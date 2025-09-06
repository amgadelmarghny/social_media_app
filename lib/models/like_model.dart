import 'package:equatable/equatable.dart';

class LikeUserModel extends Equatable {
  final String? profilePhoto;
  final String userName;
  final bool like;
  final String userUid;

  const LikeUserModel({
    required this.profilePhoto,
    required this.userName,
    required this.like,
    required this.userUid,
  });

  factory LikeUserModel.fromJson(Map<String, dynamic> json) {
    return LikeUserModel(
        profilePhoto: json['profilePhoto'],
        userName: json['userName'],
        like: json['like'],
        userUid: json['userUid']);
  }

  Map<String, dynamic> toJson() {
    return {
      'like': like,
      'userName': userName,
      'profilePhoto': profilePhoto,
      'userUid': userUid
    };
  }

  @override
  List<Object?> get props => [
        profilePhoto,
        userName,
        like,
        userUid,
      ];
}
