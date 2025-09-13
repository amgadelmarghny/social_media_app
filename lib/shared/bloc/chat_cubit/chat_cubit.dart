import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  //send message to firebase firestore
  void sendMessages(final MessageModel messageModel) {
    emit(SendMessageLoading());
    try {
      final messageCollection = FirebaseFirestore.instance
          .collection(kUsersCollection)
          .doc(CacheHelper.getData(key: kUidToken))
          .collection(kChatCollection)
          .doc(messageModel.friendUid)
          .collection(kMessageCollection);

      // Call the message's CollectionReference to add a new messade
      if (messageModel.message.isNotEmpty) {
        messageCollection.add(messageModel.toJson());
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
        if (!isClosed) {
          messageList.clear();
          for (var doc in event.docs) {
            messageList.add(MessageModel.fromJson(doc.data()));
          }
          emit(GetMessagesSuccess());
        }
      });
    } on Exception catch (e) {
      emit(GetMessagesFailure(errMessage: e.toString()));
    }
  }
}
