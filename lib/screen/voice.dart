import 'package:flutter/material.dart';
import 'package:speech_to_text_google_dialog/speech_to_text_google_dialog.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Voice extends StatefulWidget {
  const Voice({Key? key}) : super(key: key);

  @override
  _VoiceState createState() => _VoiceState();
}

class _VoiceState extends State<Voice> {
  String? result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFF222831), // Warna latar belakang yang diinginkan
        ),
        padding: EdgeInsets.symmetric(vertical: 50.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "VOICE MANUAL",
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 54.0),
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('alat')
                    .doc('NuXrx2FvKAsUY9oj43Kz')
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
                  final status = data['status'];
                  final nama = '${data['nama']} ${status ? 'On' : 'Off'}';

                  // Menggunakan kondisional untuk menampilkan Lottie.asset sesuai dengan status
                  final lottieAsset =
                      status ? 'assets/img/on.json' : 'assets/img/off.json';
                  return Row(
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
                  );
                },
              ),
              SizedBox(height: 35.0),
              Text(
                "Ketuk Untuk Memulai Robot Vacum",
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  bool isServiceAvailable =
                      await SpeechToTextGoogleDialog.getInstance()
                          .showGoogleDialog(
                    onTextReceived: (data) {
                      setState(() {
                        result = data.toString();
                      });
                    },
                    // locale: "en-US",
                  );
                  if (!isServiceAvailable) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Service is not available'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.height - 100,
                        left: 16,
                        right: 16,
                      ),
                    ));
                  }
                },
                child: Transform.translate(
                  offset: Offset(0, 0),
                  child: Lottie.asset(
                    'assets/img/audio.json',
                    width: 450,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Center(
                child: Text(
                  'result = ${result ?? ''}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
