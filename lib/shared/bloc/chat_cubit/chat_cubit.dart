import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:social_media_app/models/chat_item_model.dart';
import 'package:social_media_app/models/message_model.dart';
import 'package:social_media_app/shared/components/constants.dart';
import 'package:social_media_app/shared/network/local/cache_helper.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import 'package:social_media_app/shared/services/notification_service.dart';

part 'chat_state.dart';

/// Cubit responsible for managing chat-related state (sending/receiving messages, recording audio, image handling, etc)
class ChatCubit extends Cubit<ChatState> {
  /// Constructor: initializes initial state and audio recorder
  ChatCubit() : super(ChatInitial()) {
    _initRecorder();
  }

  /// Stream that emits current amplitude values while recording voice
  Stream<Amplitude> get amplitudeStream =>
      audioRecorder.onAmplitudeChanged(const Duration(milliseconds: 100));

  /// Holds a reference to the audio recorder for recording audio messages
  late final AudioRecorder audioRecorder;

  /// Current list of chat messages (MessageModel) in an open chat
  List<MessageModel> messageList = [];

  /// Subscription handler for the Firestore real-time messages stream
  StreamSubscription<QuerySnapshot>? _messagesSubscription;

  /// User's current UID, loaded from local cache
  final currentUserId = CacheHelper.getData(key: kUidToken);

  /// Send a message (text/image/voice) via Firestore for this chat
  Future<void> sendAMessage(final MessageModel messageModel) async {
    emit(SendMessageLoading()); // Loading state before send operation
    try {
      // Check if message contains any content
      bool hasText = messageModel.textMessage?.isNotEmpty ?? false;
      bool hasVoice = messageModel.voiceRecord?.isNotEmpty ?? false;
      bool hasImage = messageModel.images?.isNotEmpty ?? false;

      // Prevent sending empty message – must contain text, image, or voice
      if (hasText || hasVoice || hasImage) {
        await _sendTextImageRecord(messageModel);
        emit(SendMessageSuccess());
      }
    } on Exception catch (e) {
      emit(SendMessageFailure(errMessage: e.toString())); // Error state
    }
  }

  /// Helper: Actually pushes the text/image/voice record to Firestore for sender and receiver,
  /// and updates chat preview items
  Future<void> _sendTextImageRecord(MessageModel messageModel) async {
    final timestamp = Timestamp.fromDate(messageModel.dateTime);

    // Data for Firestore message document
    final messageData = {
      'uid': messageModel.uid,
      'friendUid': messageModel.friendUid,
      'textMessage': messageModel.textMessage,
      'voiceRecord': messageModel.voiceRecord,
      'images': messageModel.images,
      kCreatedAt: timestamp,
      'isRead': false,
      'isDelivered': false,
    };

    // Prepare document refs for sender and recipient (chat preview + messages)
    final senderDoc = FirebaseFirestore.instance
        .collection(kUsersCollection)
        .doc(messageModel.uid)
        .collection(kChatCollection)
        .doc(messageModel.friendUid);

    final receiverDoc = FirebaseFirestore.instance
        .collection(kUsersCollection)
        .doc(messageModel.friendUid)
        .collection(kChatCollection)
        .doc(messageModel.uid);

    // Generate a unique ID for the message
    final messageId = senderDoc.collection(kMessageCollection).doc().id;

    // Store the message in both parties' message subcollections using the SAME ID
    await senderDoc
        .collection(kMessageCollection)
        .doc(messageId)
        .set(messageData);
    await receiverDoc
        .collection(kMessageCollection)
        .doc(messageId)
        .set(messageData);

    // Update chat preview for sender (current user) - always marked as read for them
    final senderChatPreview = messageModel.toJson();
    senderChatPreview['isRead'] = true;
    await senderDoc.set(senderChatPreview);

    // Prepare and update chat preview for recipient
    final receiverChatPreview = {
      'uid': messageModel.friendUid,
      'friendUid': messageModel.uid,
      'textMessage': messageModel.textMessage,
      'voiceRecord': messageModel.voiceRecord,
      'images': messageModel.images,
      kCreatedAt: timestamp,
      'isRead': false, // Preview also tracks read status if needed
      'isDelivered': false,
    };
    await receiverDoc.set(receiverChatPreview);

    // Send Notification to Receiver
    String notificationContent = '';

    if (messageModel.voiceRecord != null &&
        messageModel.voiceRecord!.isNotEmpty) {
      notificationContent = 'Voice recording';
    } else if (messageModel.images != null && messageModel.images!.isNotEmpty) {
      // If image matches with text
      if (messageModel.textMessage != null &&
          messageModel.textMessage!.isNotEmpty) {
        notificationContent = messageModel.textMessage!;
      } else {
        notificationContent = 'Sent an image';
      }
    } else {
      notificationContent = messageModel.textMessage ?? '';
    }

    // REMOVED: Saving message to general notifications collection
    // We only want push notifications and a badge on the chat icon.

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection(kUsersCollection)
          .doc(messageModel.uid)
          .get();

      if (userDoc.exists) {
        final senderData = userDoc.data();
        if (senderData != null) {
          final senderName =
              '${senderData['firstName']} ${senderData['lastName']}';

          // REMOVED: Saving message to general notifications collection
          // We only want push notifications and a badge on the chat icon.

          // Send Push Notification
          final friendDoc = await FirebaseFirestore.instance
              .collection(kUsersCollection)
              .doc(messageModel.friendUid)
              .get();
          if (friendDoc.exists) {
            final friendData = friendDoc.data();
            if (friendData != null) {
              final String? token = friendData['fcmToken'];
              if (token != null && token.isNotEmpty) {
                await NotificationService().sendNotification(
                  receiverToken: token,
                  title: senderName,
                  body: notificationContent,
                  senderPhoto: senderData['photo'],
                  data: {
                    'type': 'message',
                    'uid': messageModel.uid,
                  },
                );
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }

  /// True if an audio recording is currently happening; controls button/UI state
  bool isRecording = false;

  /// Initializes audio recorder object (required before recording)
  void _initRecorder() {
    audioRecorder = AudioRecorder();
  }

  /// High-level: record audio, upload it and send it as a message to [friendUid]
  Future<void> recordAVoiceThenSendIt({required String friendUid}) async {
    // Step 1: Record audio and upload to storage, get download URL
    final voiceUrl = await _recordAndUploadAVoice(
      myUid: currentUserId,
      friendUid: friendUid,
    );
    // Step 2: If successfully recorded/uploaded, assemble & send MessageModel
    if (voiceUrl != null) {
      MessageModel messageModel = MessageModel(
        uid: currentUserId,
        friendUid: friendUid,
        dateTime: DateTime.now(),
        voiceRecord: voiceUrl,
      );
      await sendAMessage(messageModel);
    }
  }

  /// Cancels a running audio recording, resets state, emits cancellation event
  Future<void> cancelRecording() async {
    try {
      await audioRecorder.stop(); // Always stop the audio recorder
      isRecording = false;
      emit(RecordingCancelled());
    } catch (e) {
      emit(RecordAndUploadAVoiceFailureState(
          errMessage: "Error cancelling: $e"));
    }
  }

  /// Stores the url of currently playing audio, if any (used to update UI when a specific audio is played)
  String? currentlyPlayingUrl;

  /// Notifies that the voice message at [url] has started playing (for state/UI sync)
  void notifyVoicePlaying(String url) {
    currentlyPlayingUrl = url;
    emit(VoicePlayingStarted(url));
  }

  /// Handles the recording start/stop cycle and uploads the result;
  /// If recording is stopped, uploads audio file and returns url. If not, starts a recording.
  Future<String?> _recordAndUploadAVoice({
    required String myUid,
    required String friendUid,
  }) async {
    String? recordUrl;

    // 1. Permission check for microphone access
    if (await audioRecorder.hasPermission() == false) return null;

    try {
      if (isRecording) {
        // Stop logic
        emit(RecordingStoped());
        final path = await audioRecorder.stop();
        if (path != null) {
          final file = File(path);
          // Ensure file is valid (not zero-sized)
          if (await file.exists() && await file.length() > 0) {
            // Upload to Firebase Storage and get the URL
            recordUrl = await _uploadAndGetRecordFromFirebase(path);
            if (recordUrl != null) emit(RecordAndUploadAVoiceSuccessState());
          }
          isRecording = false;
        }
      } else {
        // Start logic: create temporary filepath for upcoming audio record
        Directory tempDir = await getTemporaryDirectory();
        final String recordFilePath = p.join(
          tempDir.path,
          'rec_${DateTime.now().millisecondsSinceEpoch}.m4a',
        );
        // Audio config: AAC/128kbps/44.1kHz (pretty standard)
        const config = RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        );

        await audioRecorder.start(config, path: recordFilePath);

        isRecording = true;
        emit(RecordingNowState());
      }
    } catch (e) {
      isRecording = false;
      emit(RecordAndUploadAVoiceFailureState(errMessage: e.toString()));
    }
    return recordUrl;
  }

  /// Upload a recorded audio file to Firebase Storage, emitting events for status and returning the download url
  Future<String?> _uploadAndGetRecordFromFirebase(
    String theRecordedFilePath,
  ) async {
    String? recordUrl;
    emit(UploadRecordLoading());
    try {
      final task = await FirebaseStorage.instance
          .ref()
          .child(
            // Place under chat/records/filename
            '$kChatCollection/records/${Uri.file(theRecordedFilePath).pathSegments.last}',
          )
          .putFile(File(theRecordedFilePath));
      recordUrl = await task.ref.getDownloadURL();
    } on Exception catch (e) {
      emit(
        UploadRecordFailure(
          errMessage:
              'Upload record failure: ${e.toString()}, please try again',
        ),
      );
    }
    if (recordUrl != null) {
      emit(RecordAndUploadAVoiceSuccessState());

      // delete record file from the device after get the url LInk
      File(theRecordedFilePath).delete().catchError((e) {
        debugPrint("Error deleting local file: $e");
      });
    }
    return recordUrl;
  }

  /// Uploads all currently picked images (gallery) as well as sending text (if provided) to friendUid in one message
  /// Only proceeds if at least 1 image was picked and upload succeeds.
  Future<void> uploadAndSendPickedImagesWithTextMessageOrNot({
    required String friendUid,
    required String? textMessage,
  }) async {
    // Do nothing if nothing was picked
    if (pickedImages.isEmpty) return;

    emit(SendMessageLoading()); // Indicate transmission in progress

    // Upload all selected images first
    List<String> imagesUrls =
        await _uploadMultipleImages(imagesFilesPicked: pickedImages);

    // Once uploading is successful, send assembled message (with or without text)
    if (imagesUrls.isNotEmpty) {
      final messageModel = MessageModel(
        textMessage: textMessage,
        uid: currentUserId, // Sender's UID
        friendUid: friendUid, // Recipient's UID
        dateTime: DateTime.now(), // Timestamp
        images: imagesUrls, // Uploaded image urls
      );
      await sendAMessage(messageModel);

      // After sending, clear picker states for new batch
      selectedAssets.clear();
      pickedImages.clear();
      emit(UpdatePickedImagesState());
    }
  }

  /// Holds picked images as File objects (populated after successful image picking)
  List<File> pickedImages = [];

  /// Corresponding list of selected images as AssetEntities (as required by picker widget)
  List<AssetEntity> selectedAssets = [];

  /// Opens gallery picker dialog for user to select images; saves the results for preview and upload
  Future<void> pickImagesForPreview(BuildContext context) async {
    PermissionStatus status;

    // Logic to handle different permissions based on Android API levels
    if (Platform.isAndroid) {
      final androidVersion = await _getAndroidVersion();

      if (androidVersion >= 33) {
        // Android 13 (API 33) and above uses [Permission.photos]
        // This maps to READ_MEDIA_IMAGES in the Manifest
        status = await Permission.photos.request();
      } else {
        // Android 12 (API 32) and below uses [Permission.storage]
        // This maps to READ_EXTERNAL_STORAGE in the Manifest
        status = await Permission.storage.request();
      }
    } else {
      // For iOS and other platforms
      status = await Permission.photos.request();
    }

    // After checking permission status...
    if (status.isGranted && context.mounted) {
      // User granted access; show asset picker dialog
      final List<AssetEntity>? result = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(
          selectedAssets: selectedAssets,
          maxAssets: 10,
          requestType: RequestType.image,
        ),
      );

      if (result != null) {
        // Save picked asset list for downstream use
        selectedAssets = result;
        pickedImages.clear();

        // Convert picked AssetEntities to File for preview/upload
        for (var asset in result) {
          final File? file = await asset.file;
          if (file != null) {
            pickedImages.add(file);
          }
        }
        emit(UpdatePickedImagesState());
      }
    } else if (status.isPermanentlyDenied) {
      // If user blocked permission, direct to settings
      openAppSettings();
    } else {
      // Permission denied (not permanent).
      emit(PickImageFailureState(
          errMessage: "Gallery access permission denied"));
    }
  }

  /// Helper function to get the correct SDK version
  Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      // Create an instance of DeviceInfoPlugin
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      // Get android specific information
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      // return the actual SDK integer (e.g., 33, 34, 31)
      return androidInfo.version.sdkInt;
    }
    return 0;
  }

  /// Remove a single image from local preview (before sending), update UI
  void removeImageFromPreview(int index) {
    // Remove the picked image and asset at specified position
    pickedImages.removeAt(index);
    selectedAssets.removeAt(index);
    emit(UpdatePickedImagesState()); // To refresh preview
  }

  /// Compress (downscale) an image to JPEG before upload; saves bandwidth and storage
  /// Returns the new file, or null if compression failed
  Future<File?> _compressImage(File file) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath = p.join(
        tempDir.path,
        "${DateTime.now().millisecondsSinceEpoch}.jpg",
      );
      // Compress with 70% quality; output JPEG for best support vs size
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 70,
        format: CompressFormat.jpeg,
      );
      return result != null ? File(result.path) : null;
    } on Exception catch (e) {
      debugPrint("compress image failure : $e");
    }
    return null;
  }

  /// Upload multiple images to Firebase Storage sequentially, returning all their download URLs
  Future<List<String>> _uploadMultipleImages({
    required List<File> imagesFilesPicked,
  }) async {
    emit(UploadImageLoading());
    List<String> imagesUrl = [];

    // For each file, compress and upload, append url if successful
    for (var imageFile in imagesFilesPicked) {
      try {
        File? compressedFile = await _compressImage(imageFile);

        File fileToUpload = compressedFile ?? imageFile;
        // Extract filename for use in Firebase storage path
        String fileName = p.basename(fileToUpload.path);
        final ref = FirebaseStorage.instance.ref().child(
              '$kChatCollection/images/$fileName',
            );

        // Notice: this should upload compressed file (fileToUpload), not imageFile
        final task = await ref.putFile(fileToUpload);
        final imageUrl = await task.ref.getDownloadURL();
        imagesUrl.add(imageUrl);
      } catch (e) {
        emit(UploadImageFailure(errMessage: "Failed uploading an image: $e"));
      }
    }
    return imagesUrl;
  }

  /// Activates realtime message listener for chat between current user and [friendUid]
  /// Emits appropriate states for loading, success, or error; keeps messageList up to date
  void getMessages({required String friendUid}) {
    // If chat is empty, emit loading for UI feedback first
    if (messageList.isEmpty) {
      emit(GetMessagesLoading());
    }

    // Cancel old subscription if exists, to prevent leaks/multiple listeners
    _messagesSubscription?.cancel();

    // Listen for Firestore message updates for this conversation, sorted latest-to-oldest
    _messagesSubscription = FirebaseFirestore.instance
        .collection(kUsersCollection)
        .doc(currentUserId)
        .collection(kChatCollection)
        .doc(friendUid)
        .collection(kMessageCollection)
        .orderBy(kCreatedAt, descending: true)
        .snapshots()
        .listen(
      (event) {
        // Clear current list and refill with updated documents
        messageList.clear();

        for (var doc in event.docs) {
          final message = MessageModel.fromJson(doc.data());
          messageList.add(message);

          // If the message is from the friend (incoming) and NOT read, mark it as read/delivered
          if (message.uid == friendUid && !message.isRead) {
            // Update MY copy (Receiver)
            doc.reference.update({'isRead': true, 'isDelivered': true});

            FirebaseFirestore.instance
                .collection(kUsersCollection)
                .doc(friendUid)
                .collection(kChatCollection)
                .doc(currentUserId)
                .collection(kMessageCollection)
                .doc(doc.id)
                .update({'isRead': true, 'isDelivered': true});

            // Update MY Chat Preview to mark it as read
            FirebaseFirestore.instance
                .collection(kUsersCollection)
                .doc(currentUserId)
                .collection(kChatCollection)
                .doc(friendUid)
                .update({'isRead': true});
          }
        }

        // Emit updated messages to UI (copy used in case of mutation by listeners)
        emit(GetMessagesSuccess(messages: List.from(messageList)));
      },
      onError: (error) {
        // On error (e.g. connectivity), show an error state but preserve UI as-is
        emit(GetMessagesFailure(errMessage: error.toString()));
      },
    );
  }

  /// List of chat previews (sidebar/recent chats) for current user
  List<ChatItemModel> chatItemsList = [];

  /// Subscription handler for the chat list stream
  StreamSubscription<QuerySnapshot>? _chatsSubscription;

  /// Loads all chat preview items for this user (called on chat list screen load)
  /// Uses a real-time listener to update the list automatically.
  Future<void> getChats() async {
    emit(GetChatsLoadingState());

    // Cancel old subscription if exists
    _chatsSubscription?.cancel();

    _chatsSubscription = FirebaseFirestore.instance
        .collection(kUsersCollection)
        .doc(currentUserId)
        .collection(kChatCollection)
        .orderBy(kCreatedAt, descending: true)
        .snapshots()
        .listen(
      (event) {
        chatItemsList.clear();
        for (var chatItem in event.docs) {
          ChatItemModel chatItemModel = ChatItemModel(
            uid: chatItem.id,
            textMessage: chatItem.data()['textMessage'],
            voiceRecord: chatItem.data()['voiceRecord'],
            images: (chatItem.data()['images']),
            dateTime: (chatItem.data()[kCreatedAt] as Timestamp).toDate(),
            isRead: chatItem.data()['isRead'] ?? true,
          );
          chatItemsList.add(chatItemModel);
        }
        emit(GetChatsSuccessState());
      },
      onError: (error) {
        emit(GetChatsFailureState(errMessage: error.toString()));
      },
    );
  }

  /// Disposes of the Firestore listener to avoid leaks; always call when cubit is closed
  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
