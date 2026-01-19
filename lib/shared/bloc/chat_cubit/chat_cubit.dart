import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:social_media_app/models/chat_item_model.dart';
import 'package:social_media_app/models/message_model.dart';
import 'package:social_media_app/shared/components/constants.dart';
import 'package:social_media_app/shared/network/local/cache_helper.dart';

part 'chat_state.dart';

/// Cubit class to manage chat-related state and logic
class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatInitial()) {
    _initRecorder();
  }

  /// Stream that provides updated amplitude for active audio recording
  Stream<Amplitude> get amplitudeStream =>
      audioRecorder.onAmplitudeChanged(const Duration(milliseconds: 100));

  late final AudioRecorder audioRecorder;

  /// List to store messages for the current chat
  List<MessageModel> messageList = [];

  /// Subscription to Firestore messages stream
  StreamSubscription<QuerySnapshot>? _messagesSubscription;

  final currentUserId = CacheHelper.getData(key: kUidToken);

  /// Sends a message to Firestore for the given [messageModel]
  Future<void> sendAMessage(final MessageModel messageModel) async {
    emit(SendMessageLoading());
    try {
      bool hasText = messageModel.textMessage?.isNotEmpty ?? false;
      bool hasVoice = messageModel.voiceRecord?.isNotEmpty ?? false;
      bool hasImage = messageModel.images?.isNotEmpty ?? false;
      // Only send if the message is not empty
      if (hasText || hasVoice || hasImage) {
        await _sendTextImageRecord(messageModel);
        emit(SendMessageSuccess());
      }
    } on Exception catch (e) {
      emit(SendMessageFailure(errMessage: e.toString()));
    }
  }

  /// Unified function that pushes all kinds of messages to Firestore (text, image, audio)
  Future<void> _sendTextImageRecord(MessageModel messageModel) async {
    final timestamp = Timestamp.fromDate(messageModel.dateTime);

    // Prepare message data (bug with images resolved here)
    final messageData = {
      'uid': messageModel.uid,
      'friendUid': messageModel.friendUid,
      'textMessage': messageModel.textMessage,
      'voiceRecord': messageModel.voiceRecord,
      'images': messageModel.images,
      kCreatedAt: timestamp,
    };

    // Firestore references for both sender and receiver
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

    // 1. Add message to both sender's and receiver's message history
    await senderDoc.collection(kMessageCollection).add(messageData);
    await receiverDoc.collection(kMessageCollection).add(messageData);

    // 2. Update latest message (preview) for the sender
    await senderDoc.set(messageModel.toJson());

    // 3. Update latest message (preview) for the receiver
    final receiverChatPreview = {
      'uid': messageModel.friendUid,
      'friendUid': messageModel.uid,
      'textMessage': messageModel.textMessage,
      'voiceRecord': messageModel.voiceRecord,
      'images': messageModel.images,
      kCreatedAt: timestamp,
    };
    await receiverDoc.set(receiverChatPreview);

    // 4. Update local chat item list for better UX
    _updateChatItemInList(
      friendUid: messageModel.friendUid,
      dateTime: messageModel.dateTime,
      textMessage: messageModel.textMessage,
      voiceMessage: messageModel.voiceRecord,
      images: messageModel.images,
    );
  }

  /// Flag for current recording status
  bool isRecording = false;

  /// Initialize the audio recorder
  void _initRecorder() {
    audioRecorder = AudioRecorder();
  }

  /// Record a voice message and send it to chat with [friendUid]
  Future<void> recordAVoiceThenSendIt({required String friendUid}) async {
    final voiceUrl = await _recordAndUploadAVoice(
        myUid: currentUserId, friendUid: friendUid);
    if (voiceUrl != null) {
      MessageModel messageModel = MessageModel(
          uid: currentUserId,
          friendUid: friendUid,
          dateTime: DateTime.now(),
          voiceRecord: voiceUrl);

      await sendAMessage(messageModel);
    }
  }

  /// Cancel an ongoing recording
  Future<void> cancelRecording() async {
    try {
      await audioRecorder.stop(); // Stop the actual recorder
      isRecording = false;
      emit(RecordingCancelled());
    } catch (e) {
      debugPrint("Error cancelling: $e");
    }
  }

  /// Currently playing audio url (if any)
  String? currentlyPlayingUrl;

  /// Notify UI that a voice message [url] started playing
  void notifyVoicePlaying(String url) {
    currentlyPlayingUrl = url;
    emit(VoicePlayingStarted(url));
  }

  /// Handle start/stop logic for audio recording and upload result
  Future<String?> _recordAndUploadAVoice(
      {required String myUid, required String friendUid}) async {
    String? recordUrl;

    if (await audioRecorder.hasPermission() == false) return null;

    try {
      if (isRecording) {
        emit(RecordingStoped());

        final path = await audioRecorder.stop();

        if (path != null) {
          final file = File(path);
          if (await file.exists() && await file.length() > 0) {
            recordUrl = await _uploadAndGetRecordFromFirebase(path);
            if (recordUrl != null) emit(RecordAndUploadAVoiceSuccessState());
          }
          isRecording = false;
        }
      } else {
        Directory tempDir = await getTemporaryDirectory();
        final String recordFilePath = p.join(
            tempDir.path, 'rec_${DateTime.now().millisecondsSinceEpoch}.m4a');

        const config = RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        );

        await audioRecorder.start(config, path: recordFilePath);
        // recorderController.record() is no longer used to prevent microphone conflict

        isRecording = true;
        emit(RecordingNowState());
      }
    } catch (e) {
      isRecording = false;
      emit(RecordAndUploadAVoiceFailureState(errMessage: e.toString()));
    }
    return recordUrl;
  }

  /// Uploads a recorded audio file to Firebase Storage and gets its url
  Future<String?> _uploadAndGetRecordFromFirebase(
      String theRecordedFilePath) async {
    String? recordUrl;
    emit(UploadRecordLoading());
    try {
      final task = await FirebaseStorage.instance
          .ref()
          .child(
              '$kChatCollection/records/${Uri.file(theRecordedFilePath).pathSegments.last}')
          .putFile(File(theRecordedFilePath));
      recordUrl = await task.ref.getDownloadURL();
    } on Exception catch (e) {
      emit(UploadRecordFailure(
          errMessage:
              'Upload record failure: ${e.toString()}, please try again'));
    }

    return recordUrl;
  }

  /// Pick multiple images from gallery and send them to chat with [friendUid]
  Future<void> pickAndSendImages({required String friendUid}) async {
    List<File> imagesFiles = await _pickMultipleImages();
    List<String> imagesUrls = [];
    if (imagesFiles.isNotEmpty) {
      imagesUrls = await _uploadMultipleImages(imagesFiles: imagesFiles);
    }
    if (imagesUrls.isEmpty) {
      // Always send a message, even if imagesUrls is empty
      MessageModel messageModel = MessageModel(
          uid: currentUserId,
          friendUid: friendUid,
          dateTime: DateTime.now(),
          images: imagesUrls);
      await sendAMessage(messageModel);
    }
  }

  /// Pick multiple images from the gallery and return [List<File>]
  Future<List<File>> _pickMultipleImages() async {
    emit(PickImageLoadingState());

    final ImagePicker picker = ImagePicker();
    // Use pickMultiImage instead of pickImage
    final List<XFile> selectedImages = await picker.pickMultiImage();

    if (selectedImages.isNotEmpty) {
      // Convert list of XFile to a list of File
      return selectedImages.map((xFile) => File(xFile.path)).toList();
    } else {
      // Return empty list if nothing was picked
      return [];
    }
  }

  /// Upload multiple images and return their Firebase URLs
  Future<List<String>> _uploadMultipleImages({
    required List<File> imagesFiles,
  }) async {
    List<String> imagesUrl = [];
    // 1. Pick images

    for (var imageFile in imagesFiles) {
      try {
        // 2. Upload each image individually
        String fileName = p.basename(imageFile.path);
        final ref = FirebaseStorage.instance
            .ref()
            .child('$kChatCollection/images/$fileName');

        final task = await ref.putFile(imageFile);
        final imageUrl = await task.ref.getDownloadURL();
        imagesUrl.add(imageUrl);
      } catch (e) {
        emit(UploadImageFailure(errMessage: "Failed uploading an image: $e"));
      }
    }
    return imagesUrl;
  }

  /// Listens to messages in real-time for a specific friend [friendUid]
  /// Listen to real-time updates in message collection for a specific chat with a given friendUid.
  /// Emits [GetMessagesLoading] if local messageList is empty (to show loading UI only on initial load).
  /// Subscribes to Firestore changes, keeping the local messageList in-sync with remote data.
  /// Emits [GetMessagesSuccess] with a cloned list after every new batch of messages arrives.
  /// If an error occurs, we're not emitting failure state to preserve existing messages in UI.
  void getMessages({required String friendUid}) {
    // Emit loading state if no cached messages (first load or cleared chat)
    if (messageList.isEmpty) {
      emit(GetMessagesLoading());
    }

    // Cancel any previous real-time subscription before listening to a new one
    _messagesSubscription?.cancel();

    // Retrieve current user's id from cache (required to locate their chat collection)

    // Set up Firestore real-time listener for the selected chat's messages,
    // ordered so the newest messages come first in the list
    _messagesSubscription = FirebaseFirestore.instance
        .collection(kUsersCollection)
        .doc(currentUserId)
        .collection(kChatCollection)
        .doc(friendUid)
        .collection(kMessageCollection)
        .orderBy(kCreatedAt, descending: true) // Most recent first (index 0)
        .snapshots()
        .listen((event) {
      // Clear the local message list before re-filling it (to avoid duplicates)
      messageList.clear();

      // Populate messageList with fresh snapshot data from Firestore
      for (var doc in event.docs) {
        messageList.add(MessageModel.fromJson(doc.data()));
      }

      // Emit state with the up-to-date messages; clone to avoid accidental mutation
      emit(GetMessagesSuccess(messages: List.from(messageList)));
    }, onError: (error) {
      // handle errors, e.g. network issues (currently just ignore errors to preserve messages)
      emit(GetMessagesFailure(errMessage: error.toString()));
    });
  }

  /// List to store chat items (chat previews)
  List<ChatItemModel> chatItemsList = [];

  /// Fetches the list of chat previews for the current user
  Future<void> getChats() async {
    emit(GetChatsLoadingState());
    try {
      // Get the chat collection for the current user, ordered by creation date
      final messageCollection = await FirebaseFirestore.instance
          .collection(kUsersCollection)
          .doc()
          .collection(kChatCollection)
          .orderBy(kCreatedAt, descending: true)
          .get();

      chatItemsList.clear();

      // Iterate through each chat document and add to the chatItemsList
      for (var chatItem in messageCollection.docs) {
        ChatItemModel chatItemModel = ChatItemModel(
          uid: chatItem.id,
          textMessage: chatItem.data()['textMessage'],
          voiceRecord: chatItem.data()['voiceRecord'],
          images: chatItem.data()['images'],
          dateTime: (chatItem.data()[kCreatedAt] as Timestamp).toDate(),
        );
        chatItemsList.add(chatItemModel);
      }
      emit(GetChatsSuccessState());
    } on Exception catch (e) {
      emit(GetChatsFailureState(errMessage: e.toString()));
    }
  }

  /// Updates the chat item in the local chatItemsList after sending a message
  /// This ensures the chat list shows the latest message without needing to refetch from Firestore
  void _updateChatItemInList(
      {required String friendUid,
      String? textMessage,
      String? voiceMessage,
      List<String>? images,
      required DateTime dateTime}) {
    // Find the index of the chat item with the matching friendUid
    final existingIndex =
        chatItemsList.indexWhere((item) => item.uid == friendUid);

    if (existingIndex != -1) {
      // Update the existing chat item with the new message and date
      chatItemsList[existingIndex] = ChatItemModel(
        uid: friendUid,
        textMessage: textMessage,
        voiceRecord: voiceMessage,
        images: images,
        dateTime: dateTime,
      );
    } else {
      // If the chat item doesn't exist, add a new one
      chatItemsList.add(ChatItemModel(
          uid: friendUid,
          textMessage: textMessage,
          dateTime: dateTime,
          voiceRecord: voiceMessage,
          images: images));
    }

    // Sort the list by dateTime in descending order (newest first)
    chatItemsList.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    // Emit success state to trigger UI update in ChatsBody
    emit(GetChatsSuccessState());
  }

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

  /// Override close to cancel the Firestore subscription when cubit is disposed
  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
