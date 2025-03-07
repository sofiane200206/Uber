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
  Map<String, dynamic>? _userProfile;

  @override
  void initState() {
    super.initState();
    supabase.auth.onAuthStateChange.listen((data) {
      setState(() {
        if (data.session != null) {
          _userProfile = {
            'name': data.session?.user.userMetadata?['full_name'] ?? 'No Name',
            'email': data.session?.user.email ?? 'No Email',
            'picture': data.session?.user.userMetadata?['avatar_url'] ??
                'https://example.com/default-avatar.png',
          };
        } else {
          _userProfile = null;
        }
      });
    });
  }

  Future<void> _signInWithGoogle() async {
    const webClientId =
        '701990745010-67mk6fmt0akb87p3c5jh3orbu2oodfoo.apps.googleusercontent.com';

    final GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId: webClientId,
    );

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return;

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null || accessToken == null) {
      throw 'Google sign-in failed.';
    }

    await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    final user = supabase.auth.currentUser;
    if (user != null && user.email != null) {
      final List<Map<String, dynamic>> response = await supabase
          .from('users')
          .select()
          .eq('email', user.email!)
          .limit(1);

      if (response.isEmpty) {
        await supabase.from('users').insert({
          'id': user.id,
          'email': user.email!,
          'name': user.userMetadata?['full_name'] ?? 'No Name',
          'avatar_url': user.userMetadata?['avatar_url'] ??
              'https://example.com/default-avatar.png',
        });
      }
    }

    setState(() {
      _userProfile = {
        'name': googleUser.displayName ?? 'No Name',
        'email': googleUser.email,
        'picture': googleUser.photoUrl ??
            'https://example.com/default-avatar.png',
      };
    });
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_userProfile != null) ...[
              CircleAvatar(
                backgroundImage: NetworkImage(_userProfile!['picture']),
                radius: 50,
              ),
              const SizedBox(height: 20),
              Text(
                'Name: ${_userProfile!['name']}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'Email: ${_userProfile!['email']}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              
            ] else ...[
              const Text('Not signed in', style: TextStyle(fontSize: 20)),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signInWithGoogle,
              child: const Text('SIGN IN WITH GOOGLE'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _userProfile != null
                  ? () async {
                      await supabase.auth.signOut();
                      setState(() {
                        _userProfile = null;
                      });
                    }
                  : null,
              child: const Text('LOG OUT'),
            ),
          ],
        ),
      ),
    );
  }
}
