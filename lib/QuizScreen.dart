import 'dart:async';
import 'dart:io';
import 'package:history_quiz_flutter_app/widgets/simple_round_icon_button.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:history_quiz_flutter_app/widgets/features_widget.dart';
import 'package:history_quiz_flutter_app/widgets/type1_widget.dart';
import 'package:history_quiz_flutter_app/widgets/type2_widget.dart';
import 'package:history_quiz_flutter_app/widgets/type3_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'quiz_brain.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';
QuizBrain quizBrain = QuizBrain();

class QuizScreen extends StatefulWidget {
  static const QuizRouteName = "/quiz_screen";

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with WidgetsBindingObserver,TickerProviderStateMixin {

  AnimationController _animationController;
  AnimationController _rotationAnimationController;
  AnimationController _scaleAnimationController;
  AnimationController _timerAnimationController;
  Animation<double> _scallAnimation;
  Animation<double> _rotationAnimation;
  Animation<double> _timerAnimation;
  bool _quizEnded=false;
  File _imageFile;
  bool _visibleDialog=false;
  Timer _timer;
  bool _feedbackVisible = false;
  bool _answer = true;
  var _result = null;
  var _noLives = false;
  var _counter=30;
  bool pauseDialog = false;
  var _wrongCount = 0;
  bool _disabler = false;
  bool _ressetter = true;
  int lives = 0;
  ScreenshotController screenshotController = ScreenshotController();

  void getLives() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

      lives =await prefs.getInt("lives") ?? -1;
      if(lives==0){
          setState(() {
            _noLives = true;
          });

      }else{
        getCounterFromLocal();
        startTimer();
        _timerAnimationController.forward();
      }

  }

  void increaseALife() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
   prefs.setInt("lives", lives+1);
  }

  void setQuestionNumberOnLocal(value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("qno", value);
  }

  void setQuestionNumberOnApp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int qno = await prefs.getInt("qno") ?? 0;
    setState(() {
    quizBrain.setQuestionNumber(qno);
    });
  }

  void getCounterFromLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int value = await prefs.getInt("counter") ?? 0;
    
    if (value > 1) {
      if(quizBrain.getQuestionType()=="3"){
        _counter = 30;
      }else{
        _counter=value;
      }

    } else {
      _counter = 30;
    }
  }

  void setCounterOnLocal(value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
   await prefs.setInt("counter", value);
  }
  


  @override
  void initState() {
    setQuestionNumberOnApp();
    getCounterFromLocal();
    checkIfQuizFinished();

    // TODO: implement initState
    _animationController= AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400)
    );
    Timer(Duration(milliseconds:300), () => _animationController.forward());
    _scaleAnimationController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this, value: 0.1);
    _timerAnimationController = AnimationController(duration: const Duration(milliseconds: 1100), vsync: this, value: 0.1);
    _rotationAnimationController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this, value:0.25,lowerBound: 0.25,upperBound: 0.5);

    _scallAnimation = CurvedAnimation(parent: _scaleAnimationController, curve: Curves.bounceInOut);
    _timerAnimation= CurvedAnimation(parent: _timerAnimationController, curve: Curves.fastOutSlowIn);
    _rotationAnimation = CurvedAnimation(parent: _rotationAnimationController, curve: Curves.linear);

    getLives();
    super.initState();


    startTimer();
    _timerAnimationController.forward();
    _rotationAnimationController.forward();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      setQuestionNumberOnLocal(quizBrain.getQuestionsNumber());
      print("State is paused");
      _ressetter=true;
      setCounterOnLocal(_counter);
      _timer.cancel();

    } else if (state == AppLifecycleState.resumed) {
      print("State is resumed");
      if (pauseDialog == false&&lives!=0&&_visibleDialog==false) {
        _showPauseDialog(context);
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _animationController.dispose();
    _timerAnimationController.dispose();
    _scaleAnimationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  void startTimer() {
    if (_timer != null) {
      _timer.cancel();
    }
      if(_quizEnded==false){
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_counter > 0) {
          _counter--;
          setCounterOnLocal(_counter);
        } else {
          setState(() {
            _timer.cancel();
            _feedbackVisible = true;
            _answer = false;
            _result = false;
            _disabler = true;
            _reduceLive2();
            _showResultIcon();
          });


          _timer.cancel();
        }
      });
    });
      }
  }

  @override
  Widget build(BuildContext context) {
    return _quizEnded?
        SafeArea(
          child: Column(
            children: [
              Container(
                color: Colors.red,
                child: Center(child: Text("Quiz Ended bro",style: TextStyle(color: Colors.white,decoration: TextDecoration.none),)),
              ),
              RaisedButton(onPressed: (){
                resetApplication();
              },
              child: Text("Reset"),
              )
            ],
          ),
        ): _noLives
        ? SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 60, horizontal: 30),
              color: Colors.black54,
              child: Container(
                color: Colors.blueAccent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      padding: EdgeInsets.all(30),
                      child: Image(
                        image: AssetImage('assets/pause.png'),
                      ),
                    ),
                    Container(
                      child: RaisedButton(
                        onPressed: ()async{
                          setState(() {
                            increaseALife();
                            getLives();
                              _noLives=false;
                              _counter=30;
                              setCounterOnLocal(30);
                              startTimer();
                            _timerAnimationController.forward();



                          });
                        },
                        color: Colors.deepOrangeAccent,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 50,vertical: 30),
                          child: Text(
                           "Get more lives",
                            style: TextStyle(color: Colors.white,fontSize: 20),
                          ),
                        ),

                                                ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : WillPopScope(
            onWillPop: () async {
              _timer.cancel();
              return true;
            },
            child: Screenshot(
              controller: screenshotController,
              child: SafeArea(
                  child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Color(0xFF4C271B),
                  elevation: 0,
                  leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        size: 30,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                  title: ScaleTransition(
                    scale: _timerAnimation,
                    child: CircularPercentIndicator(
                        radius: 50,
                        animation: true,
                        animationDuration: 1000,
                        animateFromLastPercent: true,
                        curve: Curves.linear,

                        center: Text(
                          "$_counter",
                          style: TextStyle(color: Colors.white, fontSize: 25),
                        ),
                        backgroundColor: Colors.black38,
                        progressColor: Colors.green,
                        percent: (_counter / 1000) * 33,

                    ),
                  ),
                  centerTitle: true,
                  actions: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/b.png'))),
                      child: Center(
                          child: Text(
                        "$lives",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.bold),
                      )),
                    ),
                  ],
                ),
                body: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF4C271B), Color(0xff7C532C)],
                      stops: [0.6, 1.3],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: quizBrain.getQuestionType() == "3" ? 2 : 5,
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                              ),
                              margin: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 50),
                              child: Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(top: 10),
                                    child: Text(
                                        "Question ${quizBrain.getQuestionsNumber() + 1} of ${quizBrain.getQuestionsLength()}"),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Container(
                                    width: double.infinity,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: Text(
                                      "${quizBrain.getQuestionText()}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 21.0),
                                    ),
                                  ),
                                quizBrain.getQuestionImageStatus()?Expanded(
                                      child:  Container(
                                        height: 180.0,
                                        margin: EdgeInsets.only(left: 10,right: 10,bottom: 10),
                                        child: Image.network(quizBrain.getQImgUrl(),fit: BoxFit.scaleDown,),
                                      )):Container(),


                                ],
                              ),
                            ),
                            Visibility(
                              visible: _feedbackVisible,
                              child: ScaleTransition(
                                scale: _scallAnimation,
                                alignment: Alignment.center,
                                child: Container(
                                  child: Center(
                                      child: CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    radius: 70,
                                    backgroundImage: AssetImage(_answer
                                        ? 'assets/excellent.png'
                                        : 'assets/bad.png'),
                                  )),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(child:
                      quizBrain.getQuestionType() == "1"
                          ? Type1Options(
                        animationController: _animationController,

                              resetResetter: () {
                                _ressetter = false;
                              },
                              ressetter: _ressetter,
                              disAbler: _disabler,
                              dispatchSkip: () {
                               _dispatchSkip();
                              },
                              screenShoter: () {
                                takeScreenShotAndShare();
                              },
                              options:
                                  quizBrain.getQuestionOptions().split(","),
                              result: _result,
                              hints: quizBrain.getHints().split(","),
                              setWrongCounterOnHints: () {
                                _wrongCount = 2;
                              },
                              checkAnswer: (input) {
                                if (input == quizBrain.getQuestionAnswer()) {
                                  setState(() {
                                    // _feedbackVisible = true;
                                    // _answer = true;

                                    _disabler = true;
                                    _result = true;
                                    _timer.cancel();
                                    _answer = true;
                                    _feedbackVisible = true;
                                    _showResultIcon();
                                  });
                                } else {
                                  setState(() {
                                    // _feedbackVisible = true;
                                    // _answer = false;
                                    if (lives > 0) {
                                      _wrongCount++;
                                      if (_wrongCount == 3) {
                                        _disabler = true;
                                        setState(() {
                                          _result = false;
                                          _answer = false;
                                          _timer.cancel();
                                          _feedbackVisible = true;
                                          _showResultIcon();
                                        });
                                      }
                                      _reduceLive();
                                      _result = false;
                                    }
                                    print(_wrongCount);
                                  });
                                }
                                // _showResultIcon();
                              },
                            )
                          : quizBrain.getQuestionType() == "2"
                              ? Type2Options(
                        animationController: _animationController,
                                  screenShoter: () {
                                    takeScreenShotAndShare();
                                  },
                                  result: _result,
                                  dispatchSkip: () {
                                    _dispatchSkip();
                                  },
                                  checkAnswer: (input) {
                                    _checkResult(input);
                                    _showResultIcon();
                                  },
                        resetResetter: () {
                          _ressetter = false;
                        },
                        resetter: _ressetter,
                                )
                              :quizBrain.getQuestionType() == "3"?Type3Options(
                        animationController: _animationController,
                                  resetResetter: () {
                                    _ressetter = false;
                                  },
                                  resetter: _ressetter,
                                  screenShoter: () {
                                    takeScreenShotAndShare();
                                  },
                                  options:
                                      quizBrain.getQuestionOptions().split(","),
                                  dispatchSkip: () {
                                    _dispatchSkip();
                                  },
                                  resultTrue: () {
                                    setState(() {
                                      _feedbackVisible = true;
                                      _answer = true;
                                      _result = true;
                                      _timer.cancel();
                                      _showResultIcon();
                                    });
                                  },
                                  answer: quizBrain.getQuestionAnswer(),
                                  answerLength:
                                      quizBrain.getQuestionAnswer().length,
                                ):CircularPercentIndicator(radius: 10)
                      ),
                    ],
                  ),
                ),
              )),
            ),
          );
  }

  void takeScreenShotAndShare() async {
    _timer.cancel();
    _imageFile = null;
    screenshotController
        .capture(delay: Duration(milliseconds: 10), pixelRatio: 2.0)
        .then((File image) async {
      setState(() {
        _imageFile = image;
      });
      final directory = (await getApplicationDocumentsDirectory()).path;
      Uint8List pngBytes = _imageFile.readAsBytesSync();
      File imgFile = new File('$directory/screenshot.png');
      imgFile.writeAsBytes(pngBytes);
      print("File Saved to Gallery");
      await Share.file('Anupam', 'screenshot.png', pngBytes, 'image/png');
    }).catchError((onError) {
      print(onError);
    });
  }

  void _reduceLive() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("lives", lives - 1);
    setState(() {
      getLives();
    });
  }
  void _reduceLive2() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("lives", lives - 1);

  }

  void _checkResult(input) {
    if (input == quizBrain.getQuestionAnswer()) {
      setState(() {
        _feedbackVisible = true;
        _answer = true;
        _result = true;
      });
    } else {
      _reduceLive2();
      setState(() {
        _feedbackVisible = true;
        _answer = false;
        _result = false;
      });
    }
  }

  void _showResultIcon() {
    _timer.cancel();
    _scaleAnimationController.forward();

    Timer(Duration(seconds: 2), () {
      setState(() {
        _scaleAnimationController.reverse();
       _scaleAnimationController.reset();
       _feedbackVisible = false;
        _showDialog(context);


      });
    });
  }

  void setQuizFinishedOnLocal(bool input)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("finished", input);
  }

  void resetApplication()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setQuestionNumberOnLocal(0);
    setCounterOnLocal(30);
    setQuizFinishedOnLocal(false);
    setState(() {
      quizBrain.setQuestionNumber(0);
      _quizEnded=false;
      _counter=30;
      _disabler=false;
    });
    startTimer();
    _timerAnimationController.dispose();

    _timerAnimationController.forward();


  }
  void checkIfQuizFinished()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

   bool value= await prefs.getBool("finished");
   
   setState(() {
     if(value==true||value==false){
       _quizEnded=value;
     }else{
       _quizEnded=false;
     }

   });
  }
  void _resetAll() {
    setState(() {
      _visibleDialog=false;
      if(quizBrain.getQuestionsNumber()==quizBrain.getQuestionsLength()-1){
       print("Quiz Ended");
       setQuizFinishedOnLocal(true);
       _quizEnded=true;
       _result=null;
       _counter=30;
       setCounterOnLocal(30);
       _ressetter=true;
       _timer.cancel();
      }else{
        quizBrain.nextQuestion();
        Timer(Duration(milliseconds:100), (){
          _animationController.reset();
          _animationController.forward();

        });
        setQuestionNumberOnLocal(quizBrain.getQuestionsNumber());
        _result = null;
        _counter = 30;
        setCounterOnLocal(30);
        _disabler = false;
        _wrongCount = 0;
        _ressetter = true;
        if(lives!=1){
          startTimer();

          _timerAnimationController.forward();

        }

      }

    });
  }


// void _showDialog(){
  Future _showDialog(BuildContext context) async {
    _visibleDialog=true;
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(30.0)),
              height: 450,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: _result ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(30.0)),
                    padding: EdgeInsets.symmetric(vertical: 10),
                    width: double.infinity,
                    child: Center(
                        child: Text(
                      _result ? "Correct Answer" : "Wrong Answer",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    )),
                  ),
                  Container(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        _result
                            ? "Excellent"
                            : "Correct answer is ${quizBrain.getQuestionAnswer()}",
                        style: TextStyle(
                            fontSize: _result ? 30 : 20,
                            fontWeight: FontWeight.bold),
                      )),

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 10.0),
                    height: 180,
                    child: Image.network(quizBrain.getCImgUrl(),fit: BoxFit.cover,),
                  ),
                  Container(
                    child: Column(
                      children: [
                        Text('„Did you know?”',style: TextStyle(fontWeight: FontWeight.bold),),
                        SizedBox(height: 7,)
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [


                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(quizBrain.getCurosity()),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: 20.0),
                            child: RaisedButton(
                              color: Colors.lightGreen,
                              onPressed: () {
                                setState(() {
                                  // quizBrain.nextQuestion();
                                  // _result = null;
                                  Navigator.pop(context);
                                  // _counter = 30;
                                  // startTimer();
                                });
                              },
                              child: Text(
                                "Continue",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        )

                      ],
                    ),
                  ),


                ],
              ),
            ),
          );
        });
    _resetAll();
    getLives();
  }

  Future _showPauseDialog(BuildContext context) async {
    pauseDialog = true;
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blueAccent, Colors.white],
                  stops: [0.6, 1.3],
                ),
              ),
              height: 400,
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Container(
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: AssetImage('assets/pause.png'),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          RaisedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            color: Colors.deepOrangeAccent,
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              padding: EdgeInsets.symmetric(vertical: 10),
                              width: double.infinity,
                              child: Text(
                                "HOME",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          RaisedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              startTimer();
                            },
                            color: Colors.green,
                            child: Container(
                              width: double.infinity,
                              child: Text(
                                "Resume",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });

    pauseDialog = false;
    // if(lives!=0){
    startTimer();
    _timerAnimationController.forward();
    // }
  }

  Future _showNoLivesDialog(BuildContext context) async {
    pauseDialog = true;
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blueAccent, Colors.white],
                  stops: [0.6, 1.3],
                ),
              ),
              height: 400,
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Container(
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: AssetImage('assets/pause.png'),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("Get More Lives"),
                    ),
                  )
                ],
              ),
            ),
          );
        });
    Navigator.of(context).pop();
  }

  _dispatchSkip(){
    setState(() {
      _feedbackVisible = true;
      _answer = false;
      _result = false;
      _disabler = true;
      _showResultIcon();
    });
 }
}
