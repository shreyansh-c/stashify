import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stashify/login_screen.dart';
import 'package:stashify/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const Stashify());
}

class Stashify extends StatelessWidget {
  const Stashify({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Stashify",
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
