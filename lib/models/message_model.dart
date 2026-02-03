import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:social_media_app/shared/components/constants.dart';

class MessageModel extends Equatable {
  final String? textMessage, voiceRecord;
  final List<String>? images;
  final String uid, friendUid;
  final DateTime dateTime;
  final bool isRead;
  final bool isDelivered;

  const MessageModel({
    this.textMessage,
    this.voiceRecord,
    this.images,
    required this.uid,
    required this.friendUid,
    required this.dateTime,
    this.isRead = false,
    this.isDelivered = false,
  });

  factory MessageModel.fromJson(json) => MessageModel(
        textMessage: json['textMessage'],
        voiceRecord: json['voiceRecord'],
        images:
            json['images'] != null ? List<String>.from(json['images']) : null,
        uid: json['uid'],
        friendUid: json['friendUid'],
        dateTime: (json['dateTime'] as Timestamp).toDate(),
        isRead: json['isRead'] ?? false,
        isDelivered: json['isDelivered'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'textMessage': textMessage,
        'voiceRecord': voiceRecord,
        'images': images,
        'uid': uid,
        'friendUid': friendUid,
        kCreatedAt: dateTime,
        'isRead': isRead,
        'isDelivered': isDelivered,
      };

  @override
  List<Object?> get props => [
        textMessage,
        uid,
        friendUid,
        dateTime,
        voiceRecord,
        images,
        isRead,
        isDelivered,
      ];
}
