import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
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

    // Store the message in both parties' message subcollections
    await senderDoc.collection(kMessageCollection).add(messageData);
    await receiverDoc.collection(kMessageCollection).add(messageData);

    // Update chat preview for sender (current user)
    await senderDoc.set(messageModel.toJson());

    // Prepare and update chat preview for recipient
    final receiverChatPreview = {
      'uid': messageModel.friendUid,
      'friendUid': messageModel.uid,
      'textMessage': messageModel.textMessage,
      'voiceRecord': messageModel.voiceRecord,
      'images': messageModel.images,
      kCreatedAt: timestamp,
    };
    await receiverDoc.set(receiverChatPreview);

    // Locally update displayed chat preview items (UI refresh)
    _updateChatItemInList(
      friendUid: messageModel.friendUid,
      dateTime: messageModel.dateTime,
      textMessage: messageModel.textMessage,
      voiceMessage: messageModel.voiceRecord,
      images: messageModel.images,
    );
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
      debugPrint("Error cancelling: $e");
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
    // Different permission on Android 13+ (photos) vs <= Android 12 (storage)
    if (Platform.isAndroid && (await _getAndroidVersion()) >= 13) {
      status = await Permission.photos.request(); // Android 13+
    } else {
      status = await Permission.storage.request(); // Android 12 and below
    }

    // After checking permission status...
    if (status.isGranted) {
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
    }
  }

  /// Helper for Android: read OS major version; used for correct permission request
  Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      return int.parse(Platform.version.split(' ')[0].split('.')[0]);
      // Note: device_info_plus is more robust for SDK version if you need exact information
    }
    return 0; // Not android
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
          messageList.add(MessageModel.fromJson(doc.data()));
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

  /// Loads all chat preview items for this user (called on chat list screen load)
  Future<void> getChats() async {
    emit(GetChatsLoadingState());
    try {
      // Query all chat preview docs, newest on top
      final chatCollection = await FirebaseFirestore.instance
          .collection(kUsersCollection)
          .doc(currentUserId)
          .collection(kChatCollection)
          .orderBy(kCreatedAt, descending: true)
          .get();

      chatItemsList.clear();
      // Convert Firestore docs to ChatItemModel instances for the UI
      for (var chatItem in chatCollection.docs) {
        ChatItemModel chatItemModel = ChatItemModel(
          uid: chatItem.id,
          textMessage: chatItem.data()['textMessage'],
          voiceRecord: chatItem.data()['voiceRecord'],
          images: (chatItem.data()['images']),
          dateTime: (chatItem.data()[kCreatedAt] as Timestamp).toDate(),
        );
        chatItemsList.add(chatItemModel);
      }
      emit(GetChatsSuccessState());
    } on Exception catch (e) {
      emit(GetChatsFailureState(errMessage: e.toString()));
    }
  }

  /// Locally updates (adds/modifies) a ChatItemModel in [chatItemsList] after message was sent
  /// Ensures chat sidebar/list reflects latest message contents & timestamp immediately
  void _updateChatItemInList({
    required String friendUid,
    String? textMessage,
    String? voiceMessage,
    List<String>? images,
    required DateTime dateTime,
  }) {
    // If already exists, update the entry. Otherwise, add as new chat preview.
    final existingIndex = chatItemsList.indexWhere(
      (item) => item.uid == friendUid,
    );

    if (existingIndex != -1) {
      chatItemsList[existingIndex] = ChatItemModel(
        uid: friendUid,
        textMessage: textMessage,
        voiceRecord: voiceMessage,
        images: images,
        dateTime: dateTime,
      );
    } else {
      chatItemsList.add(
        ChatItemModel(
          uid: friendUid,
          textMessage: textMessage,
          dateTime: dateTime,
          voiceRecord: voiceMessage,
          images: images,
        ),
      );
    }

    // Re-sort for newest at the top
    chatItemsList.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    emit(GetChatsSuccessState());
  }

  /*
  // Example: How to send push notification after message (not in use; left for reference)
  // Future<void> pushMessageNotificationToTheFriend({
  //   required String token,
  //   required String title,
  //   required String content,
  // }) async {
  //   try {
  //     await DioHelper.post(token: token, title: title, bodyContent: content);
  //     emit(PushMessageNotificationToTheFriendSuccess());
  //   } on Exception catch (e) {
  //     emit(PushMessageNotificationToTheFriendFailure(
  //         errMessage: 'Error sending push notification: ${e.toString()}'));
  //   }
  // }
  */

  /// Disposes of the Firestore listener to avoid leaks; always call when cubit is closed
  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
