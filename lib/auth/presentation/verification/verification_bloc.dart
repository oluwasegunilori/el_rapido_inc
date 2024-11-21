import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_rapido_inc/auth/presentation/verification/verification_event.dart';
import 'package:el_rapido_inc/auth/presentation/verification/verification_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

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
      final Timestamp? dateCreated = data?['dateCreated'];

      if (activated) {
        emit(const VerificationError("User already activated."));
        return;
      }

      if (dateCreated == null) {
        emit(const VerificationError("Invalid token data."));
        return;
      }

      final DateTime createdTime = dateCreated.toDate();
      final DateTime now = DateTime.now();

      if (now.difference(createdTime).inMinutes > 30) {
        emit(const VerificationError("Token expired."));
        return;
      }

      // Update the user document to set `activated` to true
      await firestore.collection('users').doc(event.token).update({
        'activated': true,
      });

      emit(VerificationSuccess());
    } catch (e) {
      emit(VerificationError("An error occurred: $e"));
    }
  }
}
