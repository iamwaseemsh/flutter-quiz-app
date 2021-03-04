import 'package:flutter/material.dart';
import 'package:history_quiz_flutter_app/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share/share.dart';



class PaymnetScreen extends StatefulWidget {
  @override
  _PaymnetScreenState createState() => _PaymnetScreenState();
}

class _PaymnetScreenState extends State<PaymnetScreen> {

  int _lives=0;


  Future<void> getLives()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final value= await prefs.getInt("lives");
    setState(() {
      _lives=value;
    });
  }

  void _shareMediaHander(){
    Share.share('check out my website https://example.com');
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLives();

  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueGrey, Colors.green[200]],
            stops: [0.6, 1.3],
          ),
        ),
        child: Column(

          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5,right: 15,top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      icon: Icon(Icons.arrow_back_ios_outlined,color: Colors.white,size: 40,),
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                  Container(

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
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Text("FREE",style: kPaymentHeadings,),
                     Card(
                       child: ListTile(
                         leading: Icon(Icons.video_call_sharp,color: Colors.blue,),
                         title: Center(child: Text("Watch an ad")),
                         trailing: Row(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             Text("+1"),
                             Icon(Icons.favorite,color: Colors.red,)
                           ],
                         ),
                       ),
                     ),
                     SizedBox(height: 30,),
                     Text("Shop",style: kPaymentHeadings,),
                     Card(
                       child: ListTile(
                         leading: Icon(Icons.shopping_cart,color: Colors.orange,),
                         title: Center(child: Text("\$1")),
                         trailing: Row(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             Text("+5"),
                             Icon(Icons.favorite,color: Colors.red,)
                           ],
                         ),
                       ),
                     ),
                     Card(
                       child: ListTile(
                         leading: Icon(Icons.shopping_cart,color: Colors.orange,),
                         title: Center(child: Text("\$2")),
                         trailing: Row(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             Text("+10"),
                             Icon(Icons.favorite,color: Colors.red,)
                           ],
                         ),
                       ),
                     ),
                     SizedBox(height: 30,),
                     Text("Share",style: kPaymentHeadings,),
                     Card(
                       child: ListTile(
                         onTap: _shareMediaHander,
                         leading: Icon(Icons.share,color: Colors.blue,),
                         title: Text("Share on social media"),
                         trailing: Row(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             Text("+1"),
                             Icon(Icons.favorite,color: Colors.red,)
                           ],
                         ),
                       ),
                     )

                   ],
                ),
              ),
            )
          ],
        ),
      ),
    ));
  }
}
