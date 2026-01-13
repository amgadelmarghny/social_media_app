import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:social_media_app/shared/components/constants.dart';

class MessageModel extends Equatable {
  final String? message, voiceRecord, image;
  final String uid, friendUid;
  final DateTime dateTime;

  const MessageModel({
    this.message,
    this.voiceRecord,
    this.image,
    required this.uid,
    required this.friendUid,
    required this.dateTime,
  });

  factory MessageModel.fromJson(json) => MessageModel(
        message: json['message'],
        voiceRecord: json['voiceRecord'],
        image: json['image'],
        uid: json['uid'],
        friendUid: json['friendUid'],
        dateTime: (json['dateTime'] as Timestamp).toDate(),
      );

  Map<String, dynamic> toJson() => {
        'message': message,
        'voiceRecord': voiceRecord,
        'image': image,
        'uid': uid,
        'friendUid': friendUid,
        kCreatedAt: dateTime,
      };

  @override
  List<Object?> get props =>
      [message, uid, friendUid, dateTime, voiceRecord, image];
}
