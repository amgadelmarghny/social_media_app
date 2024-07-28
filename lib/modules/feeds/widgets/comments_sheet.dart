import 'package:flutter/widgets.dart';
import 'package:social_media_app/shared/style/theme/theme.dart';

class CommentsSheet extends StatelessWidget {
  const CommentsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: themeColor(),
      padding: const EdgeInsets.only(top: 40),
    );
  }
}
