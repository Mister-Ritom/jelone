import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jelone/models/user_model.dart';
import 'package:jelone/pages/main_page.dart';
import 'package:jelone/pages/sign_in_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  //toggle password visibility
  bool _obscureText = true;

  //controlers for name, email and password
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: keyboardHeight >= 64 ? 16 : 200,
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                "assets/Jelone.png",
                height: 100,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RichText(
                text: TextSpan(
                  text: "Welcome to",
                  style: Theme.of(context).textTheme.displayLarge,
                  children: [
                    TextSpan(
                      text: "\nJelone",
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            //Text fields
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  hintText: "Enter your full name",
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  hintText: "Enter your email",
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                obscureText: _obscureText,
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  hintText: "Enter your password",
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),
            ),

            //option to go to sign in page
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SignInPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Already have an account? Sign in",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),

            // Next button in a row that adds children at last
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _signUp,
                    child: const Text("Sign up"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _signUp() async {
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final auth = FirebaseAuth.instance;

    if (!_validate(name, email, password)) return;

    //sign up with firebase auth
    final cred = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final firebaseUser = cred.user;

    if (firebaseUser == null) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to sign up"),
          ),
        );
      }
      return;
    }
    final suffix = email.split("@").first;

    //generate username
    final username = await generateUsername(suffix);

    final userModel = UserModel(
        uid: firebaseUser.uid,
        name: name,
        email: email,
        username: username,
        photoUrl: firebaseUser.photoURL);

    //save user to firestore
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .set(userModel.toJson());
    } catch (e) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to save user"),
          ),
        );
      }
      return;
    }

    if (mounted && context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainPage(),
        ),
      );
    }
  }

  Future<String> generateUsername(String suffix) async {
    var username = suffix;

// Create a reference to the users collection
    final usersRef = FirebaseFirestore.instance.collection('users');

// Query the collection
    final querySnapshot =
        await usersRef.where('username', isEqualTo: username).get();

// If the query returns any documents, the username is taken
    if (querySnapshot.docs.isNotEmpty) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Username is taken"),
          ),
        );
      }
      username = username + Random().nextInt(100).toString();
      return generateUsername(username);
    }
    return username;
  }

  bool _validate(name, email, password) {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      return false;
    }

    // if name is less than 5 characters show snackbar
    if (name.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Name must be at least 5 characters"),
        ),
      );
      return false;
    }

    // if email is not valid show snackbar
    if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email is not valid"),
        ),
      );
      return false;
    }

    // if password is less than 8 characters show snackbar
    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password must be at least 8 characters"),
        ),
      );
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
