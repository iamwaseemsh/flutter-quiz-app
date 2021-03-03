import 'package:flutter/material.dart';
import 'package:history_quiz_flutter_app/widgets/features_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Type1Options extends StatefulWidget {
  final List<String> options;
  final Function checkAnswer;
  final int hintsNo;
  final Function reduceHint;
  final Function noHintDialog;
  final Function dispatchSkip;
  final Function screenShoter;
  final Function resetResetter;
  final Function getNewHintsDialog;
  final bool ressetter;
  final bool disAbler;
  var result;
  final Function setWrongCounterOnHints;
  List<String> hints;
  final AnimationController animationController;

  Type1Options(
      {@required this.options,
      this.checkAnswer,
        this.getNewHintsDialog,
      this.result,
      this.hints,
        this.animationController,
      this.resetResetter,
      this.dispatchSkip,
      this.screenShoter,
      this.disAbler,
      this.setWrongCounterOnHints,
      this.ressetter,
        this.reduceHint,
        this.noHintDialog,
        this.hintsNo

      });

  @override
  _Type1OptionsState createState() => _Type1OptionsState();
}

class _Type1OptionsState extends State<Type1Options> {
  var selectedItem;
  bool option1;
  bool option2;
  bool option3;
  bool option4;
  bool hintOption1;
  bool hintOption2;
  bool hintOption3;
  bool hintOption4;
  bool hintUsed = false;

  // void getHints() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   hints = prefs.getInt("hints") ?? -1;
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
 //   getHints();
  }

  void resetAll() {
    if (widget.ressetter == true) {
      option1 = option2 = option3 = option4 = null;
      hintOption1 = hintOption2 = hintOption1 = hintOption1 = null;
      hintUsed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (selectedItem == 0 && widget.result != null) {
      option1 = widget.result;
    }
    if (selectedItem == 1 && widget.result != null) {
      option2 = widget.result;
    }
    if (selectedItem == 2 && widget.result != null) {
      option3 = widget.result;
    }
    if (selectedItem == 3 && widget.result != null) {
      option4 = widget.result;
    }

    if (widget.ressetter == true) {
      resetAll();
      widget.resetResetter();
    }

    return Expanded(
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0,1),
          end: Offset.zero,
        ).animate(widget.animationController),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      if (widget.hintsNo > 0 &&
                          widget.disAbler == false &&
                          hintUsed == false) {
                        // SharedPreferences prefs =
                        //     await SharedPreferences.getInstance();
                        widget.reduceHint();
                        for (int i = 0; i < widget.hints.length; i++) {
                          setState(() {
                            if (widget.hints[i] == "1") {
                              hintOption1 = false;
                            } else if (widget.hints[i] == "2") {
                              hintOption2 = false;
                            } else if (widget.hints[i] == "3") {
                              hintOption3 = false;
                            } else if (widget.hints[i] == "4") {
                              hintOption4 = false;
                            }
                          });
                        }
                        // getHints();
                        widget.setWrongCounterOnHints();
                        hintUsed = true;
                      }else{
                        //Write code here.
                        // widget.getNewHintsDialog();
                       if(!hintUsed){

                       }
                      }
                    },
                    child: Container(
                      height: double.infinity,
                      color: Color.fromRGBO(243, 243, 243, .1),
                      child: Stack(
                        overflow: Overflow.visible,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lightbulb_outline_rounded,
                                color: Colors.white,
                              ),
                              Center(
                                child: Text(
                                  "Hint",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                          Positioned(
                            top: -10,
                            right: 1,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Center(
                                child: Text(
                                  "${widget.hintsNo}",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              radius: 10,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 1,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      widget.screenShoter();
                    },
                    child: Container(
                      height: double.infinity,
                      color: Color.fromRGBO(243, 243, 243, .1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_alt_rounded,
                            color: Colors.white,
                          ),
                          Center(
                            child: Text(
                              "ASK FRIEND",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 1,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      int lives = await prefs.getInt("lives") ?? -1;
                      print(lives);
                      if (lives > 0) {
                        await prefs.setInt("lives", lives - 1);

                        widget.dispatchSkip();
                      }
                    },
                    child: Container(
                      height: double.infinity,
                      color: Color.fromRGBO(243, 243, 243, .1),
                      child: Stack(
                        overflow: Overflow.visible,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: Colors.white,
                              ),
                              Center(
                                child: Text(
                                  "SKIP",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                          Positioned(
                            right: 3,
                            top: -12,
                            child: CircleAvatar(
                              //  backgroundImage: AssetImage('assets/b.png'),
                              backgroundColor: Colors.white,
                              radius: 10,
                              child: Text(
                                "-1",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )),
            SizedBox(
              height: 1,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (!widget.disAbler) {
                    setState(() {
                      // if(widget.result==null){
                      widget.checkAnswer(widget.options[0]);
                      selectedItem = 0;
                      // }
                    });
                  }
                },
                child: Container(
                  color: widget.result == true && selectedItem == 0
                      ? Colors.lightGreen
                      : widget.result == false && selectedItem == 0
                          ? Colors.red
                          : option1 == true
                              ? Colors.green
                              : option1 == false
                                  ? Colors.red
                                  : hintOption1==false?Colors.blue:Color.fromRGBO(244, 243, 243, 0.1),
                  child: Center(
                      child: Text(
                    "${widget.options[0]}",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )),
                ),
              ),
            ),
            SizedBox(
              height: 1,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (!widget.disAbler) {
                    setState(() {
                      // if(widget.result==null){
                      widget.checkAnswer(widget.options[1]);

                      selectedItem = 1;
                      // }
                    });
                  }
                },
                child: Container(
                  color: widget.result == true && selectedItem == 1
                      ? Colors.lightGreen
                      : widget.result == false && selectedItem == 1
                          ? Colors.red
                          : option2 == true
                              ? Colors.green
                              : option2 == false
                                  ? Colors.red
                      : hintOption2==false?Colors.blue:Color.fromRGBO(244, 243, 243, 0.1),
                  child: Center(
                      child: Text(
                    "${widget.options[1]}",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )),
                ),
              ),
            ),
            SizedBox(
              height: 1,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (!widget.disAbler) {
                    setState(() {
                      // if(widget.result==null){
                      widget.checkAnswer(widget.options[2]);

                      selectedItem = 2;

                      // }
                    });
                  }
                },
                child: Container(
                  color: widget.result == true && selectedItem == 2
                      ? Colors.lightGreen
                      : widget.result == false && selectedItem == 2
                          ? Colors.red
                          : option3 == true
                              ? Colors.green
                              : option3 == false
                                  ? Colors.red
                      : hintOption3==false?Colors.blue:Color.fromRGBO(244, 243, 243, 0.1),
                  child: Center(
                      child: Text(
                    "${widget.options[2]}",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )),
                ),
              ),
            ),
            SizedBox(
              height: 1,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (!widget.disAbler) {
                      widget.checkAnswer(widget.options[3]);

                      selectedItem = 3;
                    }
                    // if(widget.result==null){

                    // }
                  });
                },
                child: Container(
                  color: widget.result == true && selectedItem == 3
                      ? Colors.lightGreen
                      : widget.result == false && selectedItem == 3
                          ? Colors.red
                          : option4 == true
                              ? Colors.green
                              : option4 == false
                                  ? Colors.red
                      : hintOption4==false?Colors.blue:Color.fromRGBO(244, 243, 243, 0.1),
                  // color:widget.result==true&&selectedItem==3?Colors.lightGreen:widget.result==false&&selectedItem==3?Colors.red:Color.fromRGBO(244, 243, 243, 0.1),
                  child: Center(
                      child: Text(
                    "${widget.options[3]}",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )),
                ),
              ),
            ),
          ],
        ),
      ),
      flex: 3,
    );
  }
}
