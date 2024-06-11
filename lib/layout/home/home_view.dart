import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/layout/home/components/custom_bottom_nav_bar.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/style/theme/theme.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key}); // Corrected constructor
  static const routeViewName = 'home view';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: themeColor(),
      child: BlocBuilder<SocialCubit, SocialState>(
        builder: (context, state) {
          if (state is SocialLoadingState) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          } else if (BlocProvider.of<SocialCubit>(context).userModel != null) {
            return Scaffold(
              bottomNavigationBar: const Padding(
                padding: EdgeInsets.only(bottom: 10,left: 8,right: 8,top: 3),
                child: CustomBottomNavBat(),
              ),
              body: BlocProvider.of<SocialCubit>(context).currentBody[
                  BlocProvider.of<SocialCubit>(context)
                      .currentBottomNavBarIndex],
            );
          }
          return const Center(
            child: Text('Something went wrong'),
          );
        },
      ),
    );
  }
}
