import 'dart:developer';

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/layout/home/components/custom_bottom_nav_bar.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/components/constants.dart';
import 'package:social_media_app/shared/network/local/cache_helper.dart';
import 'package:social_media_app/shared/style/theme/theme.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key}); // Corrected constructor
  static const routeViewName = 'home view';

  @override
  Widget build(BuildContext context) {
    log('Token ::::: ${CacheHelper.getData(key: uidToken)}');
    return Container(
      decoration: themeColor(),
      child: Scaffold(
        body: BlocBuilder<SocialCubit, SocialState>(
          builder: (context, state) {
            if (state is SocialFailureState) {
              return const Center(
                child: Text('Something went wrong'),
              );
            }
            return ConditionalBuilder(
              condition:
                  BlocProvider.of<SocialCubit>(context).userModel != null,
              builder: (context) =>
                  BlocProvider.of<SocialCubit>(context).currentBody[
                      BlocProvider.of<SocialCubit>(context)
                          .currentBottomNavBarIndex],
              fallback: (context) => const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: const Padding(
          padding: EdgeInsets.only(bottom: 10, left: 8, right: 8, top: 3),
          child: CustomBottomNavBat(),
        ),
      ),
    );
  }
}
