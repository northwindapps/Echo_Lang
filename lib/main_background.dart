import 'dart:io';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

FlutterSoundRecorder? _recorder;
String _filePath = "";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _requestPermissions();

  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // This will be executed when the app is in the foreground or background in a separate isolate
      onStart: onBackgroundServiceStart,

      // Auto start the service when the app launches
      autoStart: true,
      isForegroundMode: true,

      // Notification details for the foreground service
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'AWESOME SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
      foregroundServiceTypes: [
        AndroidForegroundType.location,
      ], // You can add other types like data sync, etc.
    ),
    iosConfiguration: IosConfiguration(
      // Auto start service when the app launches
      autoStart: true,

      // These will be executed when the app is in the foreground (separate isolate)
      onForeground: onBackgroundServiceStart,

      // onBackground should handle tasks when the app is in the background.
      onBackground: null,

      // Remember to enable background fetch capability in the Xcode project
    ),
  );

  runApp(MyApp());
}

// Request permissions for recording
Future<void> _requestPermissions() async {
  await Permission.microphone.request();
  await Permission.storage.request();
}

// Get a path to store the recorded file
Future<String> _getFilePath() async {
  final dir = await getApplicationDocumentsDirectory();
  return '${dir.path}/recording.aac';
}

// Start recording in the background
void onBackgroundServiceStart(ServiceInstance service) async {
  _recorder = FlutterSoundRecorder();
  await _recorder!.openRecorder();

  String filePath = await _getFilePath();
  _filePath = filePath;

  // Start recording
  await _recorder!.startRecorder(toFile: filePath);
  print("Recording started in background at $filePath");

  // Simulate continuous recording
  while (true) {
    await Future.delayed(Duration(seconds: 10)); // Check every 10 seconds
  }
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
  FlutterSoundPlayer? _player;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player = FlutterSoundPlayer();
    _player!.openPlayer();
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
      appBar: AppBar(title: Text('Record & Playback in Background')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
