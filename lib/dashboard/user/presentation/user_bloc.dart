import 'package:el_rapido_inc/core/data/repository/user_repository.dart';
import 'package:el_rapido_inc/dashboard/user/presentation/user_event.dart';
import 'package:el_rapido_inc/dashboard/user/presentation/user_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;

  UserBloc(this.userRepository) : super(UserInitial()) {
    on<FetchUsers>((event, emit) async {
      emit(UserLoading());
      try {
        await userRepository.fetchUsers().listen((data) {
          emit(UserLoaded(data));
        }).asFuture();
      } catch (e) {
        emit(UserError("Failed to fetch users"));
      }
    });
  }
}
