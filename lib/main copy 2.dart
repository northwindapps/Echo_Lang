import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Audio Recorder',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  String _filePath = ''; // File path for the saved recording
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    _initialize();
  }

  Future<void> _initialize() async {
    // Request permissions for microphone and storage
    await Permission.microphone.request();
    await Permission.storage.request();

    // Get a file path to save the recording
    final dir = await getApplicationDocumentsDirectory();
    _filePath = '${dir.path}/recording.aac';

    // Open the recorder
    await _recorder!.openRecorder();
    // Open the player
    await _player!.openPlayer();
  }

  // Start recording
  Future<void> _startRecording() async {
    await _setSpeechRate();
    await _speak();
    if (await Permission.microphone.request().isGranted) {
      await _recorder!.startRecorder(toFile: _filePath);
      print("Recording started...");
    } else {
      print("Permission denied");
    }
  }

  // Stop recording
  Future<void> _stopRecording() async {
    await _recorder!.stopRecorder();
    print("Recording stopped and saved to $_filePath");
  }

  // Play the recorded file
  Future<void> _playRecording() async {
    if (File(_filePath).existsSync()) {
      await _player!.startPlayer(
        fromURI: _filePath,
        whenFinished: () {
          print("Playback finished");
        },
      );
    } else {
      print("No recording found at $_filePath");
    }
  }

  Future<void> _speak() async {
    await flutterTts.speak("Hello, welcome to Flutter!");
  }

  Future<void> _setSpeechRate() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
  }

  @override
  void dispose() {
    _recorder?.closeRecorder();
    _player?.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Sound Recorder')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _startRecording,
              child: Text('Start Recording'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _stopRecording,
              child: Text('Stop Recording'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _playRecording,
              child: Text('Play Recording'),
            ),
          ],
        ),
      ),
    );
  }
}
