import 'dart:developer';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/layout/home/components/custom_bottom_nav_bar.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/components/constants.dart';
import 'package:social_media_app/shared/network/local/cache_helper.dart';
import 'package:social_media_app/shared/style/theme/theme.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  static const routeViewName = 'home view';

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ScrollController _scrollController = ScrollController();
  double _bodiesBottomPadding = 36;
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        bool isTop = _scrollController.position.pixels == 0;

        if (!isTop) {
          // Reached the bottom
          print("^^^^^^^ Reached the end of the SingleChildScrollView ^^^");
          // Perform your actions here
          setState(() {
            _bodiesBottomPadding = 90;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    log('Token ::::: ${CacheHelper.getData(key: uidToken)}');
    return Container(
      decoration: themeColor(),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: _bodiesBottomPadding),
            child: Scaffold(
              body: NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  if (scrollNotification is ScrollUpdateNotification) {
                    if (_scrollController.position.userScrollDirection ==
                        ScrollDirection.forward) {
                      setState(() {
                        _bodiesBottomPadding = 36;
                      });
                    }
                  }
                  return true;
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: BlocBuilder<SocialCubit, SocialState>(
                    builder: (context, state) {
                      if (state is GetUserDataFailureState) {
                        return const Center(
                          child: Text('Something went wrong'),
                        );
                      }
                      return ConditionalBuilder(
                        condition:
                            BlocProvider.of<SocialCubit>(context).userModel !=
                                null,
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
                ),
              ),
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(left: 8, right: 8, bottom: 5),
              child: CustomBottomNavBat(),
            ),
          ),
        ],
      ),
    );
  }
}
