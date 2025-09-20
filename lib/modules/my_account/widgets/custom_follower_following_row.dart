import 'package:flutter/material.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/modules/feeds/widgets/users_suggestion_sheet.dart';
import '../../../shared/components/custom_vertical_divider.dart';
import 'custom_number_with_title_column.dart';

class CustomPostFollowersFollowingRow extends StatelessWidget {
  const CustomPostFollowersFollowingRow({
    super.key,
    required this.numOfPosts,
    required this.numOfFollowers,
    required this.numOfFollowing,
    required this.following,
    required this.followers,
  });
  final String numOfPosts;
  final String numOfFollowers;
  final String numOfFollowing;
  final List<UserModel> following, followers;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomNumberWithTitleColumn(
          number: numOfPosts,
          title: 'Post',
        ),
        const CustomVerticalDivider(),
        CustomNumberWithTitleColumn(
          number: numOfFollowers,
          title: 'Followers',
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return FractionallySizedBox(
                  heightFactor:
                      1.0, // This makes the bottom sheet take the full height
                  child: UsersSuggestionsSheet(
                    userModelList: followers,
                  ),
                );
              },
            );
          },
        ),
        const CustomVerticalDivider(),
        CustomNumberWithTitleColumn(
          number: numOfFollowing,
          title: 'Following',
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return FractionallySizedBox(
                  heightFactor:
                      1.0, // This makes the bottom sheet take the full height
                  child: UsersSuggestionsSheet(
                    userModelList: following,
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
