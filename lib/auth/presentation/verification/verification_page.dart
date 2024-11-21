import 'package:el_rapido_inc/auth/presentation/verification/verification_event.dart';
import 'package:el_rapido_inc/auth/presentation/verification/verification_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'verification_bloc.dart';

class VerificationPage extends StatelessWidget {
  final String? token;

  const VerificationPage({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    if (token != null) {
      context.read<VerificationBloc>().add(VerifyTokenEvent(token!));
    }
    return BlocProvider(
      create: (context) => VerificationBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Token Verification"),
        ),
        body: BlocConsumer<VerificationBloc, VerificationState>(
          listener: (context, state) {
            if (state is VerificationSuccess) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Success"),
                  content: const Text("Token verified successfully!"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            } else if (state is VerificationError) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Error"),
                  content: Text(state.message),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is VerificationLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
