import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tolab/core/cubits/user_repository.dart';
import 'package:tolab/core/cubits/user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository userRepository;

  UserCubit(this.userRepository) : super(UserInitial());

  Future<void> getUser(String uid) async {
    emit(UserLoading());
    try {
      final user = await userRepository.getUserDetails(uid);
      if (user != null) {
        emit(UserLoaded(user));
      } else {
        emit(UserError("not user found"));
      }
    } catch (e) {
      emit(UserError("error upload data user"));
    }
  }

  Future<void> logout() async {
    emit(UserLoggedOut());
  }
}
