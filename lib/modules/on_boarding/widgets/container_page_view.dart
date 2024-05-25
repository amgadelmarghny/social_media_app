import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:social_media_app/modules/on_boarding/widgets/on_boarding_pages.dart';
import 'package:social_media_app/shared/bloc/app_cubit/app_cubit.dart';
import 'package:social_media_app/shared/components/custom_button.dart';
import 'dart:ui' as ui;

class ContainerPageView extends StatelessWidget {
  const ContainerPageView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController();
    return Positioned(
      bottom: -MediaQuery.sizeOf(context).height * 0.85 / 7,
      left: 0,
      right: 0,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.34,
        width: double.infinity,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: const Color(0xffCEA6E7).withOpacity(0.85),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: Radius.circular(50),
          ),
        ),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 9, sigmaY: 9),
          child: Padding(
            padding: const EdgeInsets.only(top: 30, left: 40, right: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SmoothPageIndicator(
                  controller: pageController,
                  count: 3,
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
                    onPageChanged: (value) {
                      BlocProvider.of<AppCubit>(context).currentIndex = value;
                    },
                    itemCount: 3,
                    itemBuilder: (context, index) => OnBoardingPages(
                      onBoardingModel: BlocProvider.of<AppCubit>(context)
                          .onBoardingModels[index],
                    ),
                    controller: pageController,
                  ),
                ),
                CustomButton(
                  text: 'Get Started',
                  onTap: () {},
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
