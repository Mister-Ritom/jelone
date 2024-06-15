import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Dialogs {
  static Future<void> showLoadingDialog(
      BuildContext context, GlobalKey key) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: true,
          child: SimpleDialog(
            key: key,
            backgroundColor: Colors.black54,
            children: const <Widget>[
              Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Please Wait....",
                      style: TextStyle(color: Colors.blueAccent),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  static void showForgotPasswordDialog(
      BuildContext dialogContext, TextEditingController textController) async {
    return showDialog(
      context: dialogContext,
      //build a dialog with a textfield for email and send reset password link using firebase auth
      builder: (BuildContext context) {
        return Dialog(
            child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: 300,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            child: Column(
              children: <Widget>[
                Text(
                  "Reset password",
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final email = textController.text;
                        final auth = FirebaseAuth.instance;
                        try {
                          await auth.sendPasswordResetEmail(email: email);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Password reset email sent"),
                              ),
                            );
                            Navigator.pop(context);
                          } else {
                            log("Something went wrong while trying to send password reset email");
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("An error occurred"),
                              ),
                            );
                          } else {
                            log("Something went wrong", error: e);
                          }
                        }
                      },
                      child: const Text(
                        'Send Reset Link',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
      },
    );
  }
}
