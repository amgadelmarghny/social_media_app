import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/modules/reqister/register_view_body.dart';
import 'package:social_media_app/shared/bloc/register_cubit/register_cubit.dart';
import 'package:social_media_app/shared/style/theme/theme.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});
  static const routeViewName = 'Register View';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(),
      child: Container(
        decoration: themeColor(),
        child: const Scaffold(
          backgroundColor: Colors.transparent,
          body: RegisterViewBody(),
        ),
      ),
    );
  }
}
