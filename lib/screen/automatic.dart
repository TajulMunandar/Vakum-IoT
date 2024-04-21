import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vakum/screen/complete.dart';

class Automatic extends StatefulWidget {
  const Automatic({Key? key});

  @override
  _AutomaticState createState() => _AutomaticState();
}

class _AutomaticState extends State<Automatic> {
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
              .doc('jmmAuqXUzmVy0fF207LW')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Menampilkan loading indicator jika data sedang diambil
            }

            // Menampilkan data jika snapshot sudah ada
            final data = snapshot.data!.data() as Map<String, dynamic>;
            final cleaning = data['cleaning'];

            return Column(
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
                        cleaning
                            ? 'assets/img/progress.json'
                            : 'assets/img/on.json',
                        width: 25,
                        height: 25,
                        fit: BoxFit.fill,
                      ),
                    ),
                    Text(
                      "Vacum 301 ${cleaning ? 'On Progress' : 'On'}",
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
                      "Vacum 301 ${cleaning ? 'Sedang Membersihkan' : 'Idle'}",
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
                          offset: Offset(0,
                              50), // Menggeser widget ke atas sejauh 20 piksel
                          child: Center(
                            child: Lottie.asset(
                              'assets/img/vacum.json',
                              width: 200,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: Offset(0,
                              -50), // Menggeser widget ke atas sejauh 20 piksel
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
                ),
                ElevatedButton(
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection('alat')
                        .doc('jmmAuqXUzmVy0fF207LW')
                        .update({'cleaning': false}).then((_) {
                      // Pindah ke halaman complete.dart setelah pembaruan berhasil
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Complete()),
                      );
                    }).catchError((error) {
                      // Tangani kesalahan jika terjadi
                      print("Failed to update data: $error");
                    });
                  },
                  child: Text('Berhenti'),
                ) // Jarak antara animasi dan tombol
              ],
            );
          },
        ),
      ),
    );
  }
}
