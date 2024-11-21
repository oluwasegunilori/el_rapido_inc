import 'package:el_rapido_inc/auth/presentation/auth_page_router.dart';
import 'package:el_rapido_inc/auth/presentation/signup/signup_bloc.dart';
import 'package:el_rapido_inc/auth/presentation/signup/signup_event.dart';
import 'package:el_rapido_inc/auth/presentation/signup/signup_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final String? token;

  SignupPage({super.key, this.token});

  @override
  Widget build(BuildContext context) {
    SignupBloc signupBloc = SignupBloc();
    signupBloc.add(UserVerification(token: token));
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text("ElRapido"),
        centerTitle: false,
        titleTextStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            backgroundColor: Theme.of(context).colorScheme.surface),
        backgroundColor: Colors.transparent,
      ),
      body: BlocProvider(
        create: (_) => signupBloc,
        child: BlocListener<SignupBloc, SignupState>(
          listener: (context, state) {
            if (state is SignupSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Signup Successful!')),
              );
            } else if (state is SignupFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: LayoutBuilder(builder: (context, constraints) {
                  return Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 500, // Set maximum width for the Card
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 50),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Signup",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              //Firstname
                              TextFormField(
                                controller: firstNameController,
                                decoration: InputDecoration(
                                  labelText: 'First Name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  prefixIcon: const Icon(Icons.person),
                                ),
                                keyboardType: TextInputType.name,
                                validator: (value) {
                                  return validateName(value);
                                },
                              ),
                              const SizedBox(height: 16),
                              //Lastname
                              TextFormField(
                                controller: lastNameController,
                                decoration: InputDecoration(
                                  labelText: 'Last Name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  prefixIcon: const Icon(Icons.person),
                                ),
                                keyboardType: TextInputType.name,
                                validator: (value) {
                                  return validateName(value);
                                },
                              ),
                              const SizedBox(height: 16),

                              // Email Input
                              TextFormField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  prefixIcon: const Icon(Icons.email),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  return validateEmail(value);
                                },
                              ),
                              const SizedBox(height: 16),
                              // Password Input
                              TextFormField(
                                controller: passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  prefixIcon: const Icon(Icons.lock),
                                ),
                                obscureText: true,
                                validator: (value) {
                                  return validatePassword(value);
                                },
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    final email = emailController.text;
                                    final password = passwordController.text;
                                    final firstName = firstNameController.text;
                                    final lastName = lastNameController.text;

                                    // Trigger Firebase Signup
                                    BlocProvider.of<SignupBloc>(context).add(
                                      SignupButtonPressed(
                                          email, password, firstName, lastName),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 50, vertical: 15),
                                ),
                                child: const Text(
                                  "Signup",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Divider(),
                              // Google Sign-In Button
                              ElevatedButton.icon(
                                onPressed: () {
                                  BlocProvider.of<SignupBloc>(context)
                                      .add(GoogleSignInPressed());
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                                icon: const Icon(Icons.auto_fix_high),
                                label: const Text(
                                  "Sign in with Google",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Divider(),
                              routeWidget(
                                  text: "Login",
                                  route: "/login",
                                  context: context),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    } else if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a valid anme';
    } else if (!RegExp(r"^[a-zA-Z]+([ '-][a-zA-Z]+)*$").hasMatch(value)) {
      return 'Enter a valid name';
    }
    return null;
  }
}
