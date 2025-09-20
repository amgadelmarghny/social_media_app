import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared/components/constants.dart';

class CommentModel {
  final String userName;
  final String? comment;
  final String? profilePhoto;
  final String? commentPhoto;
  final DateTime dateTime;
  final String userUid;

  CommentModel({
    required this.userName,
    required this.comment,
    required this.profilePhoto,
    required this.commentPhoto,
    required this.dateTime,
    required this.userUid,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      userUid: json['userUid'],
      userName: json['userName'],
      comment: json['comment'],
      profilePhoto: json['profilePhoto'],
      commentPhoto: json['commentPhoto'],
      dateTime: (json['dateTime'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userUid': userUid,
      'userName': userName,
      'comment': comment,
      'profilePhoto': profilePhoto,
      'commentPhoto': commentPhoto,
      kCreatedAt: Timestamp.fromDate(dateTime),
    };
  }
}
