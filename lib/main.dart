import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:noteapp_hive/settings.dart';
import 'package:noteapp_hive/splash_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/notes_model.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  var directory = await getApplicationDocumentsDirectory() ;
  Hive.init(directory.path);

  Hive.registerAdapter(NotesModelAdapter()) ;
  await Hive.openBox<NotesModel>('notes');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;
  double fontSize = 12.0;
  String language = 'English';
  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('darkMode') ?? false;
      fontSize = prefs.getDouble('fontSize') ?? 12.0;
      language = prefs.getString('language')?? 'English';
    });
  }

  void updateTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

  void updateFontSize(double value) {
    setState(() {
      fontSize = value;
    });
  }
  void updateFLanguage(String value) {
    setState(() {
      language = value;
    });
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.purple,
        ),
        routes: {
          '/settings': (context) => SettingsPage(
            updateTheme: updateTheme,
            updateFontSize: updateFontSize,
          ),
        },
        home: const SplashScreen()
    );
  }
}