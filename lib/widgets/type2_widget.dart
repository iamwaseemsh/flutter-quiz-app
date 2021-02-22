import 'package:flutter/material.dart';
import 'package:history_quiz_flutter_app/widgets/features_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Type2Options extends StatefulWidget {
  var result;
  final Function checkAnswer;
  final Function dispatchSkip;
  bool resetter;

  final Function resetResetter;
  final AnimationController animationController;
  final Function screenShoter;
  Type2Options({this.checkAnswer,this.result,this.dispatchSkip,this.screenShoter,this.animationController,this.resetResetter,this.resetter});

  @override
  _Type2OptionsState createState() => _Type2OptionsState();
}

class _Type2OptionsState extends State<Type2Options> {
  var selectedItem;
  @override
  Widget build(BuildContext context) {
    if(widget.resetter==true){
      selectedItem=null;

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
                      onTap: (){
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
                      onTap: ()async{
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        int lives = await prefs.getInt("lives") ?? -1;
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
              ),
            ),
            SizedBox(
              height: 1,
            ),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if(widget.result==null){


                        setState(() {
                          selectedItem=0;
                        });
                        widget.checkAnswer("TRUE");
                        }
                      },
                      child: Container(
                        height: double.infinity,
                        color:selectedItem==0&&widget.result==true?Colors.lightGreen:selectedItem==0&&widget.result==false?Colors.red:Color.fromRGBO(244, 243, 243, 0.1),
                        child: Center(
                            child: Text(
                          "True",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                        )),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 1,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if(widget.result==null){


                        setState(() {
                          selectedItem=1;
                        });
                        widget.checkAnswer("FALSE");
                        }
                      },
                      child: Container(
                        height: double.infinity,
                        color:selectedItem==1&&widget.result==true?Colors.lightGreen:selectedItem==1&&widget.result==false?Colors.red:Color.fromRGBO(244, 243, 243, 0.1),
                        child: Center(
                            child: Text(
                          "False",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                        )),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      flex: 2,
    );
  }
}
