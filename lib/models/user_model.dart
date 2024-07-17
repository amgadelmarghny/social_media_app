class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String dateAndMonth;
  final String year;
  final String gender;
  final String? photo;
  final String? cover;
  final String? bio;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
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
      gender: json['gender'],
      photo: json['photo'],
      cover: json['cover'],
      bio: json['bio'],
    );
  }

  Map<String, dynamic> toMap() {

    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'dateAndMonth': dateAndMonth,
      'year': year,
      'gender': gender,
      'photo': photo,
      'cover': cover,
      'bio': bio,
    };
  }
}
