import 'package:flutter/material.dart';
import 'package:history_quiz_flutter_app/QuizScreen.dart';
import 'package:history_quiz_flutter_app/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
//  SharedPreferences.setMockInitialValues({});
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        QuizScreen.QuizRouteName:(ctx)=>QuizScreen(),

      },
      home: SafeArea(
        child: HomeScreen()
      ),
    );
  }
}
