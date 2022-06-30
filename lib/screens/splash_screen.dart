import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_sendbird_fcm/constants.dart';
import 'package:flutter_sendbird_fcm/screens/registration_screen.dart';
import 'package:flutter_sendbird_fcm/services/firebase_services.dart';
import 'package:flutter_sendbird_fcm/services/shared_ervices.dart';
import 'package:flutter_sendbird_fcm/utility/size_config.dart';

class SplashScreen extends StatefulWidget {
  //final Color backgroundColor = Colors.white;
  final TextStyle styleTextUnderTheLoader = TextStyle(
      fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  late FirebaseServices _userServices;
  late SharedServices _sharedServices;

  @override
  void initState() {
    super.initState();

    _userServices = new FirebaseServices();
    _sharedServices = new SharedServices();
    Future.delayed(Duration(milliseconds: 4000), () {
      if (FirebaseAuth.instance.currentUser != null) {
        _userServices.getUserById(user!.uid).then((snapShot) {
          if (snapShot.exists) {
            print("UserName :  ${snapShot['name']}");
            _sharedServices.addUserDataToSF(
              name: '${snapShot['name']}',
              phone: '${snapShot['number']}',
              email: '${snapShot['email']}',
              picURL: '${snapShot['profile_Pic_URL']}',
            );
            Navigator.pushReplacementNamed(context, '/Landing_Screen');
          } else {
            print("Registration needed");
            //user data does not exists
            //will create new data in db
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => RegistrationScreen(
                          phoneNumber: user!.phoneNumber!,
                          uid: user!.uid,
                        )));
          }
        });
      } else {
        Navigator.popAndPushNamed(context, '/welcome-screen');
        print("WELCOME SCREEN");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            brandLogo(),
            Positioned(
                left: 0,
                right: 0,
                bottom: 20,
                child: Column(
                  children: [
                    // Text(
                    //   "www.matrixnmedia.com | 2022",
                    //   style: Theme.of(context).textTheme.bodyText1,
                    // ),
                    Text(
                      "Version 1.0.0",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ],
                ))
          ],
        ));
  }

  Widget brandLogo() {
    return Center(
      child: Container(
          width: 60 * SizeConfig.imageSizeMultiplier!,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(500),
            ),
            color: Colors.transparent,
            semanticContainer: true,
            clipBehavior: Clip.antiAlias,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: Image.asset(
                'assets/virtualemployee.png',
                fit: BoxFit.cover,
              ),
            ),
          )),
    );
  }
}
