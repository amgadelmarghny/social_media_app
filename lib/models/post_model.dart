class PostModel {
  final String uid;
  final String userName;
  final String profilePhoto;
  final String? content;
  final String? postImage;
  final DateTime dateTime;

  PostModel({
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
      dateTime: json['dateTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'userName': userName,
      'profilePhoto': profilePhoto,
      'content': content,
      'postImage': postImage,
      'dateTime': dateTime.toString(),
    };
  }
}
