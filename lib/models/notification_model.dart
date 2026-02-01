import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class NotificationModel extends Equatable {
  final String notificationId;
  final String senderUid;
  final String receiverUid;
  final String senderName;
  final String? senderPhoto;
  final String type; // 'like', 'comment', 'message'
  final String? subType; // 'text', 'voice', 'image'
  final String content;
  final String? postId;
  final bool isRead;
  final DateTime dateTime;

  const NotificationModel({
    required this.notificationId,
    required this.senderUid,
    required this.receiverUid,
    required this.senderName,
    required this.senderPhoto,
    required this.type,
    this.subType,
    required this.content,
    this.postId,
    required this.isRead,
    required this.dateTime,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notificationId'] ,
      senderUid: json['senderUid'],
      receiverUid: json['receiverUid'] ,
      senderName: json['senderName'] ,
      senderPhoto: json['senderPhoto'] ,
      type: json['type'] ,
      subType: json['subType'],
      content: json['content'] ,
      postId: json['postId'],
      isRead: json['isRead'] ,
      dateTime: (json['dateTime'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'senderUid': senderUid,
      'receiverUid': receiverUid,
      'senderName': senderName,
      'senderPhoto': senderPhoto,
      'type': type,
      'subType': subType,
      'content': content,
      'postId': postId,
      'isRead': isRead,
      'dateTime': Timestamp.fromDate(dateTime),
    };
  }

  @override
  List<Object?> get props => [
        notificationId,
        senderUid,
        receiverUid,
        senderName,
        senderPhoto,
        type,
        subType,
        content,
        postId,
        isRead,
        dateTime,
      ];
}
