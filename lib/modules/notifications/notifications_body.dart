import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/rendering.dart';
import 'package:social_media_app/models/notification_model.dart';
import 'package:social_media_app/modules/chat/chat_view.dart';
import 'package:social_media_app/modules/notifications/widgets/notification_item.dart';
import 'package:social_media_app/modules/post/post_view.dart';
import 'package:social_media_app/modules/user/user_view.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/components/constants.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';

class NotificationsBody extends StatefulWidget {
  const NotificationsBody({super.key});

  @override
  State<NotificationsBody> createState() => _NotificationsBodyState();
}

class _NotificationsBodyState extends State<NotificationsBody> {
  final ScrollController _scrollController = ScrollController();
  double _bodiesBottomPadding = 36;
  late final Stream<QuerySnapshot> _notificationsStream;

  @override
  void initState() {
    super.initState();

    // Initialize the stream once in initState to prevent resets during build/setState
    final cubit = BlocProvider.of<SocialCubit>(context);
    final myUid = cubit.userModel?.uid ?? cubit.currentUserUid;

    _notificationsStream = FirebaseFirestore.instance
        .collection(kUsersCollection)
        .doc(myUid)
        .collection('notifications')
        .orderBy('dateTime', descending: true)
        .snapshots();

    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        bool isTop = _scrollController.position.pixels == 0;
        if (!isTop) {
          setState(() {
            _bodiesBottomPadding = 82;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final socialCubit = BlocProvider.of<SocialCubit>(context);
    final myUid = socialCubit.userModel?.uid;

    if (myUid == null) {
      // In case userModel is not yet loaded? Usually it is by the time we reach here.
      return const Center(
          child: CircularProgressIndicator(
        color: Colors.white,
      ));
    }

    return SafeArea(
      bottom: false,
      child: NotificationListener<ScrollNotification>(
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
        child: Padding(
          padding: EdgeInsets.only(top: 10, bottom: _bodiesBottomPadding),
          child: StreamBuilder<QuerySnapshot>(
            stream: _notificationsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.white));
              }

              if (snapshot.hasError) {
                return Center(
                    child: Text(
                  'Error: ${snapshot.error}',
                  style: FontsStyle.font16Poppins(color: Colors.white),
                ));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    'No notifications yet',
                    style: FontsStyle.font16Poppins(color: Colors.white),
                  ),
                );
              }

              var notifications = snapshot.data!.docs
                  .map((doc) {
                    return NotificationModel.fromJson(
                        doc.data() as Map<String, dynamic>);
                  })
                  .where((notification) => notification.type != 'message')
                  .toList();

              return ListView.builder(
                controller: _scrollController,
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final model = notifications[index];
                  return FadeInRight(
                    duration: Duration(milliseconds: 100 * index),
                    child: NotificationItem(
                      model: model,
                      onTap: () =>
                          _handleNotificationTap(context, model, socialCubit),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _handleNotificationTap(
      BuildContext context, NotificationModel model, SocialCubit cubit) async {
    // Show loading
    showDialog(
      context: context,
      builder: (c) => const Center(
          child: CircularProgressIndicator(
        color: Colors.white,
      )),
      barrierDismissible: false,
    );

    try {
      // Mark as read in Firestore
      await FirebaseFirestore.instance
          .collection(kUsersCollection)
          .doc(cubit.currentUserUid)
          .collection('notifications')
          .doc(model.notificationId)
          .update({'isRead': true});

      if (model.type == 'message') {
        // Navigate to ChatView
        // We need the UserModel of the sender
        final userModel = await cubit.getUserData(userUid: model.senderUid);
        if (context.mounted) Navigator.pop(context); // Close loading
        if (userModel != null && context.mounted) {
          Navigator.pushNamed(context, ChatView.routeName,
              arguments: userModel);
        } else {
          // debugPrint("User not found");
        }
      } else if (model.type == 'like' || model.type == 'comment') {
        // Navigate to PostView
        // We need PostModel
        if (model.postId != null) {
          final postModel = await cubit.getPostById(model.postId!);
          if (context.mounted) Navigator.pop(context); // Close loading
          if (postModel != null && context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostView(
                  postModel: postModel,
                  postId: model.postId!,
                ),
              ),
            );
          } else {
            // debugPrint("Post not found");
          }
        } else {
          if (context.mounted) Navigator.pop(context); // Close loading
        }
      } else if (model.type == 'follow') {
        // Navigate to UserView
        final userModel = await cubit.getUserData(userUid: model.senderUid);
        if (context.mounted) Navigator.pop(context); // Close loading
        if (userModel != null && context.mounted) {
          Navigator.pushNamed(context, UserView.routName, arguments: userModel);
        }
      } else {
        if (context.mounted) Navigator.pop(context); // Close loading
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context); // Close loading
      // debugPrint("Error handling notification tap: $e");
    }
  }
}
