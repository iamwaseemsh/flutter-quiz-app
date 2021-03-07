import 'package:flutter/material.dart';
import 'package:history_quiz_flutter_app/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share/share.dart';
import 'dart:io';
import 'dart:convert';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_admob/firebase_admob.dart';


class PaymnetScreen extends StatefulWidget {
  @override
  _PaymnetScreenState createState() => _PaymnetScreenState();
}

class _PaymnetScreenState extends State<PaymnetScreen> {

  int _lives = 0;
  Token _paymentToken;
  String _error;
  PaymentMethod _paymentMethod;
  final String _currentSecret = null; //set this yourself, e.g using curl
  PaymentIntentResult _paymentIntent;
  Source _source;

  Future<void> getLives() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final value = await prefs.getInt("lives");
    setState(() {
      _lives = value;
    });
  }
  Future<void> _increaseLives(int amount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("lives",_lives+amount);
    final value = await prefs.getInt("lives");
    setState(() {
      _lives = value;
    });
  }

  void _shareMediaHander() {
    Share.share('check out my website https://example.com');
  }

  ScrollController _controller = ScrollController();

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    FirebaseAdMob.instance
        .initialize(appId: "ca-app-pub-3940256099942544~3347511713");
    getLives();
    StripePayment.setOptions(
        StripeOptions(
            publishableKey: "pk_test_51HpsHeKYtVKuOXI6HpFy2jFBxRGUlpeqhroxxweFC6Yb7OUfCLk6QZcjaGYut8ZL5B4u59jPDiCggyWe1NuiAGhg00tFKHah8Y",
            merchantId: "Test",
            androidPayMode: 'test'));
    RewardedVideoAd.instance.listener =
        (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
      if (event == RewardedVideoAdEvent.rewarded) {
      _increaseLives(1);
      } else if (event == RewardedVideoAdEvent.loaded) {
        print("RewardedVideoAd.listener - Loaded");
      } else if (event == RewardedVideoAdEvent.opened) {
        print("RewardedVideoAd.listener - Opened");
        loadRewardedVideoAd();
      } else if (event == RewardedVideoAdEvent.failedToLoad) {
        print("RewardedVideoAd.listener - FailedToLoad");
        loadRewardedVideoAd();
      } else if (event == RewardedVideoAdEvent.started) {
        print("RewardedVideoAd.listener - Started");
      } else if (event == RewardedVideoAdEvent.completed) {
        print("RewardedVideoAd.listener - Completed");
      } else if (event == RewardedVideoAdEvent.leftApplication) {
        print("RewardedVideoAd.listener - Left Application");
      } else if (event == RewardedVideoAdEvent.closed) {

        print("RewardedVideoAd.listener - Closed");
      }
    };
  }
  void loadRewardedVideoAd() {
    print("RewardedVideoAd.load() - Called");
    RewardedVideoAd.instance
        .load(
        adUnitId: RewardedVideoAd.testAdUnitId,
        targetingInfo: MobileAdTargetingInfo(
          nonPersonalizedAds: true,
        ))
        .catchError((error) {
      print("RewardedVideoAd.load() - Error");
    }).then((onVal) {
      print("RewardedVideoAd.load() - Returned ${onVal}");
      return onVal;
    }).whenComplete(() {
      print("RewardedVideoAd.load() - Complete");
    });
  }
    void setError(dynamic error) {
      // _scaffoldKey.currentState.showSnackBar(
      //     SnackBar(content: Text("Payment could'nt done.")));
      // setState(() {
      //   _error = error.toString();
      // });
      // // TODO: implement initState
      Fluttertoast.showToast(
          msg: "Payment could'nt done.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0
      );


    }

  void showRewardedVideoAd() async {

    await RewardedVideoAd.instance.show();
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
                    padding: const EdgeInsets.only(left: 5, right: 15, top: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            icon: Icon(Icons.arrow_back_ios_outlined,
                              color: Colors.white, size: 40,),
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
                          Text("FREE", style: kPaymentHeadings,),
                          Card(
                            child: ListTile(
                              leading: Icon(
                                Icons.video_call_sharp, color: Colors.blue,),
                              title: Center(child: Text("Watch an ad")),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("+1"),
                                  Icon(Icons.favorite, color: Colors.red,)
                                ],
                              ),
                              onTap: ()async{
                                RewardedVideoAd.instance
                                    .load(
                                    adUnitId: RewardedVideoAd.testAdUnitId,
                                    targetingInfo: MobileAdTargetingInfo(
                                      nonPersonalizedAds: true,
                                    ))
                                    .catchError((error) {
                                  print("RewardedVideoAd.load() - Error");
                                }).then((onVal) {
                                  print(
                                      "RewardedVideoAd.load() - Returned ${onVal}");
                                  return onVal;
                                }).whenComplete(() {
                                  showRewardedVideoAd();
                                  print("RewardedVideoAd.load() - Complete");
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 30,),
                          Text("Shop", style: kPaymentHeadings,),
                          Card(
                            child: ListTile(
                              leading: Icon(
                                Icons.shopping_cart, color: Colors.orange,),
                              title: Center(child: Text("€1.00")),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("+5"),
                                  Icon(Icons.favorite, color: Colors.red,)
                                ],
                              ),
                              onTap: () {
                                if (Platform.isIOS) {
                                  _controller.jumpTo(450);
                                }
                                StripePayment.paymentRequestWithNativePay(
                                  androidPayOptions: AndroidPayPaymentRequest(
                                    totalPrice: "1.00",
                                    currencyCode: "EUR",
                                  ),
                                  applePayOptions: ApplePayPaymentOptions(
                                    countryCode: 'DE',
                                    currencyCode: 'EUR',
                                    items: [
                                      ApplePayItem(
                                        label: 'Test',
                                        amount: '13',
                                      )
                                    ],
                                  ),
                                ).then((token) async{
                                 await _increaseLives(5);
                                 Fluttertoast.showToast(
                                     msg: "Payment successful.",
                                     toastLength: Toast.LENGTH_SHORT,
                                     gravity: ToastGravity.BOTTOM,
                                     timeInSecForIosWeb: 1,
                                     backgroundColor: Colors.black,
                                     textColor: Colors.white,
                                     fontSize: 16.0
                                 );
                                  setState(() {

                                    // _scaffoldKey.currentState.showSnackBar(
                                    //     SnackBar(content: Text(
                                    //         'Received ${token.tokenId}')));
                                    // _paymentToken = token;
                                  });
                                }).catchError(setError);
                              },
                            ),
                          ),
                          Card(
                            child: ListTile(
                              leading: Icon(
                                Icons.shopping_cart, color: Colors.orange,),
                              title: Center(child: Text("€2.00")),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("+10"),
                                  Icon(Icons.favorite, color: Colors.red,)
                                ],
                              ),
                              onTap: () {
                                if (Platform.isIOS) {
                                  _controller.jumpTo(450);
                                }
                                StripePayment.paymentRequestWithNativePay(
                                  androidPayOptions: AndroidPayPaymentRequest(
                                    totalPrice: "2.00",
                                    currencyCode: "EUR",
                                  ),
                                  applePayOptions: ApplePayPaymentOptions(
                                    countryCode: 'DE',
                                    currencyCode: 'EUR',
                                    items: [
                                      ApplePayItem(
                                        label: 'Test',
                                        amount: '13',
                                      )
                                    ],
                                  ),
                                ).then((token)async {
                                  await _increaseLives(10);
                                  Fluttertoast.showToast(
                                      msg: "Payment successful.",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.black,
                                      textColor: Colors.white,
                                      fontSize: 16.0
                                  );
                                  // setState(() {
                                  //   _scaffoldKey.currentState.showSnackBar(
                                  //       SnackBar(content: Text(
                                  //           'Received ${token.tokenId}')));
                                  //   _paymentToken = token;
                                  // });
                                }).catchError(setError);
                              },
                            ),
                          ),
                          SizedBox(height: 30,),
                          Text("Share", style: kPaymentHeadings,),
                          Card(
                            child: ListTile(
                              onTap: _shareMediaHander,
                              leading: Icon(Icons.share, color: Colors.blue,),
                              title: Text("Share on social media"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("+1"),
                                  Icon(Icons.favorite, color: Colors.red,)
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
