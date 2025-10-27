import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../shared/components/constants.dart';

class PostModel extends Equatable {
  final String creatorUid;
  final String userName;
  final String? profilePhoto;
  final String? content;
  final String? postImage;
  final DateTime dateTime;
  final int commentsNum;

  const PostModel({
    required this.userName,
    required this.creatorUid,
    required this.profilePhoto,
    required this.dateTime,
    required this.commentsNum,
    this.content,
    this.postImage,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      creatorUid: json['uid'],
      userName: json['userName'],
      profilePhoto: json['profilePhoto'],
      content: json['content'],
      postImage: json['postImage'],
      dateTime: json['dateTime'].toDate(),
      commentsNum: json['commentsNum'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': creatorUid,
      'userName': userName,
      'profilePhoto': profilePhoto,
      'content': content,
      'postImage': postImage,
      'commentsNum': commentsNum,
      kCreatedAt: Timestamp.fromDate(dateTime),
    };
  }

  @override
  List<Object?> get props => [
        userName,
        creatorUid,
        profilePhoto,
        dateTime,
        commentsNum,
        content,
        postImage,
      ];
}
