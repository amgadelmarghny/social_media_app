import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/models/post_model.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/shared/components/constants.dart';
import 'package:flutter/material.dart';
import '../../../../models/notification_model.dart';

import 'package:social_media_app/shared/services/notification_service.dart';

part 'user_state.dart';

/// Cubit class to manage user-related state, such as following/followers logic.
class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial());

  /// Reference to the users collection in Firestore.
  final _userCollection =
      FirebaseFirestore.instance.collection(kUsersCollection);

  List<PostModel> postsModelList = [];
  List<String> postsIdList = [];

  Future<void> getUserPosts(uid) async {
    emit(GetUserPostsLoading());
    try {
      final postsSnapshot = await FirebaseFirestore.instance
          .collection(kPostsCollection)
          .where('uid', isEqualTo: uid)
          .orderBy(kCreatedAt, descending: true)
          .get();

      postsModelList.clear();
      postsIdList.clear();

      for (var postDoc in postsSnapshot.docs) {
        postsModelList.add(PostModel.fromJson(postDoc.data()));
        postsIdList.add(postDoc.id);
        emit(GetUserPostsSuccess());
      }
    } on Exception catch (e) {
      emit(GetUserPostsFailure(errMessage: e.toString()));
    }
  }

  /// Current follow status (true if the current user is following another user).
  bool isFollowing = false;

  /// Number of users the current user is following.
  int numberOfFollowing = 0;

  /// Number of users following the current user.
  int numberOfFollowers = 0;

  /// List of users the current user is following.
  List<UserModel> followings = [];

  /// List of users following the current user.
  List<UserModel> followers = [];

  /// Fetch the list of users that the given user is following.
  ///
  /// [userUid] - The UID of the user whose followings are to be fetched.
  Future<void> getFollowing(String userUid) async {
    emit(GetUserFollowingLoadingState());
    try {
      // Get the following collection for the user.
      final snapshot = await _userCollection
          .doc(userUid)
          .collection(kFollowingCollection)
          .get();

      // Update the number of followings.
      numberOfFollowing = snapshot.docs.length;
      // Clear the current list before adding new data.
      // Use a temporary list to avoid race conditions
      List<UserModel> tempFollowings = [];
      final seenUids = <String>{};

      // For each following, fetch the user data and add to the list.
      for (var doc in snapshot.docs) {
        // Skip if we've already processed this UID
        if (seenUids.contains(doc.id)) continue;

        final userModel = await _userCollection.doc(doc.id).get();
        if (userModel.exists && userModel.data() != null) {
          tempFollowings.add(UserModel.fromJson(userModel.data()!));
          seenUids.add(doc.id);
        }
      }
      followings = tempFollowings;
      emit(GetUserFollowingSuccessState());
    } catch (e) {
      // Emit error state if something goes wrong.
      if (!isClosed) {
        emit(GetUserFollowingErrorState(e.toString()));
      }
    }
  }

  /// Fetch the list of users that are following the given user.
  ///
  /// [userUid] - The UID of the user whose followers are to be fetched.
  Future<void> getFollowers(String userUid) async {
    emit(GetUserFollowersLoadingState());
    try {
      // Get the followers collection for the user.
      final snapshot = await _userCollection
          .doc(userUid)
          .collection(kFollowersCollection)
          .get();

      // Update the number of followers.
      numberOfFollowers = snapshot.docs.length;
      // Clear the current list before adding new data.
      // Use a temporary list
      List<UserModel> tempFollowers = [];
      final seenUids = <String>{};

      // For each follower, fetch the user data and add to the list.
      for (var doc in snapshot.docs) {
        // Skip if we've already processed this UID
        if (seenUids.contains(doc.id)) continue;

        final userModel = await _userCollection.doc(doc.id).get();
        if (userModel.exists && userModel.data() != null) {
          tempFollowers.add(UserModel.fromJson(userModel.data()!));
          seenUids.add(doc.id);
        }
      }
      followers = tempFollowers;
      emit(GetUserFollowersSuccessState());
    } catch (e) {
      // Emit error state if something goes wrong.
      if (!isClosed) {
        emit(GetUserFollowersFailureState(errMessage: e.toString()));
      }
    }
  }

  /// Check if the current user is following another user.
  ///
  /// [myUid] - The UID of the current user.
  /// [userUid] - The UID of the user to check follow status for.
  Future<void> checkFollowStatus(String myUid, String userUid) async {
    try {
      // Try to get the document representing the follow relationship.
      final doc = await _userCollection
          .doc(myUid)
          .collection(kFollowingCollection)
          .doc(userUid)
          .get();

      // If the document exists, the user is following.
      isFollowing = doc.exists;
      emit(FollowStatusChanged(isFollowing));
    } catch (e) {
      // Emit error state if something goes wrong.
      if (!isClosed) {
        emit(GetUserFollowingErrorState(e.toString()));
      }
    }
  }

  /// Follow another user.
  ///
  /// [myUid] - The UID of the current user.
  /// [userUid] - The UID of the user to follow.
  Future<void> followUser(String myUid, String userUid) async {
    emit(FollowUserLoading());
    try {
      // Add the user to the current user's following collection.
      await _userCollection
          .doc(myUid)
          .collection(kFollowingCollection)
          .doc(userUid)
          .set({'uid': userUid, 'date': DateTime.now()});

      // Add the current user to the other user's followers collection.
      await _userCollection
          .doc(userUid)
          .collection(kFollowersCollection)
          .doc(myUid)
          .set({'uid': myUid, 'date': DateTime.now()});

      // Update follow status and emit state.
      isFollowing = true;

      // Send Notification to the followed user
      // We need sender (current user) info.
      // Since UserCubit doesn't hold 'currentUserModel' directly, we might need to fetch it or rely on SocialCubit.
      // However, we can fetch it briefly using myUid.
      try {
        final myUserDoc = await _userCollection.doc(myUid).get();
        if (myUserDoc.exists) {
          final myUserData = myUserDoc.data();
          if (myUserData != null) {
            final senderName =
                '${myUserData['firstName']} ${myUserData['lastName']}';
            final String? senderPhoto = myUserData['photo'];

            final notificationId =
                DateTime.now().millisecondsSinceEpoch.toString();
            final notification = NotificationModel(
              notificationId: notificationId,
              senderUid: myUid,
              receiverUid: userUid,
              senderName: senderName,
              senderPhoto: senderPhoto,
              type: 'follow',
              content: 'started following you',
              isRead: false,
              dateTime: DateTime.now(),
            );

            await _userCollection
                .doc(userUid)
                .collection('notifications')
                .doc(notificationId)
                .set(notification.toMap());

            // Send Push Notification
            // Calculate target token and send
            // We need the FOLLOWED user's token.

            final followedUserDoc = await _userCollection.doc(userUid).get();
            if (followedUserDoc.exists) {
              final followedUserData = followedUserDoc.data();
              if (followedUserData != null) {
                final String? fToken = followedUserData['fcmToken'];
                if (fToken != null && fToken.isNotEmpty) {
                  await NotificationService().sendNotification(
                    receiverToken: fToken,
                    title: senderName,
                    body: 'started following you',
                  );
                }
              }
            }
          }
        }
      } catch (e) {
        debugPrint("Error sending follow notification: $e");
      }

      emit(FollowStatusChanged(isFollowing));
    } catch (e) {
      // Emit error state if something goes wrong.
      emit(GetUserFollowingErrorState(e.toString()));
    }
  }

  /// Unfollow a user.
  ///
  /// [myUid] - The UID of the current user.
  /// [userUid] - The UID of the user to unfollow.
  Future<void> unfollowUser(String myUid, String userUid) async {
    emit(FollowUserLoading());
    try {
      // Remove the user from the current user's following collection.
      await _userCollection
          .doc(myUid)
          .collection(kFollowingCollection)
          .doc(userUid)
          .delete();

      // Remove the current user from the other user's followers collection.
      await _userCollection
          .doc(userUid)
          .collection(kFollowersCollection)
          .doc(myUid)
          .delete();

      // Update follow status and emit state.
      isFollowing = false;
      emit(FollowStatusChanged(isFollowing));
    } catch (e) {
      // Emit error state if something goes wrong.
      emit(GetUserFollowingErrorState(e.toString()));
    }
  }
}
