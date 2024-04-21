import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vakum/screen/automatic.dart';
import 'package:vakum/screen/voice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late MqttServerClient client;

  @override
  void initState() {
    super.initState();
    connectToBroker();
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

  void onConnected() {
    print('Connected to MQTT broker');
  }

  // Fungsi yang dipanggil saat koneksi terputus
  void onDisconnected() {
    print('Disconnected from MQTT broker');
  }

  // Fungsi untuk mengirim data ke broker MQTT
  void sendDataToRaspberryPi() {
    // Pastikan klien MQTT terhubung ke broker
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      final message = 'true'; // Data yang ingin dikirim
      final topic =
          'vakum/control'; // Topik yang digunakan untuk mengirim pesan

      final builder = MqttClientPayloadBuilder();
      builder.addString(message); // Tambahkan pesan ke builder

      // Kirim pesan ke topik
      client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
      
      print('Pesan terkirim: $message ke topik: $topic');
    } else {
      print('Gagal mengirim pesan: Tidak terhubung ke broker MQTT');
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
              return Center(
                  child:
                      CircularProgressIndicator()); // Menampilkan loading indicator jika data sedang diambil
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
                        sendDataToRaspberryPi();
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

  @override
  void dispose() {
    // Lepaskan koneksi MQTT saat widget dihapus
    client.disconnect();
    super.dispose();
  }
}
