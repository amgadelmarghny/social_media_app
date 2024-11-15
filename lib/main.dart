import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/firebase_options.dart';
import 'package:social_media_app/layout/home/home_view.dart';
import 'package:social_media_app/modules/edit_profile/edit_profile_view.dart';
import 'package:social_media_app/modules/login/login_view.dart';
import 'package:social_media_app/modules/on_boarding/on_boarding_view.dart';
import 'package:social_media_app/modules/post/post_view.dart';
import 'package:social_media_app/modules/register/register_view.dart';
import 'package:social_media_app/shared/bloc/app_cubit/app_cubit.dart';
import 'package:social_media_app/shared/bloc/bloc_observer.dart';
import 'package:social_media_app/shared/bloc/comments_cubit/comments_cubit.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/network/local/cache_helper.dart';
import 'package:social_media_app/shared/components/constants.dart';
import 'package:social_media_app/shared/style/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = MyBlocObserver();
  await CacheHelper.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SocialMediaApp());
}

class SocialMediaApp extends StatelessWidget {
  const SocialMediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    String? tokenCache = CacheHelper.getData(key: kUidToken);
    bool? onBoardingCache = CacheHelper.getData(key: kOnBoardingConst);
    late String initialRoute;
    if (onBoardingCache != null) {
      if (tokenCache != null) {
        initialRoute = HomeView.routeViewName;
      } else {
        initialRoute = LoginView.routeViewName;
      }
    } else {
      initialRoute = OnBoardingView.routeViewName;
    }
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AppCubit(),
        ),
        BlocProvider(
          create: (context) => CommentsCubit(),
        ),
        BlocProvider(
          create: (context) => SocialCubit()
            ..getPosts()
            ..getUserData(),
        ),
      ],
      child: MaterialApp(
        darkTheme: CustomThemeMode.darkTheme,
        theme: CustomThemeMode.lightTheme,
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        initialRoute: initialRoute,
        routes: {
          OnBoardingView.routeViewName: (context) => const OnBoardingView(),
          LoginView.routeViewName: (context) => const LoginView(),
          RegisterView.routeViewName: (context) => const RegisterView(),
          HomeView.routeViewName: (context) => const HomeView(),
          EditProfileView.routeViewName: (context) => const EditProfileView(),
        },
      ),
    );
  }
}
