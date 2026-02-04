import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/firebase_options.dart';
import 'package:social_media_app/layout/home/home_view.dart';
import 'package:social_media_app/modules/chat/chat_view.dart';
import 'package:social_media_app/modules/edit_profile/edit_profile_view.dart';
import 'package:social_media_app/modules/login/login_view.dart';
import 'package:social_media_app/modules/on_boarding/on_boarding_view.dart';
import 'package:social_media_app/modules/register/register_view.dart';
import 'package:social_media_app/modules/user/user_view.dart';
import 'package:social_media_app/shared/bloc/app_cubit/app_cubit.dart';
import 'package:social_media_app/shared/bloc/bloc_observer.dart';
import 'package:social_media_app/shared/bloc/chat_cubit/chat_cubit.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/network/local/cache_helper.dart';
import 'package:social_media_app/shared/components/constants.dart';
import 'package:social_media_app/shared/style/theme/theme.dart';
import 'package:social_media_app/shared/services/notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = MyBlocObserver();
  await CacheHelper.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.configureFCM();

  // Save FCM token if user is already logged in
  if (FirebaseAuth.instance.currentUser != null) {
    await notificationService.saveFCMToken();
  }

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
          create: (context) => SocialCubit()
            ..getUserData(
                userUid: tokenCache ?? FirebaseAuth.instance.currentUser!.uid)
            ..getMyUserPosts(
                tokenCache ?? FirebaseAuth.instance.currentUser!.uid)
            ..getTimelinePosts()
            ..getFollowers()
            ..getFollowing(),
        ),
        BlocProvider(
          create: (context) => ChatCubit()..getChats(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
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
          ChatView.routeName: (context) => const ChatView(),
          UserView.routName: (context) => const UserView(),
          // Note: PostView is not included in the routes table because it requires arguments to be passed to its constructor.
          // To navigate to PostView, use Navigator.push and provide the required  to the PostView constructor.attributes
        },
      ),
    );
  }
}
