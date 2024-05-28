import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/modules/login/login_view.dart';
import 'package:social_media_app/modules/on_boarding/on_boarding_view.dart';
import 'package:social_media_app/shared/bloc/app_cubit/app_cubit.dart';
import 'package:social_media_app/shared/bloc/bloc_observer.dart';

void main() {
  Bloc.observer = MyBlocObserver();
  runApp(const SocialMediaApp());
}

class SocialMediaApp extends StatelessWidget {
  const SocialMediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: OnBoardingView.routeViewName,
        routes: {
          OnBoardingView.routeViewName: (context) => const OnBoardingView(),
          LoginView.routeViewName: (context) => const LoginView(),
        },
      ),
    );
  }
}
