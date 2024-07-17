import 'package:social_media_app/models/user_model.dart';

class UpdateUserImplModel {
  final String? firstName;
  final String? lastName;
  final String? dateAndMonth;
  final String? year;
  final String? gender;
  final String? photo;
  final String? cover;
  final String? bio;

  UpdateUserImplModel({
    this.firstName,
    this.lastName,
    this.dateAndMonth,
    this.year,
    this.gender,
    this.photo,
    this.cover,
    this.bio,
  });

  Map<Object, Object?> toMap(UserModel userModel) {
    return {
      'firstName': firstName!.isNotEmpty ? firstName : userModel.firstName,
      'lastName': lastName!.isNotEmpty ? lastName : userModel.lastName,
      'dateAndMonth':
          dateAndMonth!.isNotEmpty ? dateAndMonth : userModel.dateAndMonth,
      'year': year ?? userModel.year,
      'gender': gender ?? userModel.gender,
      'photo': photo ?? userModel.photo,
      'cover': cover ?? userModel.cover,
      'bio': bio!.isNotEmpty ? bio : userModel.bio,
    };
  }
}
