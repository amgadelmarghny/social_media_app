class LikeUserModel {
  final String? profilePhoto;
  final String userName;
  final bool like;

  LikeUserModel({
    required this.profilePhoto,
    required this.userName,
    required this.like,
  });

  factory LikeUserModel.fromJson(Map<String, dynamic> json) {
    return LikeUserModel(
      profilePhoto: json['profilePhoto'],
      userName: json['userName'],
      like: json['like'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'like': like,
      'userName': userName,
      'profilePhoto': profilePhoto,
    };
  }
}
