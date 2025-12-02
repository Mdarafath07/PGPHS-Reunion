import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pgphs_reunion/pages/admin_panel.dart';
import 'package:pgphs_reunion/pages/splash_screen.dart'; // ১. এই লাইনটি যোগ করুন

// যদি firebase_options.dart ফাইল থাকে তবে নিচের লাইনটি আনকমেন্ট করুন
// import 'firebase_options.dart';

void main() async { // ২. এখানে async লিখুন
  // ৩. এই দুইটি লাইন যোগ করুন
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // যদি আপনি FlutterFire CLI ব্যবহার করে থাকেন তবে নিচের লাইনটি ব্যবহার করুন:
    // options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PGPHS Reunion',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: const RootPage(),
    );
  }
}

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      onAnimationComplete: () {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const AdminPanel(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = 0.0;
              const end = 1.0;
              const curve = Curves.easeInOut;

              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return FadeTransition(
                opacity: animation.drive(tween),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      },
    );
  }
}