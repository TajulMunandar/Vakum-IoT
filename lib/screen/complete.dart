import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vakum/screen/main_page.dart';

class Complete extends StatefulWidget {
  const Complete({Key? key});

  @override
  _CompleteState createState() => _CompleteState();
}

class _CompleteState extends State<Complete> {
  @override
  Widget build(BuildContext context) {
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
                    'assets/img/on.json',
                    width: 25,
                    height: 25,
                    fit: BoxFit.fill,
                  ),
                ),
                Text(
                  "Vacum 301 On",
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
                  "Ruangan Sudah Di Bersihkan",
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: 100,
                ),
                Transform.translate(
                  offset: Offset(
                      0, -80), // Menggeser widget ke atas sejauh 20 piksel
                  child: Center(
                    child: Lottie.asset(
                      'assets/img/success.json',
                      width: 250,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ],
            ),
            Transform.translate(
              offset: Offset(0, -50), // Sesuaikan pergeseran vertikal
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "3",
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    "Total Sampah Yang Tertinggal",
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Selesai",
                      style: GoogleFonts.montserrat(
                        color: Color(0xFF222831),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ), // Jarak antara animasi dan tombol
          ],
        ),
      ),
    );
  }
}
