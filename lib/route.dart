import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sendbird_fcm/screens/all_user_screen.dart';
import 'package:flutter_sendbird_fcm/screens/landing_screen.dart';
import 'package:flutter_sendbird_fcm/screens/welcome_screen.dart';
import 'main.dart';


class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return CupertinoPageRoute(builder: (context) => MyApp());
      case '/Landing_Screen':
        return MaterialPageRoute(builder: (context) => LandingScreen());
      case '/welcome-screen':
        return CupertinoPageRoute(builder: (context) => WelcomeScreen());
      case '/alluser-screen':
        return CupertinoPageRoute(builder: (context) => AllUserScreen());  

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return CupertinoPageRoute(builder: (_) {
      return Scaffold(
          appBar: AppBar(title: Text("Error")),
          body: Center(
            child: Text("Page Not Found"),
          ));
    });
  }
}
