import 'package:flutter/material.dart';
class Features extends StatelessWidget {
  final int type;
  Features(this.type);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        type==2?Container():Expanded(
          child:Container(
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
                      "2",
                      style: TextStyle(color: Colors.black),
                    ),
                    radius: 10,
                  ),
                )
              ],
            ),
          ),
        ),
        SizedBox(
          width: 1,
        ),
        Expanded(
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
        SizedBox(
          width: 1,
        ),
        Expanded(
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
      ],
    );
  }
}