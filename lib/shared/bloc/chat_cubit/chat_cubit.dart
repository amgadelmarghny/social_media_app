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

  Stream<Amplitude> get amplitudeStream =>
      audioRecorder.onAmplitudeChanged(const Duration(milliseconds: 100));

  late final AudioRecorder audioRecorder;

  /// List to store messages for the current chat
  List<MessageModel> messageList = [];

  /// Subscription to Firestore messages stream
  StreamSubscription<QuerySnapshot>? _messagesSubscription;

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

  /// الدالة الموحدة التي تقوم بعملية الرفع إلى Firestore لكل أنواع الرسائل
  Future<void> _sendTextImageRecord(MessageModel messageModel) async {
    final timestamp = Timestamp.fromDate(messageModel.dateTime);

    // تجهيز البيانات (تم إصلاح خطأ الصورة هنا)
    final messageData = {
      'uid': messageModel.uid,
      'friendUid': messageModel.friendUid,
      'textMessage': messageModel.textMessage,
      'voiceRecord': messageModel.voiceRecord,
      'images': messageModel.images,
      kCreatedAt: timestamp,
    };

    // مراجع الـ Firestore
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

    // 1. إضافة الرسالة في سجل الرسائل للطرفين
    await senderDoc.collection(kMessageCollection).add(messageData);
    await receiverDoc.collection(kMessageCollection).add(messageData);

    // 2. تحديث "آخر رسالة" (Preview) عند المرسل
    await senderDoc.set(messageModel.toJson());

    // 3. تحديث "آخر رسالة" (Preview) عند المستقبل
    final receiverChatPreview = {
      'uid': messageModel.friendUid,
      'friendUid': messageModel.uid,
      'textMessage': messageModel.textMessage,
      'voiceRecord': messageModel.voiceRecord,
      'images': messageModel.images,
      kCreatedAt: timestamp,
    };
    await receiverDoc.set(receiverChatPreview);

    // 4. تحديث القائمة المحلية فوراً لتحسين تجربة المستخدم
    _updateChatItemInList(
      friendUid: messageModel.friendUid,
      dateTime: messageModel.dateTime,
      textMessage: messageModel.textMessage,
      voiceMessage: messageModel.voiceRecord,
      images: messageModel.images,
    );
  }

  bool isRecording = false;

  void _initRecorder() {
    audioRecorder = AudioRecorder();
  }

  Future<void> recordAVoiceThenSendIt({required String friendUid}) async {
    final currentUserId = CacheHelper.getData(key: kUidToken);
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

  Future<void> cancelRecording() async {
    try {
      await audioRecorder.stop(); // إيقاف المسجل الفعلي
      isRecording = false;
      emit(RecordingCancelled());
    } catch (e) {
      debugPrint("Error cancelling: $e");
    }
  }

  String? currentlyPlayingUrl;

  void notifyVoicePlaying(String url) {
    currentlyPlayingUrl = url;
    emit(VoicePlayingStarted(url));
  }

  Future<String?> _recordAndUploadAVoice(
      {required String myUid, required String friendUid}) async {
    String? recordUrl;

    if (await audioRecorder.hasPermission() == false) return null;

    try {
      if (isRecording) {
        isRecording = false;
        emit(RecordingStoped());

        final path = await audioRecorder.stop();

        if (path != null) {
          final file = File(path);
          if (await file.exists() && await file.length() > 0) {
            recordUrl = await _uploadAndGetRecordFromFirebase(path);
            if (recordUrl != null) emit(RecordAndUploadAVoiceSuccessState());
          }
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
        // تم إلغاء recorderController.record() لمنع الصراع على الميكروفون

        isRecording = true;
        emit(RecordingNowState());
      }
    } catch (e) {
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
          errMessage:
              'Upload record failure: ${e.toString()}, please try again'));
    }

    return recordUrl;
  }

  Future<void> pickAndSendImages({required String friendUid}) async {
    List<File> imagesFiles = await _pickMultipleImages();
    List<String> imagesUrls = [];
    if (imagesFiles.isNotEmpty) {
      imagesUrls = await _uploadMultipleImages(imagesFiles: imagesFiles);
    }
    if (imagesUrls.isEmpty) {
      final currentUserId = CacheHelper.getData(key: kUidToken);
      MessageModel messageModel = MessageModel(
          uid: currentUserId,
          friendUid: friendUid,
          dateTime: DateTime.now(),
          images: imagesUrls);
      await sendAMessage(messageModel);
    }
  }

  /// Pick multiple images from the gallery and return [List <File>]
  Future<List<File>> _pickMultipleImages() async {
    emit(PickImageLoadingState());

    final ImagePicker picker = ImagePicker();
    // استخدام pickMultiImage بدلاً من pickImage
    final List<XFile> selectedImages = await picker.pickMultiImage();

    if (selectedImages.isNotEmpty) {
      // تحويل قائمة XFile إلى قائمة File
      return selectedImages.map((xFile) => File(xFile.path)).toList();
    } else {
      // إرجاع قائمة فارغة إذا لم يتم اختيار شيء
      return [];
    }
  }

  Future<List<String>> _uploadMultipleImages({
    required List<File> imagesFiles,
  }) async {
    List<String> imagesUrl = [];
    // 1. اختيار الصور

    for (var imageFile in imagesFiles) {
      try {
        // 2. رفع كل صورة على حدة
        String fileName = p.basename(imageFile.path);
        final ref = FirebaseStorage.instance
            .ref()
            .child('$kChatCollection/images/$fileName');

        final task = await ref.putFile(imageFile);
        final imageUrl = await task.ref.getDownloadURL();
        imagesUrl.add(imageUrl);
      } catch (e) {
        emit(UploadImageFailure(errMessage: "فشل رفع إحدى الصور: $e"));
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
