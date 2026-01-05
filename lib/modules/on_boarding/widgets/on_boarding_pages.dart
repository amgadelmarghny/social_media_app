import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/models/onBoarding/on_boarding_model.dart';
import 'package:social_media_app/shared/bloc/app_cubit/app_cubit.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';

class OnBoardingPages extends StatelessWidget {
  const OnBoardingPages({
    super.key,
    required this.onBoardingModel,
  });
  final OnBoardingModel onBoardingModel;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              onBoardingModel.subTitle,
              style: FontsStyle.font24Shadow,
            ),
            BlocProvider.of<AppCubit>(context)
                        .onBoardingModelsList
                        .indexOf(onBoardingModel) ==
                    0
                ? Row(
                    children: [
                      Text(
                        'moment with',
                        style: FontsStyle.font24Shadow,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Image.asset(
                        'lib/assets/images/launch_icon_wthout_bg.png',
                        height: 40,
                      ),
                    ],
                  )
                : const SizedBox(),
          ],
        );
      },
    );
  }
}
