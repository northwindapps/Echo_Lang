import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class HomeScreenPage extends StatefulWidget {
  final String language;

  HomeScreenPage({required this.language});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreenPage> {
  List<Question> questions = [];
  // FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  FlutterTts flutterTts = FlutterTts();
  String _questiontext = "";
  String _answertext = "";
  int _qindex = 0;

  // Language setting
  String _selectedLanguage = "en-US"; // Default to French
  List<String> languages = ["fr-FR", "en-US", "de-DE", "it-IT"];

  @override
  void initState() {
    super.initState();
    // _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    _setLanguage(widget.language); // Set language from the widget
    loadAndSetQuestions();
    _initialize();
    _loadQuestion();
  }

  Future<void> loadAndSetQuestions() async {
    List<Question> loadedQuestions = await loadQuestions(
      _selectedLanguage.toString(),
    );
    loadedQuestions.shuffle();
    setState(() {
      questions = loadedQuestions;
    });
  }

  Future<void> _initialize() async {
    // await Permission.microphone.request();
    // await Permission.storage.request();

    // final dir = await getApplicationDocumentsDirectory();
    // _filePath = '${dir.path}/recording.aac';

    // await _recorder!.openRecorder();
    await _player!.openPlayer();
  }

  Future<void> _setLanguage(String languageCode) async {
    setState(() {
      _selectedLanguage = languageCode;
    });
    // Update FlutterTts and SpeechToText language
    await flutterTts.setLanguage(_selectedLanguage);
    // await _speechToText.initialize(onStatus: (status) {}, onError: (error) {});
  }

  Future<void> _loadQuestion() async {
    await _setSpeechRate();
    await _speak();
    setState(() {
      _questiontext = questions[_qindex].question;
    });
  }

  Future<void> _loadAnswer() async {
    await _setSpeechRate();
    await _speak_answer();
    setState(() {
      _answertext = questions[_qindex].answer;
    });
  }

  Future<void> _speak() async {
    String qatext =
        questions.isNotEmpty ? questions[_qindex].question : "Loading...";
    _questiontext = qatext;
    await flutterTts.speak(_questiontext);
  }

  Future<void> _speak_answer() async {
    String antext =
        questions.isNotEmpty ? questions[_qindex].answer : "Loading...";
    _answertext = antext;
    await flutterTts.speak(_answertext);
  }

  Future<void> _setSpeechRate() async {
    await flutterTts.setSpeechRate(0.5);
  }

  void _next() {
    setState(() {
      _qindex = (_qindex + 1) % questions.length;
      _loadQuestion();
      _answertext = "";
    });
  }

  @override
  void dispose() {
    // _recorder?.closeRecorder();
    _player?.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Content')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _loadQuestion,
                  child: Text('Question'),
                ),
                SizedBox(height: 20),
                Text(
                  _questiontext,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _loadAnswer,
                  child: Text('Example Answer'),
                ),
                SizedBox(height: 20),
                Text(
                  _answertext,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: _next, child: Text('→')),
                SizedBox(height: 20),
                Text(
                  "",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
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
Future<List<Question>> loadQuestions(String langstr) async {
  String jsonString = await rootBundle.loadString('assets/data.json');

  if (langstr.contains("fr")) {
    jsonString = await rootBundle.loadString('assets/data_fr.json');
  }
  if (langstr.contains("de")) {
    jsonString = await rootBundle.loadString('assets/data_de.json');
  }
  if (langstr.contains("it")) {
    jsonString = await rootBundle.loadString('assets/data_it.json');
  }
  if (langstr.contains("ja")) {
    jsonString = await rootBundle.loadString('assets/data_jp.json');
  }
  if (langstr.contains("es")) {
    jsonString = await rootBundle.loadString('assets/data_es.json');
  }
  List<dynamic> jsonData = json.decode(jsonString);
  return jsonData.map((item) => Question.fromJson(item)).toList();
}
