import 'package:equatable/equatable.dart';

class OnBoardingModel extends Equatable {
  final String subTitle;

  const OnBoardingModel({
    required this.subTitle,
  });
 
  @override
  List<Object?> get props => [subTitle];
}
