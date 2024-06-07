import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/models/onBoarding/user_model.dart';
import 'package:social_media_app/shared/components/constants.dart';

part 'social_state.dart';

class SocialCubit extends Cubit<SocialState> {
  SocialCubit(this.uidToken) : super(SocialInitial());
  String uidToken;
  UserModel? userModel;

  void getUserData() async {
    emit(SocialLoadingState());
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection(usersCollection)
              .doc(uidToken)
              .get();

      userModel = UserModel.fromJson(documentSnapshot.data()!);
      print(' ******* ${userModel!.firstName}');
      emit(SocialSuccessState());
    } catch (error) {
      emit(SocialFailureState(errMessage: error.toString()));
    }
  }
}
