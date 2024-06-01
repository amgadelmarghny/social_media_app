import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitial());

  UserCredential? userCredential;

  void userRegister({required String email, required String password}) async {
    emit(RegisterLoadingState());
    try {
      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      emit(RegisterLoadingState());
    } on Exception catch (error) {
      emit(RegisterFailureState(errMessage: error.toString()));
    }
  }
}
