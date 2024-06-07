import 'package:bloc/bloc.dart';

part 'social_state.dart';

class SocialCubit extends Cubit<SocialState> {
  SocialCubit() : super(SocialInitial());
}
