import 'dart:js' as js;

import 'package:firebase_auth/firebase_auth.dart';

void initiateGoogleSignIn(Function(String) onTokenReceived) {
  js.context.callMethod('google.accounts.id.initialize', [
    {
      'client_id': '149971017649-2fcme03pvn31usdgrlc2um6hphjb3n22.apps.googleusercontent.com',
      'callback': (response) {
        final token = response['credential']; // Extract the credential token.
        if (token != null) {
          onTokenReceived(token); // Pass the token to the callback.
        } else {
          print('Failed to retrieve the credential token');
        }
      },
    }
  ]);

  // Prompt the Google sign-in button for the user.
  js.context.callMethod('google.accounts.id.prompt');
}


Future<void> signInWithFirebaseCredential(String idToken) async {
  try {
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    print('Firebase User: ${userCredential.user}');
  } catch (e) {
    print('Firebase Sign-In Error: $e');
  }
}