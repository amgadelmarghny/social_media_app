import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/models/onBoarding/on_boarding_model.dart';
part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppInitial());

  int currentIndex = 0;
  void onBoardingPageChanged(int value) {
    currentIndex = value;
    emit(OnBoardingChangedState());
  }

  List<OnBoardingModel> onBoardingModelsList = [
    OnBoardingModel(
      title: 'Welocme !',
      subTitle: 'Experience a wonderful',
    ),
    OnBoardingModel(
      title: 'Welocme !',
      subTitle: 'Experience a wonderful',
    ),
    OnBoardingModel(
      title: 'Welocme !',
      subTitle: 'Experience a wonderful',
    ),
  ];
}
