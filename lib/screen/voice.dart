import 'package:flutter/material.dart';
import 'package:speech_to_text_google_dialog/speech_to_text_google_dialog.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class Voice extends StatefulWidget {
  const Voice({Key? key}) : super(key: key);

  @override
  _VoiceState createState() => _VoiceState();
}

class _VoiceState extends State<Voice> {
  String? result;
  late MqttServerClient client;

  @override
  void initState() {
    super.initState();
    connectToBroker(); // Inisialisasi koneksi ke broker MQTT
  }

  // Menghubungkan ke broker MQTT
  void connectToBroker() async {
    // Tentukan alamat IP broker MQTT dan ID client Anda
    client = MqttServerClient.withPort(
        '192.168.187.155', // Alamat server MQTT
        'flutter_client', // Identifier klien
        1883 // Nomor port MQTT yang ingin digunakan
        );

    client.keepAlivePeriod = 60; // Periode keep-alive dalam detik
    client.setProtocolV311(); // Setel protokol MQTT ke versi 3.1.1

    // Tambahkan fungsi callback untuk mengatur tindakan saat terhubung atau terputus
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;

    // Hubungkan ke broker MQTT
    try {
      await client.connect();
      print('Connected to MQTT broker');
    } catch (e) {
      print('Failed to connect to MQTT broker: $e');
      print('Client identifier: ${client.clientIdentifier}');
      print('port: ${client.port}');
      client.disconnect(); // Lepaskan koneksi jika terjadi kesalahan
    }
  }

  // Fungsi yang dipanggil saat berhasil terhubung ke broker
  void onConnected() {
    print('Connected to MQTT broker');
  }

  // Fungsi yang dipanggil saat koneksi terputus
  void onDisconnected() {
    print('Disconnected from MQTT broker');
  }

  // Fungsi yang dipanggil saat menerima hasil pengenalan suara
  void onVoiceResult(dynamic data) {
    String resultData = data.toString();
    setState(() {
      result = resultData;
    });
    sendMessageToRaspberryPi(); // Kirim data suara ke Raspberry Pi
  }

  // Fungsi untuk mengirim pesan ke Raspberry Pi melalui MQTT
  void sendMessageToRaspberryPi() {
    // Pastikan client terhubung ke broker sebelum mengirim pesan
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      final message = result ?? ''; // Ambil hasil pengenalan suara
      final topic = 'test/topic'; // Topik yang digunakan untuk mengirim pesan

      // Buat builder payload
      final builder = MqttClientPayloadBuilder();
      builder.addString(message); // Tambahkan pesan ke builder

      // Kirim pesan ke topik yang ditentukan
      client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
      print('Sent message: $message to topic: $topic');
    } else {
      print('Failed to send message: Not connected to MQTT broker');
    }
  }

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
                  final status = data['status'];
                  final cleaning = data['cleaning'];
                  final nama =
                      '${data['nama']} ${cleaning ? 'On Progress' : 'On'}';

                  // Menggunakan kondisi untuk menampilkan Lottie.asset sesuai dengan status
                  final lottieAsset = status
                      ? (cleaning
                          ? 'assets/img/progress.json'
                          : 'assets/img/on.json')
                      : 'assets/img/off.json';
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
                  // Memulai pengenalan suara saat pengguna mengetuk
                  bool isServiceAvailable =
                      await SpeechToTextGoogleDialog.getInstance()
                          .showGoogleDialog(
                    onTextReceived: onVoiceResult,
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

  @override
  void dispose() {
    // Lepaskan koneksi MQTT saat widget dihapus
    client.disconnect();
    super.dispose();
  }
}
