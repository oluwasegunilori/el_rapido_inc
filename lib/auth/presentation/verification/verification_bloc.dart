import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_rapido_inc/auth/presentation/verification/verification_event.dart';
import 'package:el_rapido_inc/auth/presentation/verification/verification_state.dart';
import 'package:el_rapido_inc/core/data/model/user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repository/user_sessions_manager.dart';

class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final UserSessionManager _userSessionManager = UserSessionManagerImpl();


  VerificationBloc() : super(VerificationInitial()) {
    on<VerifyTokenEvent>(_onVerifyToken);
  }

  Future<void> _onVerifyToken(
    VerifyTokenEvent event,
    Emitter<VerificationState> emit,
  ) async {
    emit(VerificationLoading());

    try {
      final userDoc = await firestore.collection('users').doc(event.token).get();

      if (!userDoc.exists) {
        emit(const VerificationError("Token not found."));
        return;
      }

      final data = userDoc.data();
      final bool activated = data?['activated'] ?? false;
      final Timestamp? verificationSentDate = data?['verificationSentDate'];

      if (activated) {
        emit(const VerificationError("User already activated."));
        return;
      }

      if (verificationSentDate == null) {
        emit(const VerificationError("Invalid token data."));
        return;
      }

      final DateTime createdTime = verificationSentDate.toDate();
      final DateTime now = DateTime.now();

      if (now.difference(createdTime).inMinutes > 30) {
        emit(const VerificationError("Token expired.\nPlease login again"));
        return;
      }

      // Update the user document to set `activated` to true
      await firestore.collection('users').doc(event.token).update({
        'activated': true,
      });
      if(data != null) {
        _userSessionManager.saveUserLoginSessionWithUser(
            User.fromFirestore(data));
      }
      emit(VerificationSuccess());
    } catch (e) {
      emit(VerificationError("An error occurred: $e"));
    }
  }
}
