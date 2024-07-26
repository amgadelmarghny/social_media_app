import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared/components/constants.dart';

class PostModel {
  final String uid;
  final String userName;
  final String? profilePhoto;
  final String? content;
  final String? postImage;
  final DateTime dateTime;
  final List? likes;

  PostModel({
    required this.likes,
    required this.userName,
    required this.uid,
    required this.profilePhoto,
    required this.dateTime,
    this.content,
    this.postImage,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      uid: json['uid'],
      userName: json['userName'],
      profilePhoto: json['profilePhoto'],
      content: json['content'],
      postImage: json['postImage'],
      dateTime: json['dateTime'].toDate(),
      likes: json['likes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'userName': userName,
      'profilePhoto': profilePhoto,
      'content': content,
      'postImage': postImage,
      'likes' : likes,
      kDateTime: Timestamp.fromDate(dateTime),
    };
  }
}
