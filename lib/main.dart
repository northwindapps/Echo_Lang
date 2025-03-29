import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Speech to Text',
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
  List<Question> questions = [];
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  String _filePath = ''; // File path for the saved recording
  FlutterTts flutterTts = FlutterTts();
  stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  String _recognizedText = "Press the button and start speaking...";
  String _history = "";
  int _qindex = 0;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    loadAndSetQuestions();
    questions.shuffle();
    _initialize();
  }

  Future<void> loadAndSetQuestions() async {
    List<Question> loadedQuestions = await loadQuestions();
    setState(() {
      questions = loadedQuestions;
    });
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

  Future<void> _loadQuestion() async {
    await _startListening(stateInt: 1);
  }

  Future<void> _speak() async {
    String qatext =
        questions.isNotEmpty ? questions[_qindex].question : "Loading...";
    await flutterTts.speak(qatext);
  }

  Future<void> _setSpeechRate() async {
    await flutterTts.setLanguage("fr-FR");
    await flutterTts.setSpeechRate(0.5);
  }

  // Speech to Text Functionality
  Future<void> _startListening({int stateInt = 1}) async {
    if (stateInt == 1) {
      await _setSpeechRate();
      await _speak();
    }
    bool available = await _speechToText.initialize(
      onStatus: (status) {
        // Handle status change here
        print("Speech recognition status: $status");
        if (stateInt != 2 && (status == 'notListening' || status == 'done')) {
          // Wait 500 milliseconds before restarting the listening process
          Future.delayed(Duration(milliseconds: 500), () async {
            // Only restart listening if the status is not 'listening' or 'done'
            await _startListening(stateInt: 0);
          });
        }
      },
      onError: (error) {
        // Handle errors here
        print("Speech recognition error: ${error.errorMsg}");
      },
    );

    if (available) {
      setState(() {
        _isListening = true;
      });

      // Set the language (example for French)
      _speechToText.listen(
        onResult: (result) {
          // print(result.recognizedWords);
          setState(() {
            if (stateInt == 0) {
              _recognizedText += result.recognizedWords;
              _history += result.recognizedWords;
              //check here
            }
          });
        },
        listenFor: Duration(seconds: 20), // Increase duration
        pauseFor: Duration(seconds: 5), // Allow longer pauses
        localeId: "fr_FR", //it_IT,de_DE,fr_FR,es_ES,ja_JP
      );
    } else {
      print("Speech recognition not available");
    }
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
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
      appBar: AppBar(title: Text('Flutter Speech to Text')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // ElevatedButton(
            //   onPressed: _startRecording,
            //   child: Text('Start Recording'),
            // ),
            // SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: _stopRecording,
            //   child: Text('Stop Recording'),
            // ),
            // SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: _playRecording,
            //   child: Text('Play Recording'),
            // ),
            // SizedBox(height: 40),
            ElevatedButton(onPressed: _loadQuestion, child: Text('Question')),
            SizedBox(height: 40),
            Text(
              _recognizedText,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isListening ? _stopListening : _startListening,
              child: Text(_isListening ? 'Stop Listening' : 'Start Listening'),
            ),
          ],
        ),
      ),
    );
  }
}

// Model class for the Question
class Question {
  final String question;
  final String answer;
  final String language;

  Question({
    required this.question,
    required this.answer,
    required this.language,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'],
      answer: json['answer'],
      language: json['language'],
    );
  }
}

// Function to load JSON
Future<List<Question>> loadQuestions() async {
  String jsonString = await rootBundle.loadString('assets/data_fr.json');
  List<dynamic> jsonData = json.decode(jsonString);
  return jsonData.map((item) => Question.fromJson(item)).toList();
}
