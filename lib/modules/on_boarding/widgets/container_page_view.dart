import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:social_media_app/modules/login/login_view.dart';
import 'package:social_media_app/modules/on_boarding/widgets/on_boarding_pages.dart';
import 'package:social_media_app/shared/bloc/app_cubit/app_cubit.dart';
import 'package:social_media_app/shared/network/local/cache_helper.dart';
import 'package:social_media_app/shared/components/constants.dart';
import 'dart:ui' as ui;

import 'package:social_media_app/shared/components/custom_button.dart';

class CustomContainerPageView extends StatelessWidget {
  const CustomContainerPageView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    AppCubit appCubit = BlocProvider.of<AppCubit>(context);
    PageController pageController = PageController();
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.34,
        width: double.infinity,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: const Color(0xffCEA6E7).withOpacity(0.78),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: Radius.circular(50),
          ),
        ),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 9, sigmaY: 9),
          child: Padding(
            padding: const EdgeInsets.only(top: 30, left: 40, right: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SmoothPageIndicator(
                  controller: pageController,
                  count: appCubit.onBoardingModelsList.length,
                  effect: const WormEffect(
                      dotHeight: 10,
                      dotWidth: 10,
                      dotColor: Colors.white,
                      activeDotColor: Color(0xff8C64D5),
                      spacing: 12),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.18,
                  child: PageView.builder(
                    controller: pageController,
                    onPageChanged: (value) {
                      appCubit.onBoardingPageChanged(value);
                    },
                    itemCount: appCubit.onBoardingModelsList.length,
                    itemBuilder: (context, index) => OnBoardingPages(
                      onBoardingModel: appCubit.onBoardingModelsList[index],
                    ),
                  ),
                ),
                BlocBuilder<AppCubit, AppState>(
                  builder: (context, state) {
                    return CustomButton(
                      text: appCubit.currentIndex ==
                              appCubit.onBoardingModelsList.length - 1
                          ? 'Get Started'
                          : 'Next',
                      onTap: () {
                        if (appCubit.currentIndex ==
                            appCubit.onBoardingModelsList.length - 1) {
                          CacheHelper.setData(
                              key: kOnBoardingConst, value: true);
                          Navigator.pushReplacementNamed(
                              context, LoginView.routeViewName);
                        } else {
                          pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.linear,
                          );
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
