import 'package:el_rapido_inc/auth/presentation/auth_page_router.dart';
import 'package:el_rapido_inc/auth/presentation/verification/verification_event.dart';
import 'package:el_rapido_inc/auth/presentation/verification/verification_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'verification_bloc.dart';

class VerificationPage extends StatelessWidget {
  final String? token;

  const VerificationPage({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    VerificationBloc verificationBloc = VerificationBloc();
    if (token != null) {
      verificationBloc.add(VerifyTokenEvent(token!));
    }
    return BlocProvider(
      create: (context) => verificationBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Email Verification"),
        ),
        body: BlocConsumer<VerificationBloc, VerificationState>(
          listener: (context, state) {
            if (state is VerificationSuccess) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Success"),
                  content: const Text("Email verified successfully!"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        routeNeglect(context, route: "/dashboard");
                      },
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
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.replace("/login");
                      },
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
