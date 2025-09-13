import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:social_media_app/shared/components/constants.dart';

class MessageModel extends Equatable {
  final String message, uid, friendUid;
  final DateTime dateTime;

  const MessageModel({
    required this.message,
    required this.uid,
    required this.friendUid,
    required this.dateTime,
  });

  factory MessageModel.fromJson(json) => MessageModel(
        message: json['message'],
        uid: json['uid'],
        friendUid: json['friendUid'],
        dateTime: (json['dateTime'] as Timestamp).toDate(),
      );

  Map<String, dynamic> toJson() => {
        'message': message,
        'uid': uid,
        'friendUid': friendUid,
        kCreatedAt: dateTime,
      };

  @override
  List<Object?> get props => [message, uid, friendUid, dateTime];
}
