import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String userName;
  final String? comment;
  final String? profilePhoto;
  final String? commentPhoto;
  final DateTime dateTime;

  CommentModel({
    required this.userName,
    required this.comment,
    required this.profilePhoto,
    required this.commentPhoto,
    required this.dateTime,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      userName: json['userName'],
      comment: json['comment'],
      profilePhoto: json['profilePhoto'],
      commentPhoto: json['commentPhoto'],
      dateTime: json['dateTime'].toData(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'comment': comment,
      'profilePhoto': profilePhoto,
      'commentPhoto': commentPhoto,
      'dateTime': Timestamp.fromDate(dateTime),
    };
  }
}
