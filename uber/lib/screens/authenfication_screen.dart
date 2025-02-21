import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

final supabase = Supabase.instance.client;

class _AuthPageState extends State<AuthPage> {
  String? _userId;

  @override
  void initState() {
    super.initState();
    
    // Écoute les changements d'état d'authentification
    supabase.auth.onAuthStateChange.listen((data) {
      setState(() {
        _userId = data.session?.user.id;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Ajouté pour centrer
          children: [
            Text(_userId ?? 'Not signed in'), // Affiche l'ID de l'utilisateur ou "Not signed in"
            ElevatedButton(
              onPressed: () async {
                        /// TODO: update the Web client ID with your own.
          ///
          /// Web Client ID that you registered with Google Cloud.
          const webClientId = '701990745010-67mk6fmt0akb87p3c5jh3orbu2oodfoo.apps.googleusercontent.com';

          /// TODO: update the iOS client ID with your own.
          ///
          /// iOS Client ID that you registered with Google Cloud.
          const iosClientId = 'my-ios.apps.googleusercontent.com';

          // Google sign in on Android will work without providing the Android
          // Client ID registered on Google Cloud.

          final GoogleSignIn googleSignIn = GoogleSignIn(
            clientId: iosClientId,
            serverClientId: webClientId,
          );
          print('init google');
          final googleUser = await googleSignIn.signIn();
          print('init google user google: $googleUser');
          final googleAuth = await googleUser!.authentication;
          final accessToken = googleAuth.accessToken;
          final idToken = googleAuth.idToken;

          if (accessToken == null) {
            throw 'No Access Token found.';
          }
          if (idToken == null) {
            throw 'No ID Token found.';
          }

          await supabase.auth.signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: idToken,
            accessToken: accessToken,);
                        // Ajouter la logique pour la connexion ici
                      },
                      child: const Text('SIGN IN WITH GOOGLE'),
            ),
          ],
        ),
      ),
    );
  }
}
