import 'dart:async';
import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
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

  late final RecorderController recorderController;

  /// List to store messages for the current chat
  List<MessageModel> messageList = [];

  /// Subscription to Firestore messages stream
  StreamSubscription<QuerySnapshot>? _messagesSubscription;

  /// Sends a message to Firestore for the given [messageModel]
  Future<void> sendMessages(final MessageModel messageModel) async {
    emit(SendMessageLoading());
    try {
      // Only send if the message is not empty
      if (messageModel.message?.isNotEmpty ?? false) {
        final currentUserId = CacheHelper.getData(key: kUidToken);
        final timestamp = Timestamp.fromDate(messageModel.dateTime);

        // Prepare message data with all required fields
        final messageData = {
          'message': messageModel.message,
          'uid': messageModel.uid,
          'friendUid': messageModel.friendUid,
          kCreatedAt: timestamp,
        };

        // Reference to the sender's chat collection
        final senderDoc = FirebaseFirestore.instance
            .collection(kUsersCollection)
            .doc(currentUserId)
            .collection(kChatCollection)
            .doc(messageModel.friendUid);

        // Reference to the receiver's chat collection
        final receiverDoc = FirebaseFirestore.instance
            .collection(kUsersCollection)
            .doc(messageModel.friendUid)
            .collection(kChatCollection)
            .doc(currentUserId);

        // Add the message to sender's messages collection
        await senderDoc.collection(kMessageCollection).add(messageData);

        // Add the message to receiver's messages collection (for real-time updates)
        await receiverDoc.collection(kMessageCollection).add(messageData);

        // Update the chat preview for sender
        await senderDoc.set(messageModel.toJson());

        // Update the chat preview for receiver (with reversed uid/friendUid)
        final receiverChatPreview = {
          'message': messageModel.message,
          'uid': messageModel.friendUid,
          'voiceRecord': messageModel.voiceRecord,
          'image': messageModel.image,
          'friendUid': currentUserId,
          kCreatedAt: timestamp,
        };
        await receiverDoc.set(receiverChatPreview);

        // Update the local chatItemsList to reflect the new message

        _updateChatItemInList(
            friendUid: messageModel.friendUid,
            dateTime: messageModel.dateTime,
            message: messageModel.message,
            voiceMessage: messageModel.voiceRecord,
            image: messageModel.image);
        emit(SendMessageSuccess());
      }
    } on Exception catch (e) {
      emit(SendMessageFailure(errMessage: e.toString()));
    }
  }

  Future<void> sendRecord(final MessageModel messageModel) async {
    emit(SendMessageLoading());
    try {
      // Only send if the message is not empty
      if (messageModel.voiceRecord?.isNotEmpty ?? false) {
        final currentUserId = CacheHelper.getData(key: kUidToken);
        final timestamp = Timestamp.fromDate(messageModel.dateTime);

        // Prepare message data with all required fields
        final messageData = {
          'voiceRecord': messageModel.voiceRecord,
          'uid': messageModel.uid,
          'friendUid': messageModel.friendUid,
          kCreatedAt: timestamp,
        };

        // Reference to the sender's chat collection
        final senderDoc = FirebaseFirestore.instance
            .collection(kUsersCollection)
            .doc(currentUserId)
            .collection(kChatCollection)
            .doc(messageModel.friendUid);

        // Reference to the receiver's chat collection
        final receiverDoc = FirebaseFirestore.instance
            .collection(kUsersCollection)
            .doc(messageModel.friendUid)
            .collection(kChatCollection)
            .doc(currentUserId);

        // Add the message to sender's messages collection
        await senderDoc.collection(kMessageCollection).add(messageData);

        // Add the message to receiver's messages collection (for real-time updates)
        await receiverDoc.collection(kMessageCollection).add(messageData);

        // Update the chat preview for sender
        await senderDoc.set(messageModel.toJson());

        // Update the chat preview for receiver (with reversed uid/friendUid)
        final receiverChatPreview = {
          'voiceRecord': messageModel.message,
          'uid': messageModel.friendUid,
          'friendUid': currentUserId,
          kCreatedAt: timestamp,
        };
        await receiverDoc.set(receiverChatPreview);

        // Update the local chatItemsList to reflect the new message

        _updateChatItemInList(
          friendUid: messageModel.friendUid,
          dateTime: messageModel.dateTime,
          message: messageModel.message,
          voiceMessage: messageModel.voiceRecord,
          image: messageModel.image,
        );
      }
      emit(SendMessageSuccess());
    } on Exception catch (e) {
      emit(SendMessageFailure(errMessage: e.toString()));
    }
  }

  bool isRecording = false;

  void _initRecorder() {
    recorderController = RecorderController();
  }

  Future<void> recordAVoiceThenSendIt(
      {required String myUid, required String friendUid}) async {
    final voiecUrl =
        await _recordAndUploadAVoice(myUid: myUid, friendUid: friendUid);
    if (voiecUrl != null) {
      MessageModel messageModel = MessageModel(
          voiceRecord: voiecUrl,
          uid: myUid,
          friendUid: friendUid,
          dateTime: DateTime.now());
      await sendRecord(messageModel);
    }
  }

  Future<void> cancelRecording() async {
    try {
      await recorderController.stop();
      isRecording = false;
      emit(RecordingCancelled());
    } catch (e) {
      debugPrint("Error cancelling recording: $e");
    }
  }

  Future<String?> _recordAndUploadAVoice(
      {required String myUid, required String friendUid}) async {
    String? recordUrl;
    await recorderController.checkPermission();
    try {
      if (isRecording) {
        // Stop recording...
        final theRecordedFilePath = await recorderController.stop(false);
        isRecording = false;
        emit(RecordingStoped());
        if (theRecordedFilePath != null) {
          recordUrl =
              await _uploadAndGetRecordFromFirebase(theRecordedFilePath);
          emit(RecordAndUploadAVoiceSuccessState());
        }
      } else {
        // Check and request permission if needed
        if (recorderController.hasPermission) {
          Directory appDocumentsDir = await getApplicationDocumentsDirectory();
          final String recordFilePath = p.join(appDocumentsDir.path,
              'voice_record_${DateTime.now().millisecondsSinceEpoch}.m4a');
          // Start recording to file
          await recorderController.record(path: recordFilePath);
          isRecording = true;
          emit(RecordingNowState());
        }
      }
    } on Exception catch (e) {
      isRecording = false;
      emit(RecordAndUploadAVoiceFailureState(errMessage: e.toString()));
    }
    return recordUrl;
  }

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
          errMessage: 'Upload record failur, please try again'));
    }

    return recordUrl;
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
    final currentUserId = CacheHelper.getData(key: kUidToken);

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
          .doc(CacheHelper.getData(key: kUidToken))
          .collection(kChatCollection)
          .orderBy(kCreatedAt, descending: true)
          .get();

      chatItemsList.clear();

      // Iterate through each chat document and add to the chatItemsList
      for (var chatItem in messageCollection.docs) {
        ChatItemModel chatItemModel = ChatItemModel(
          uid: chatItem.id,
          message: chatItem.data()['message'],
          voiceRecord: chatItem.data()['voiceRecord'],
          image: chatItem.data()['image'],
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
      String? message,
      String? voiceMessage,
      String? image,
      required DateTime dateTime}) {
    // Find the index of the chat item with the matching friendUid
    final existingIndex =
        chatItemsList.indexWhere((item) => item.uid == friendUid);

    if (existingIndex != -1) {
      // Update the existing chat item with the new message and date
      chatItemsList[existingIndex] = ChatItemModel(
        uid: friendUid,
        message: message,
        voiceRecord: voiceMessage,
        image: image,
        dateTime: dateTime,
      );
    } else {
      // If the chat item doesn't exist, add a new one
      chatItemsList.add(ChatItemModel(
          uid: friendUid,
          message: message,
          dateTime: dateTime,
          voiceRecord: voiceMessage,
          image: image));
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
    recorderController.dispose();
    _messagesSubscription?.cancel();
    return super.close();
  }
}
