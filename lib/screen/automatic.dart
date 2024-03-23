import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

import 'package:vakum/screen/complete.dart';

class Automatic extends StatefulWidget {
  const Automatic({Key? key});

  @override
  _AutomaticState createState() => _AutomaticState();
}

class _AutomaticState extends State<Automatic> {
  @override
  Widget build(BuildContext context) {
    Timer(
      const Duration(seconds: 6),
      () {
        // Navigasi ke halaman berikutnya setelah splash screen
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 500),
            pageBuilder: (context, animation, secondaryAnimation) =>
                Complete(),
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

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFF222831), // Warna latar belakang yang diinginkan
        ),
        padding: EdgeInsets.symmetric(vertical: 50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "AUTOMATIC",
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 55.0), // Jarak antara teks pertama dan kedua
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Lottie.asset(
                    'assets/img/progress.json',
                    width: 25,
                    height: 25,
                    fit: BoxFit.fill,
                  ),
                ),
                Text(
                  "Vacum 301 On Progress",
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 52.0),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Vacum 301 Sedang Membersihkan",
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: 100,
                ),
                Stack(
                  children: [
                    Transform.translate(
                      offset: Offset(
                          0, 50), // Menggeser widget ke atas sejauh 20 piksel
                      child: Center(
                        child: Lottie.asset(
                          'assets/img/vacum.json',
                          width: 200,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(
                          0, -50), // Menggeser widget ke atas sejauh 20 piksel
                      child: Center(
                        child: Lottie.asset(
                          'assets/img/load.json',
                          width: 350,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ), // Jarak antara animasi dan tombol
          ],
        ),
      ),
    );
  }
}
