import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:icon_broken/icon_broken.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/modules/chat/chat_body.dart';
import 'package:social_media_app/modules/feeds/feeds_body.dart';
import 'package:social_media_app/modules/new_post/new_post.dart';
import 'package:social_media_app/modules/notifications/notifications_body.dart';
import 'package:social_media_app/modules/users/users_body.dart';
import 'package:social_media_app/shared/components/constants.dart';
import 'package:social_media_app/shared/network/local/cache_helper.dart';

part 'social_state.dart';

class SocialCubit extends Cubit<SocialState> {
  SocialCubit() : super(SocialInitial());
  
  String uidTokenCache = CacheHelper.getData(key: uidToken);

  //? social bodies navigation
  int currentBottomNavBarIndex = 0;

  void changeBottomNavBar(int value) {
    currentBottomNavBarIndex = value;
    emit(BottomNavBarState());
  }

  final List<Widget> currentBody = const [
    FeedsBody(),
    ChatBody(),
    PostNewFeed(),
    UsersBody(),
    NotificationsBody(),
  ];

  final List<BottomNavigationBarItem> bottomNavigationBarItem = const [
    BottomNavigationBarItem(icon: Icon(IconBroken.Home), label: ''),
    BottomNavigationBarItem(
        icon: Padding(
            padding: EdgeInsets.only(right: 10), child: Icon(IconBroken.Chat)),
        label: ''),
    BottomNavigationBarItem(
        icon: SizedBox(
          width: 35,
        ),
        label: ''),
    BottomNavigationBarItem(icon: Icon(IconBroken.Profile), label: ''),
    BottomNavigationBarItem(icon: Icon(IconBroken.Notification), label: ''),
  ];

  //? get user info
  UserModel? userModel;

  void getUserData() async {
    emit(SocialLoadingState());
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection(usersCollection)
              .doc(uidTokenCache)
              .get();

      userModel = UserModel.fromJson(documentSnapshot.data()!);
      emit(SocialSuccessState());
    } catch (error) {
      emit(SocialFailureState(errMessage: error.toString()));
    }
  }

  Future<File?> profileImagePicked() async {
    emit(ProfileImagePickedLoadingState());

    final ImagePicker picker = ImagePicker();
    XFile? returnImage = await picker.pickImage(source: ImageSource.gallery);

    if (returnImage == null) {
      debugPrint('No image selected');
      emit(ProfileImagePickedFailureState(errMessage: 'No image selected'));
      return null;
    } else {
      emit(ProfileImagePickedSuccessState());
      return File(returnImage.path);
    }
  }

  Future<String?> uploadProfileImage({required File file}) async {
    emit(UploadProfileImageLoadingState());
    String? pictureUrl;
    try {
      final task = await FirebaseStorage.instance
          .ref()
          .child(
              '$usersCollection/profile/${Uri.file(file.path).pathSegments.last}')
          .putFile(file);

      pictureUrl = await task.ref.getDownloadURL();
      emit(UploadProfileImageSuccessState());
      return pictureUrl;
    } on Exception catch (e) {
      emit(UploadProfileImageFailureState(errMessage: e.toString()));
    }
    return pictureUrl;
  }

  Future<String?> pickAndUploadProfileImage() async {
    File? returnedProfileImage = await profileImagePicked();
    if (returnedProfileImage != null) {
      return await uploadProfileImage(file: returnedProfileImage);
    }
    return null;
  }
}
