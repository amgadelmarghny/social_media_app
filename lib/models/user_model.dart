import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String fcmToken;
  final String firstName;
  final String lastName;
  final String email;
  final String userName;
  final String dateAndMonth;
  final String year;
  final String gender;
  final String? photo;
  final String? cover;
  final String? bio;

  const UserModel({
    required this.uid,
    required this.fcmToken,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.userName,
    required this.dateAndMonth,
    required this.year,
    required this.gender,
    this.photo,
    this.cover,
    this.bio,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      dateAndMonth: json['dateAndMonth'],
      year: json['year'],
      userName: json['userName'],
      gender: json['gender'],
      photo: json['photo'],
      cover: json['cover'],
      bio: json['bio'],
      fcmToken: json['fcmToken'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fcmToken': fcmToken,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'dateAndMonth': dateAndMonth,
      'year': year,
      'userName': userName,
      'gender': gender,
      'photo': photo,
      'cover': cover,
      'bio': bio,
    };
  }

  @override
  List<Object?> get props => [
        uid,
        fcmToken,
        firstName,
        lastName,
        email,
        userName,
        dateAndMonth,
        year,
        gender,
        photo,
        cover,
        bio,
      ];
}
