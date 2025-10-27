import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/components/show_toast.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';

class VerifyEmailContainer extends StatelessWidget {
  const VerifyEmailContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialState>(
      listener: (context, state) {
        if (state is SendEmailVerificationSuccessState) {
          showToast(msg: state.message, toastState: ToastState.success);
        }
        if (state is CheckEmailErrorState) {
          showToast(msg: state.errMessage, toastState: ToastState.success);
        }
        if (state is SendEmailVerificationFailureState) {
          showToast(msg: state.errMessage, toastState: ToastState.error);
        }
      },
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: defaultColorButton.withValues(alpha: 0.7),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            border: Border.all(color: defaultTextColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text('Please verify your email to continue using the app.',
                  style: FontsStyle.font15Popin()),
              SizedBox(height: 10),
              Text('Click the link in the email to verify your email.',
                  style: FontsStyle.font15Popin()),
              SizedBox(height: 10),
              Text(
                  'If you did not receive an email, click the button below to resend the email.',
                  style: FontsStyle.font15Popin()),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Email: ${BlocProvider.of<SocialCubit>(context).currentUserEmail ?? 'Not available'}',
                        style: FontsStyle.font15Popin()),
                    SizedBox(height: 4),
                    Text(
                        'Verified: ${BlocProvider.of<SocialCubit>(context).userVerification!.emailVerified ? 'Yes' : 'No'}',
                        style: FontsStyle.font15Popin()),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                AbsorbPointer(
                  absorbing: state is SendEmailVerificationLoadingState,
                  child: ElevatedButton(
                    child: const Text('Send email'),
                    onPressed: () async {
                      await BlocProvider.of<SocialCubit>(context)
                          .sendEmailVerification();
                      //  log('${FirebaseAuth.instance.currentUser?.emailVerified}');
                    },
                  ),
                ),
                if (state is SendEmailVerificationSuccessState)
                  SizedBox(
                    width: 10,
                  ),
                if (state is SendEmailVerificationSuccessState)
                  AbsorbPointer(
                    absorbing: state is CheckEmailLoadingState,
                    child: TextButton(
                      onPressed: () async {
                        await BlocProvider.of<SocialCubit>(context)
                            .checkEmailStatus();
                      },
                      child: const Text(
                        'I\'ve Verified My Email',
                        style: TextStyle(
                          color: Colors.deepOrangeAccent,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.deepOrangeAccent,
                        ),
                      ),
                    ),
                  )
              ]),
            ],
          ),
        );
      },
    );
  }
}
