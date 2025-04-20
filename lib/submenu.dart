import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

import 'package:test_flutter/content.dart';

class SubMenuPage extends StatefulWidget {
  final String language;

  SubMenuPage({required this.language});

  @override
  _SubMenuState createState() => _SubMenuState();
}

class _SubMenuState extends State<SubMenuPage> {
  List<Question> questions = [];
  late String _language;
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
    _language = widget.language;
  }

  Future<void> _loadPage({int t = 0}) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContentPage(language: _language, contentType: t),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Courses')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _loadPage(t: 0),
                  child: Text('Questions'),
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
                  onPressed: () => _loadPage(t: 1),
                  child: Text('Dialogs'),
                ),
                SizedBox(height: 20),
                Text(
                  _answertext,
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
