import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'main_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(
          seconds: 6), // Atur durasi splash screen (3 detik dalam contoh ini)
      () {
        // Navigasi ke halaman berikutnya setelah splash screen
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 500),
            pageBuilder: (context, animation, secondaryAnimation) =>
                MainScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            color: Color(0xFF222831) // Warna latar belakang yang diinginkan
            ),
        child: Center(
          child: SizedBox(
            child: Lottie.asset(
              'assets/img/audio.json',
              width: 300,
              height: 300,
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }
}
