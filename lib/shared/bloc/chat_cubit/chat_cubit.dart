import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/models/chat_item_model.dart';
import 'package:social_media_app/models/message_model.dart';
import 'package:social_media_app/shared/components/constants.dart';
import 'package:social_media_app/shared/network/local/cache_helper.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatInitial());

  List<MessageModel> messageList = [];
  StreamSubscription<QuerySnapshot>? _messagesSubscription;

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }

  List<ChatItemModel> chatItemsList = [];

  Future<void> getChats() async {
    emit(GetChatsLoadingState());
    try {
      final messageCollection = await FirebaseFirestore.instance
          .collection(kUsersCollection)
          .doc(CacheHelper.getData(key: kUidToken))
          .collection(kChatCollection)
          .orderBy(kCreatedAt, descending: true)
          .get();
      chatItemsList.clear();
      for (var chatItem in messageCollection.docs) {
        ChatItemModel chatItemModel = ChatItemModel(
          uid: chatItem.id,
          message: chatItem.data()['message'],
          dateTime: chatItem.data()[kCreatedAt],
        );
        chatItemsList.add(chatItemModel);
      }
      emit(GetChatsSuccessState());
    } on Exception catch (e) {
      emit(GetChatsFailureState(errMessage: e.toString()));
    }
  }

  //send message to firebase firestore
  void sendMessages(final MessageModel messageModel) async {
    emit(SendMessageLoading());
    try {
      if (messageModel.message.isNotEmpty) {
        final messageCollection = FirebaseFirestore.instance
            .collection(kUsersCollection)
            .doc(CacheHelper.getData(key: kUidToken))
            .collection(kChatCollection)
            .doc(messageModel.friendUid)
            .collection(kMessageCollection);
        // Call the message's CollectionReference to add a new messade
        messageCollection.add(messageModel.toJson());
        await FirebaseFirestore.instance
            .collection(kUsersCollection)
            .doc(CacheHelper.getData(key: kUidToken))
            .collection(kChatCollection)
            .doc(messageModel.friendUid)
            .set({
          kCreatedAt: messageModel.dateTime,
          "message": messageModel.message
        });
      }
      emit(SendMessageSuccess());
    } on Exception catch (e) {
      emit(SendMessageFailure(errMessage: e.toString()));
    }
  }

  void getMessages({required String friendUid}) {
    emit(GetMessagesLoading());
    try {
      // Cancel existing subscription
      _messagesSubscription?.cancel();

      final messageCollection = FirebaseFirestore.instance
          .collection(kUsersCollection)
          .doc(CacheHelper.getData(key: kUidToken))
          .collection(kChatCollection)
          .doc(friendUid)
          .collection(kMessageCollection);

      messageList.clear();

      _messagesSubscription = messageCollection
          .orderBy(kCreatedAt, descending: true)
          .snapshots()
          .listen((event) {
        messageList.clear();
        for (var doc in event.docs) {
          messageList.add(MessageModel.fromJson(doc.data()));
        }
        emit(GetMessagesSuccess());
      });
    } on Exception catch (e) {
      emit(GetMessagesFailure(errMessage: e.toString()));
    }
  }
}
