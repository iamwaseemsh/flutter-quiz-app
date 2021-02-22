import 'package:flutter/material.dart';
import 'package:history_quiz_flutter_app/QuizScreen.dart';
import 'package:history_quiz_flutter_app/quiz_brain.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

QuizBrain quizBrain = QuizBrain();

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int questionsLength=0;
  final _firestore=FirebaseFirestore.instance;
  void getQuestionFromDB()async{
    final messages=  await _firestore.collection("quizlist").get();
   // print("length is${}");
   setState(() {
     questionsLength=messages.docs.length;
   });

  }
  int solvedQuestion = 0;
  bool _quizEnded=false;
  void checkIfQuizFinished()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool value= await prefs.getBool("finished");
    if(value){
          print("value is $value");
        _quizEnded=value;
    }else{
      await prefs.setBool("finished", false);
    }

  }
  void setData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final questionNumber=await prefs.getInt("qno") ?? 0;
    QuizBrain().setQuestionNumber(questionNumber);
    final hints = await prefs.getInt("hints") ?? -1;
    final lives = await prefs.getInt("lives") ?? -1;


    if (hints < 0) {
      await prefs.setInt("hints", 10);
      print("hints are $hints");
    }
    if (lives < 0) {
      await prefs.setInt("lives", 10);
      print("hints are $lives");
    }
  }

  void getSolvedQuestionsNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int temp=await prefs.getInt("qno") ?? 0;
    setState(() {
      solvedQuestion = temp;
    });
  }

  @override
  void initState() {

    // TODO: implement initState
    super.initState();
    getQuestionFromDB();
    checkIfQuizFinished();
    setData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getSolvedQuestionsNumber();
    return Scaffold(
        body: Column(
      children: [
        Expanded(
          flex: 2,
          child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,

                    colors: [Color(0xFF4C271B), Color(0xff7C532C)],
                    // colors: [Color(0xFF772F1A), Color(0xffF2A65A)],
                    stops: [0.6, 1.3],
                  ),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30))),
              child: Center(
                child: Image.asset('assets/a.png'),
              )),
        ),
        Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  onPressed: ()async {
                    quizBrain.setEmpty();
                    final messages=  await _firestore.collection("quizlist").get();
                    for(var message in messages.docs){
                      if(message.data()["type"]=="1"){
                        print(message.data());
                        quizBrain.addQuestion(Question(type: message.data()["type"],question: message.data()["question"],answer: message.data()["answer"],hints: message.data()["hints"],curosity: message.data()["curosity"],options: message.data()["options"],cImgUrl:message.data()["cImgUrl"],qImgUrl:message.data()["qImgUrl"],questionImg:message.data()["questionImg"] ));
                      }else if(message.data()["type"]=="2"){
                        quizBrain.addQuestion(Question(type: message.data()["type"],question: message.data()["question"],answer: message.data()["answer"],curosity: message.data()["curosity"],cImgUrl:message.data()["cImgUrl"],qImgUrl:message.data()["qImgUrl"],questionImg:message.data()["questionImg"] ));

                      }else if(message.data()["type"]=="3"){
                        quizBrain.addQuestion(Question(type: message.data()["type"],question: message.data()["question"],answer: message.data()["answer"],curosity: message.data()["curosity"],options: message.data()["options"],cImgUrl:message.data()["cImgUrl"],qImgUrl:message.data()["qImgUrl"],questionImg:message.data()["questionImg"] ));
                      }

                    }
                    if(quizBrain.getQuestionsLength()==0){
                      Fluttertoast.showToast(
                          msg: "Connection error!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          fontSize: 16.0
                      );
                    }else{
                      await  Navigator.of(context).pushNamed(QuizScreen.QuizRouteName);
                      checkIfQuizFinished();
                    }

                  },
                  // padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.lightGreen,
                    ),
                    height: 50,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Icon(
                              Icons.play_circle_fill_sharp,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Play",
                              style:
                                  TextStyle(fontSize: 30, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                    child: Text(
                 _quizEnded?"Congratulation! You've completed quiz":"${questionsLength - solvedQuestion} more questions remaining",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ))
              ],
            )),
      ],
    ));
  }
}
