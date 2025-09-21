import 'package:equatable/equatable.dart';

class UserRegisterImpl extends Equatable {
  final String firstName;
  final String lastName;
  final String email;
  final String userName;
  final String password;
  final String dateAndMonth;
  final String year;
  final String gender;

  const UserRegisterImpl(
      {required this.firstName,
      required this.lastName,
      required this.email,
      required this.userName,
      required this.dateAndMonth,
      required this.year,
      required this.gender,
      required this.password});

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'dateAndMonth': dateAndMonth,
      'year': year,
      'userName': userName,
      'gender': gender,
      'password': gender
    };
  }

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        email,
        userName,
        dateAndMonth,
        year,
        gender,
        password
      ];
}
