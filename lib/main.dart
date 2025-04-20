import 'package:flutter/material.dart';
import 'package:test_flutter/submenu.dart';
import 'content.dart'; // Import the second page
import 'package:flutter_tts/flutter_tts.dart';
import 'submenu.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EchoLang',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LanguageSelectionPage(),
    );
  }
}

class LanguageSelectionPage extends StatefulWidget {
  @override
  _LanguageSelectionPageState createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _speakWelcomeMessage(); // Run this at startup
    _printAvailableLanguages();
  }

  Future<void> _printAvailableLanguages() async {
    List<dynamic> languages = await flutterTts.getLanguages;
    print("Available languages:");
    for (var lang in languages) {
      print(lang);
    }
  }

  Future<void> _speakWelcomeMessage() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak("Welcome to EchoLang. Please select a language.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Language')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'EchoLang - Learn by Speaking Everyday',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _languageButton(context, "Français", "fr-FR"),
            _languageButton(context, "English", "en-US"),
            _languageButton(context, "Deutsch", "de-DE"),
            _languageButton(context, "Italiano", "it-IT"),
            _languageButton(context, "日本語", "ja-JP"),
            _languageButton(context, "Español", "es-ES"),
            _languageButton(context, "Danish", "da-DK"),
            _languageButton(context, "中国語（簡体字)", "zh-CN"),
          ],
        ),
      ),
    );
  }

  Widget _languageButton(BuildContext context, String label, String langCode) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubMenuPage(language: langCode),
              ),
            );
          },
          child: Text(label),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
