import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double paddingValue = screenHeight * 0.02;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: ListView(
        padding: EdgeInsets.all(paddingValue),
        children: [
          SizedBox(height: paddingValue * 12),
          const Align(
            alignment: Alignment.center,
            child: Text(
              "Stashify",
              style: TextStyle(
                fontSize: 55,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: paddingValue * 12),
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Text(
                "Get Started With Stashify",
                style: TextStyle(
                    fontSize: 32,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: paddingValue * 4),
          ElevatedButton.icon(
            onPressed: () async {
              await _handleGoogleSignIn(context);
            },
            icon: Image.asset('assets/Glogo.png', height: 30, width: 30),
            label: const Text("Login with Google"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            ),
          ),
          SizedBox(height: paddingValue * 8),
          const Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                "By logging in the app, you agree with our terms and conditions",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.grey,
                  decorationThickness: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
        Fluttertoast.showToast(
          msg: "Google Sign In Successful",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );

        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Fluttertoast.showToast(
          msg: "Google Sign In Canceled",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (error) {
      Fluttertoast.showToast(
        msg: "Error during Google Sign In",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
}
