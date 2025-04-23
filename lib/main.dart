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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue, // AppBar background
          foregroundColor: Colors.white, // Text/icon color
          elevation: 2, // Optional: shadow depth
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, // Button background
            foregroundColor: Colors.black, // Button text/icon
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Optional
            ),
          ),
        ),
      ),

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
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'EchoLang - Learn by Speaking Everyday',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
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
                _languageButton(context, "فارسی", "fa-IR"),
                _languageButton(context, "ελληνικά", "el-GR"),
                _languageButton(context, "Português", "pt-PT"),
                _languageButton(context, "عربي", "ar-SA"),
                _languageButton(context, "Pусский", "ru-RU"),
                _languageButton(context, "Cymraeg", "cy-GB"),
              ],
            ),
          ),
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
