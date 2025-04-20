import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class ContentPage extends StatefulWidget {
  final String language;
  final int contentType;

  ContentPage({required this.language, required this.contentType});

  @override
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<ContentPage> {
  List<Question> questions = [];
  List<Dialog> dialogs = [];
  List<String> dialoglinesParsedFromAdialog = [];

  // FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  FlutterTts flutterTts = FlutterTts();
  String _questiontext = "";
  String _answertext = "";
  int _qindex = 0;
  int _dindex = 0;
  String _dialogtext = "";

  // Language setting
  String _selectedLanguage = "en-US"; // Default to French
  List<String> languages = [
    "fr-FR",
    "en-US",
    "de-DE",
    "it-IT",
    "da-DK",
    "zh-CN",
  ];
  int _contentType = 0;

  @override
  void initState() {
    super.initState();
    _player = FlutterSoundPlayer();
    _setLanguage(widget.language); // Set language from the widget
    _contentType = widget.contentType;
    if (_contentType == 0) {
      loadAndSetQuestions();
      _initialize();
      _loadQuestion();
    }
    if (_contentType == 1) {
      loadAndSetDialogs();
      _initialize();
      _loadDialog();
    }
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

  Future<void> loadAndSetDialogs() async {
    List<Dialog> loadedDialogs = await loadDialogs(
      _selectedLanguage.toString(),
    );
    loadedDialogs.shuffle();
    setState(() {
      dialogs = loadedDialogs;
    });
  }

  Future<void> _initialize() async {
    await _player!.openPlayer();
  }

  Future<void> _setLanguage(String languageCode) async {
    setState(() {
      _selectedLanguage = languageCode;
    });
    // Update FlutterTts and SpeechToText language
    await flutterTts.setLanguage(_selectedLanguage);
  }

  Future<void> _loadDialog() async {
    await _setSpeechRate(pitch: 0.6);
    await _speakDialog();
    setState(() {
      _dialogtext = dialogs[_dindex].dialog;
      dialoglinesParsedFromAdialog = _parseDialog(_dialogtext);
    });
  }

  List<String> _parseDialog(String dialogText) {
    return dialogText.split('__');
  }

  List<String> _parseLine(String lineText) {
    return lineText.split(':');
  }

  Future<void> _loadQuestion() async {
    await _setSpeechRate(pitch: 0.5);
    await _loadQuestionText();
    await Future.delayed(Duration(milliseconds: 100));
    await _speak();
  }

  Future<void> _loadAnswer() async {
    await _setSpeechRate(pitch: 0.5);
    await _loadAnswerText();
    await Future.delayed(Duration(milliseconds: 100));
    await _speakAnswer();
  }

  Future<void> _loadQuestionText() async {
    setState(() {
      _questiontext = questions[_qindex].question;
    });
  }

  Future<void> _loadAnswerText() async {
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

  Future<void> _speakDialog() async {
    await flutterTts.awaitSpeakCompletion(
      true,
    ); // Ensure it waits between lines

    for (final each in dialoglinesParsedFromAdialog) {
      final ary = _parseLine(
        each,
      ); // Assuming _parseLine returns [speaker, sentence]
      await flutterTts.speak(
        ary.last,
      ); // Speak only the speaker's name or dialog
    }
  }

  Future<void> _speakAnswer() async {
    await flutterTts.speak(_answertext);
  }

  Future<void> _setSpeechRate({double pitch = 0.6}) async {
    await flutterTts.setSpeechRate(pitch);
  }

  void _next() {
    setState(() {
      _qindex = (_qindex + 1) % questions.length;
      _loadQuestion();
      _answertext = "";
    });
  }

  void _nextdialog() {
    setState(() {
      _dindex = (_dindex + 1) % dialogs.length;
      _loadDialog();
      dialoglinesParsedFromAdialog = [];
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
            if (_contentType == 0) ...[
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
            if (_contentType == 1) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    // This ensures the Column doesn't overflow horizontally
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 80.0,
                          ),
                          child: ElevatedButton(
                            onPressed: _loadDialog,
                            child: Text('Play Dialog'),
                          ),
                        ),
                        SizedBox(height: 20),

                        ...dialoglinesParsedFromAdialog.map((line) {
                          final parts = _parseLine(
                            line,
                          ); // Assuming this gives [speaker, text]
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4.0,
                              horizontal: 80.0,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    line,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.play_arrow),
                                  onPressed: () async {
                                    await _setSpeechRate(pitch: 0.6);
                                    await flutterTts.speak(
                                      parts.last,
                                    ); // Play just the spoken text
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(onPressed: _nextdialog, child: Text('→')),
                  SizedBox(height: 20),
                  Text(
                    "",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
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
  if (langstr.contains("da")) {
    jsonString = await rootBundle.loadString('assets/data_da.json');
  }
  if (langstr.contains("zh")) {
    jsonString = await rootBundle.loadString('assets/data_zh.json');
  }
  List<dynamic> jsonData = json.decode(jsonString);
  return jsonData.map((item) => Question.fromJson(item)).toList();
}

// Model class for the Dialog
class Dialog {
  final String dialog;
  final String language;

  Dialog({required this.dialog, required this.language});

  factory Dialog.fromJson(Map<String, dynamic> json) {
    return Dialog(dialog: json['dialog'], language: json['language']);
  }
}

// Function to load JSON
Future<List<Dialog>> loadDialogs(String langstr) async {
  String jsonString = await rootBundle.loadString('assets/data_dialog.json');

  if (langstr.contains("fr")) {
    jsonString = await rootBundle.loadString('assets/data_fr_dialog.json');
  }
  if (langstr.contains("de")) {
    jsonString = await rootBundle.loadString('assets/data_de_dialog.json');
  }
  if (langstr.contains("it")) {
    jsonString = await rootBundle.loadString('assets/data_it_dialog.json');
  }
  if (langstr.contains("ja")) {
    jsonString = await rootBundle.loadString('assets/data_jp_dialog.json');
  }
  if (langstr.contains("es")) {
    jsonString = await rootBundle.loadString('assets/data_es_dialog.json');
  }
  if (langstr.contains("da")) {
    jsonString = await rootBundle.loadString('assets/data_da_dialog.json');
  }
  if (langstr.contains("zh")) {
    jsonString = await rootBundle.loadString('assets/data_zh_dialog.json');
  }
  List<dynamic> jsonData = json.decode(jsonString);
  return jsonData.map((item) => Dialog.fromJson(item)).toList();
}
