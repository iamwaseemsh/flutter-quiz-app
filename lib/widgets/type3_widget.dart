import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Type3Options extends StatefulWidget {
  final List<String> options;
  final Function resultTrue;
  String answer;
  int answerLength;
  bool resetter;
  final Function dispatchSkip;
  final Function resetResetter;
  final Function screenShoter;
  final Function getNewHintsDialog;
  final AnimationController animationController;

  Type3Options(
      {this.options,
      this.resultTrue,
      this.answer,
        this.animationController,
        this.getNewHintsDialog,
      this.answerLength,
        this.resetResetter,
      this.dispatchSkip,
        this.resetter,
      this.screenShoter});

  @override
  _Type3OptionsState createState() => _Type3OptionsState();
}

class _Type3OptionsState extends State<Type3Options> {

  bool disabler = false;
  int hintsHead=-1;
  int hints = 0;
  List<Option2> myAnswer = [];
  int writing_head = 0;
  int spaceIndex = null;
  List<Option> options = [];

  void makeBlankItems() {
    spaceIndex = widget.answer.indexOf(' ');
    for (int i = 0; i < widget.answerLength; i++) {
      if (spaceIndex != -1 && i == spaceIndex) {
        myAnswer.add(Option2(text: " "));
      } else {
        myAnswer.add(Option2(text: "_"));
      }
    }
  }

  void getHints() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    hints = prefs.getInt("hints") ?? -1;
  }

  void setOptions(){
    for (int i = 0; i < widget.options.length; i++) {
      options.add(Option(text: widget.options[i]));
    }
  }

void resetAll(){
    disabler=false;
    myAnswer=[];
    writing_head=0;
    spaceIndex=null;
    options=[];
    hintsHead=-1;

}

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // resetAll();
    getHints();
    // setOptions();
    // setState(() {
    //   makeBlankItems();
    // });
  }

  @override
  Widget build(BuildContext context) {
    if(widget.resetter==true){
      resetAll();
      setOptions();
      makeBlankItems();
      widget.resetResetter();
    }
    return Expanded(
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0,1),
          end: Offset.zero,
        ).animate(widget.animationController),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: ListTile(
                    title: Text(
                      myAnswer.map((e) => e.text).toList().join(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: Colors.white,
                          letterSpacing: 5),
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        if (writing_head > 0 && disabler == false&&hintsHead!=writing_head-1) {
                          setState(() {
                            myAnswer[writing_head - 1].text = "_";
                            options[myAnswer[writing_head - 1].index].toggle();
                            if (writing_head != 0) {
                              writing_head--;
                            }

                            if (writing_head == spaceIndex + 1 &&
                                spaceIndex != -1) {
                              writing_head--;
                            }
                          });
                        }
                        print("2 = ${writing_head}");
                      },
                      icon: Icon(
                        Icons.backspace,
                        color: Colors.white,
                      ),
                    ),
                  ),),
            ),
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {

                      if (hints > 0 && disabler == false) {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                       prefs.setInt("hints", hints - 1);
                        getHints();
                        // if (writing_head < widget.answerLength) {

                          for(int i=0;i<myAnswer.length;i++){
                            if(widget.answer[i]!=myAnswer[i].text){
                              print(widget.answer[i]);
                              print(myAnswer[i].text);
                              hintsHead=i;
                              print("okay");
                              break;
                            }else{
                              print(widget.answer[i]);
                              print(myAnswer[i].text);
                            }
                          }
                          if(hintsHead!=-1){
                            setState(() {
                              myAnswer[hintsHead].text =
                              widget.answer[hintsHead];

                            });
                          }

                          if(hintsHead==writing_head){
                            writing_head++;
                            if (writing_head == spaceIndex) {
                              writing_head++;
                            }
                          }

                          if (myAnswer.map((e) => e.text).toList().join() ==
                              widget.answer) {
                            disabler = true;
                            widget.resultTrue();
                          }
                        // }
                      }else{
                        Fluttertoast.showToast(
                            msg: "No hints left.",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.black,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );
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
                              child: Text(
                                "$hints",
                                style: TextStyle(color: Colors.black),
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
                        disabler=true;
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
              child: GridView.count(
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
                crossAxisCount: 10,
                children: List.generate(20, (index) {
                  return GestureDetector(
                    onTap: () {
                      if (options[index].visibility && disabler == false) {
                        if (writing_head < widget.answerLength) {
                          setState(() {
                            myAnswer[writing_head].text = widget.options[index];
                            myAnswer[writing_head].index = index;
                          });

                          // if(writing_head!=widget.answerLength-1){
                          writing_head++;
                          //}

                          if (writing_head == spaceIndex) {
                            writing_head++;
                          }
                          if (myAnswer.map((e) => e.text).toList().join() ==
                              widget.answer) {
                            disabler = true;
                            widget.resultTrue();
                          }
                          options[index].toggle();
                        }
                      }
                    },
                    child: Container(
                      color: Color.fromRGBO(243, 243, 243, .1),
                      child: Center(
                        child: Visibility(
                          visible: options[index].visibility,
                          child: Text(
                            "${options[index].text}",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Option {
  String text;
  bool visibility;

  Option({this.text, this.visibility = true});

  void toggle() {
    visibility = !visibility;
  }
}

class Option2 {
  String text;
  int index;

  Option2({this.text, this.index});
}
