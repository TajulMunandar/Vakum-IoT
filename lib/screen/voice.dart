import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
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
  bool _listening = false;
  bool _isListening = false;
  late MqttServerClient client;
  late SpeechToText _speechToText;
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    connectToBroker(); // Inisialisasi koneksi ke broker MQTT
    _initSpeech(); // Inisialisasi pengenalan suara
  }

  void _initSpeech() async {
    _speechToText = SpeechToText();
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  // Menghubungkan ke broker MQTT
  void connectToBroker() async {
    // Tentukan alamat IP broker MQTT dan ID client Anda
    client = MqttServerClient.withPort(
        '192.168.47.155', // Alamat server MQTT, Harus Berubah Kalau Ip Berubah
        'flutter_client', // Identifier klien
        1883 // Nomor port MQTT yang ingin digunakan
        );

    client.keepAlivePeriod = 60;
    client.setProtocolV311();

    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;

    try {
      await client.connect();
      print('Connected to MQTT broker');
    } catch (e) {
      print('Failed to connect to MQTT broker: $e');
      client.disconnect();
    }
  }

  void onConnected() {
    print('Connected to MQTT broker');
  }

  void onDisconnected() {
    print('Disconnected from MQTT broker');
  }

  void onVoiceResult(SpeechRecognitionResult result) {
    if (result.recognizedWords.isNotEmpty) {
      setState(() {
        _listening = false;
        _isListening = false;
        this.result = result.recognizedWords;
      });

      print('Recognized words: ${result.recognizedWords}');
      sendMessageToRaspberryPiIfNeeded();
    }
  }

  void sendMessageToRaspberryPiIfNeeded() {
    if (this.result != null &&
        (this.result == "maju" ||
            this.result == "mundur" ||
            this.result == "kanan" ||
            this.result == "kiri" ||
            this.result == "berhenti")) {
      if (client.connectionStatus?.state == MqttConnectionState.connected) {
        final message = this.result!;
        final topic = 'test/topic';

        final builder = MqttClientPayloadBuilder();
        builder.addString(message);

        client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
        print('Sent message: $message to topic: $topic');
      } else {
        print('Failed to send message: Not connected to MQTT broker');
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Peringatan'),
          content: Text('Suara tidak dikenali.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void sendMessageToRaspberryPi() {
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      final message = result ?? '';
      final topic = 'test/topic';

      final builder = MqttClientPayloadBuilder();
      builder.addString(message);

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
          color: Color(0xFF222831),
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
                    return CircularProgressIndicator();
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final status = data['status'];
                  final cleaning = data['cleaning'];
                  final nama =
                      '${data['nama']} ${cleaning ? 'On Progress' : 'On'}';

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
                onTap: () {
                  if (_speechEnabled && !_isListening) {
                    setState(() {
                      _isListening = true;
                      _listening =
                          true; // Set _listening true for visual indicator
                    });
                    _speechToText.listen(
                      onResult: (result) => onVoiceResult(result),
                      listenFor:
                          Duration(seconds: 5), // Set timeout duration here
                    );
                  } else {
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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.translate(
                      offset: Offset(0, 0),
                      child: Lottie.asset(
                        'assets/img/audio.json',
                        width: 450,
                        fit: BoxFit.fill,
                      ),
                    ),
                    if (_listening) // Show visual indicator while listening
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                  ],
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
    client.disconnect();
    super.dispose();
  }
}
