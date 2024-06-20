import 'package:flutter/material.dart';
import '../../../shared/components/custom_vertical_divider.dart';
import 'custom_number_with_title_column.dart';

class CustomPostFollowersFollowingRow extends StatelessWidget {
  const CustomPostFollowersFollowingRow({
    super.key,
    required this.numOfPosts,
    required this.numOfFollowers,
    required this.numOfFollowing,
  });
  final String numOfPosts;
  final String numOfFollowers;
  final String numOfFollowing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomNumberWithTitleColumn(
          number: numOfPosts,
          title: 'Post',
          onTap: () {},
        ),
        const CustomVerticalDivider(),
        CustomNumberWithTitleColumn(
          number: numOfFollowers,
          title: 'Followers',
          onTap: () {},
        ),
        const CustomVerticalDivider(),
        CustomNumberWithTitleColumn(
          number: numOfFollowing,
          title: 'Following',
          onTap: () {},
        ),
      ],
    );
  }
}
