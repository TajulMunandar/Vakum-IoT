import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vakum/screen/automatic.dart';
import 'package:vakum/screen/voice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFF222831), // Warna latar belakang yang diinginkan
        ),
        padding: EdgeInsets.symmetric(vertical: 50.0),
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('alat')
              .doc('NuXrx2FvKAsUY9oj43Kz')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator()); // Menampilkan loading indicator jika data sedang diambil
            }

            final status = snapshot.data!.data()!['status'];
            final nama =
                '${snapshot.data!.data()!['nama']} ${status ? 'On' : 'Off'}';

            final lottieAsset =
                status ? 'assets/img/on.json' : 'assets/img/off.json';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "VOICE",
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 55.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Lottie.asset(
                        lottieAsset,
                        width: 25,
                        height: 25,
                        fit: BoxFit.fill,
                      ),
                    ),
                    Text(
                      nama,
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Ketuk Untuk Memulai Cleaning",
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (status) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Voice(), // Ganti HalamanTujuan() dengan halaman tujuan Anda
                            ),
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("Vacuum Tidak Aktif"),
                              content: Text(
                                  "Aktifkan vacuum untuk menggunakan mode suara."),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("OK"),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: Center(
                        child: Transform.translate(
                          offset: Offset(0, 0), // Naik 10 piksel ke atas
                          child: Lottie.asset(
                            'assets/img/audio.json',
                            width: 450,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Transform.translate(
                  offset: Offset(0, 0), // Naik 10 piksel ke atas
                  child: ElevatedButton(
                    onPressed: () {
                      if (status) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Automatic()), // Ganti NextPage() dengan halaman yang ingin Anda tuju
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Vacuum Tidak Aktif"),
                            content: Text(
                                "Aktifkan vacuum untuk menggunakan mode otomatis."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("OK"),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: Text(
                      "AUTOMATIC",
                      style: GoogleFonts.montserrat(
                        color: Color(0xFF222831),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
