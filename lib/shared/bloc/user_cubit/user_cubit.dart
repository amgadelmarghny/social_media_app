import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/models/post_model.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/shared/components/constants.dart';

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
      followings.clear();

      // For each following, fetch the user data and add to the list.
      for (var doc in snapshot.docs) {
        final userModel = await _userCollection.doc(doc.id).get();
        followings.add(UserModel.fromJson(userModel.data()!));
      }
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
    emit(GetUserFollowingLoadingState());
    try {
      // Get the followers collection for the user.
      final snapshot = await _userCollection
          .doc(userUid)
          .collection(kFollowersCollection)
          .get();

      // Update the number of followers.
      numberOfFollowers = snapshot.docs.length;
      // Clear the current list before adding new data.
      followers.clear();

      // For each follower, fetch the user data and add to the list.
      for (var doc in snapshot.docs) {
        final userModel = await _userCollection.doc(doc.id).get();
        followers.add(UserModel.fromJson(userModel.data()!));
      }
      emit(GetFollowersSuccessState());
    } catch (e) {
      // Emit error state if something goes wrong.
      if (!isClosed) {
        emit(GetUserFollowingErrorState(e.toString()));
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
