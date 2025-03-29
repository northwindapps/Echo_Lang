import 'package:flutter_tts/flutter_tts.dart';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

FlutterSoundRecorder? _recorder;
FlutterSoundPlayer? _player;
String _filePath = ""; // File to save recording

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request permissions and get file path
  await _requestPermissions();
  _filePath = await _getFilePath();

  // Initialize the recorder on the main thread
  _recorder = FlutterSoundRecorder();
  await _recorder!.openRecorder();

  // Start recording in the background thread
  Isolate.spawn(_recordInBackground, _filePath);

  runApp(MyApp());
}

// Request microphone permissions
Future<void> _requestPermissions() async {
  await Permission.microphone.request();
  await Permission.storage.request();
}

// Get a path to store the recorded file
Future<String> _getFilePath() async {
  final dir = await getApplicationDocumentsDirectory();
  return '${dir.path}/recording.aac';
}

// Function to record in an Isolate
void _recordInBackground(String filePath) {
  // Use the recorder that has been initialized in the main isolate
  _recorder!.startRecorder(toFile: filePath);
  print("Recording started in the background");
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FlutterTts flutterTts = FlutterTts();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _setSpeechRate();
    _player = FlutterSoundPlayer();
    _player!.openPlayer();
  }

  Future<void> _setSpeechRate() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speak() async {
    await flutterTts.speak("Hello, welcome to Flutter!");
  }

  void _stopRecording() async {
    await _recorder?.stopRecorder();
    print("Recording stopped and saved to $_filePath");
  }

  void _playRecording() async {
    if (File(_filePath).existsSync()) {
      if (!isPlaying) {
        await _player!.startPlayer(
          fromURI: _filePath,
          whenFinished: () {
            setState(() => isPlaying = false);
          },
        );
        setState(() => isPlaying = true);
      } else {
        await _player!.stopPlayer();
        setState(() => isPlaying = false);
      }
    } else {
      print("No recording found at $_filePath");
    }
  }

  @override
  void dispose() {
    _player!.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Record & Playback Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: _speak, child: Text('Speak Text')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _stopRecording,
              child: Text('Stop Recording'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _playRecording,
              child: Text(isPlaying ? 'Stop Playback' : 'Play Recording'),
            ),
          ],
        ),
      ),
    );
  }
}
