class UserRegisterImpl {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String dateAndMonth;
  final String year;
  final String gender;

  UserRegisterImpl({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.dateAndMonth,
    required this.year,
    required this.gender,
    required this.password
  });

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'dateAndMonth': dateAndMonth,
      'year': year,
      'gender': gender,
      'password' : gender
    };
  }
}
