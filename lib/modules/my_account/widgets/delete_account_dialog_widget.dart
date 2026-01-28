import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icon_broken/icon_broken.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';

/// A dialog widget to confirm permanent account deletion.
/// All important text and actions are translated from Arabic to English.
class DeleteAccountDialogWidget extends StatelessWidget {
  const DeleteAccountDialogWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(IconBroken.Danger, color: Colors.red),
          SizedBox(width: 10),
          Expanded(
            child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Permanently Delete Account',
                  textAlign: TextAlign.center,
                )),
          ),
        ],
      ),
      content: const Text(
        'Are you sure you want to delete your account? This action will permanently delete all your posts, photos, and messages, and cannot be undone.',
        style: TextStyle(fontSize: 16),
      ),
      actions: [
        TextButton(
          // 'Cancel'
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            Navigator.pop(context); // Close the dialog
            await BlocProvider.of<SocialCubit>(context)
                .deleteUserAccount(); // Call the delete function
          },
          //Confirm Deletion
          child: const Text('Confirm Deletion',
              style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
