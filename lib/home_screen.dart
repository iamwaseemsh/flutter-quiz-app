import 'package:flutter/material.dart';
import 'package:history_quiz_flutter_app/QuizScreen.dart';
import 'package:history_quiz_flutter_app/paymentScreen.dart';
import 'package:history_quiz_flutter_app/quiz_brain.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:url_launcher/url_launcher.dart';


QuizBrain quizBrain = QuizBrain();

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int _lives=0;

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
    final rated=await prefs.getBool("rated")??false;
    if(questionNumber>3){
      if(rated==false){
        _showRatingDialog();
        await prefs.setBool("rated", true);
      }

    }
    QuizBrain().setQuestionNumber(questionNumber);
    final hints = await prefs.getInt("hints") ?? -1;
    final lives = await prefs.getInt("lives") ?? -1;

    setState(() {
      _lives=lives;
    });

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
    getQuestionFromDB();
    checkIfQuizFinished();
    setData();
    // TODO: implement initState
    super.initState();

  }

  void _showRatingDialog(){
   showDialog(context: context
   ,builder: (context){
     return RatingDialog(
       icon: Image.asset('assets/rating.png'),
       title: "Rate our app",
       description: "",
       onSubmitPressed: (int rating)async{
         if(rating>3){
           await canLaunch("https://play.google.com/store/apps/details?id=com.cleantec.mehndidesing") ? await launch("https://play.google.com/store/apps/details?id=com.cleantec.mehndidesing") : throw 'Could not launch';

         }else{

         }

       },
       positiveComment: "Thanks for rating",
       submitButton: "Submit",

     );
       }

   );


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
        Container(
          color: Colors.blue[400],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=>PaymnetScreen()));
                },

                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Container(

                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/b.png'))),
                    child: Center(
                        child: Text(
                          "$_lives",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.bold),
                        )),
                  ),
                ),
              ),


          ],),
        ),
        Expanded(
          flex: 2,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
              width: double.infinity,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,

                    colors: [Colors.blue[400], Colors.lightBlue[50]],
                    // colors: [Color(0xFF772F1A), Color(0xffF2A65A)],
                    stops: [0.6, 1.3],
                  ),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30))),
              child: Center(
                child: Image.asset('assets/mainimage.png',fit: BoxFit.contain,),
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
                      color: Colors.blue[400],
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
                )),

              ],
            )),
      ],
    ));
  }
}
