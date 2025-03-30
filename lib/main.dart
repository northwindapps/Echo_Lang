import 'package:flutter/material.dart';
import 'content.dart'; // Import the second page

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EchoLang',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LanguageSelectionPage(),
    );
  }
}

class LanguageSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Language')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'EchoLang - Learn by Speaking Everyday', // Replace with your app's actual name
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            HomeScreenPage(language: "fr-FR"), // French
                  ),
                );
              },
              child: Text('Français'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            HomeScreenPage(language: "en-US"), // English
                  ),
                );
              },
              child: Text('English'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            HomeScreenPage(language: "de-DE"), // English
                  ),
                );
              },
              child: Text('Deutsch'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            HomeScreenPage(language: "it-IT"), // English
                  ),
                );
              },
              child: Text('Italiano'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            HomeScreenPage(language: "ja-JP"), // English
                  ),
                );
              },
              child: Text('日本語'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            HomeScreenPage(language: "es-ES"), // English
                  ),
                );
              },
              child: Text('Español'),
            ),
            // Add more language buttons if needed
          ],
        ),
      ),
    );
  }
}
