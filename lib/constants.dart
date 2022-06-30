import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

const logoTag = "logoTag";
const kSecondaryColor = Color(0xFF37a7a0);
const kGreenColor = Color(0xFF6AC259);
const kRedColor = Color(0xFFE92E30);
const kGrayColor = Color(0xFFC1C1C1);
const kBlackColor = Color(0xFF101010);
const kPrimaryGradient = LinearGradient(
  colors: [Color(0xFF46A0AE), Color(0xFF00FFCB)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);
const double kDefaultPadding = 20.0;
SharedPreferences? prefs;
SharedPreferences? quizAttemptLimit;
const primaryColor = Color(0xFF1b4772);
const secondaryColor = Color(0xFF37a7a0);
const bgColor = Color(0xFF212332);

const kPageViewTextStyle = TextStyle(
  fontSize: 25,
  fontWeight: FontWeight.w700,
);

enum AniProps { opacity, translateY, height, weight, translateX }

final headingStyle = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.bold,
  color: Colors.black,
  height: 1.5,
);

Widget customButton({
  required BuildContext context,
  required Function() onPressed,
  required String title,
  Color btnColor = primaryColor,
  double letterSpacing = 4,
  double buttonRadius = 8,
  double leftPadding = 15,
  double rightPadding = 15,
  IconData? icon,
}) {
  return Padding(
    padding: EdgeInsets.only(left: leftPadding, right: rightPadding),
    child: Container(
      height: 45,

      // width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          enableFeedback: true,
          padding: EdgeInsets.all(0),
          shape: RoundedRectangleBorder(

              // side: BorderSide(color: bgColor, width: 0.0),
              borderRadius: BorderRadius.circular(buttonRadius)),
          elevation: 1,
          primary: Colors.transparent,
        ),
        onPressed: onPressed,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(buttonRadius),
            ),
            border: Border.all(color: Colors.black, width: 0.3),
            // image: DecorationImage(
            //     image: AssetImage("assets/buttonSkin.png"),
            //     fit: BoxFit.cover)
          ),
          child: Container(
            decoration: BoxDecoration(
              color: btnColor,
              borderRadius: BorderRadius.all(
                Radius.circular(buttonRadius),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 10),
                Text(title,
                    style:
                        shadowbodyText1(context, size: 18, letterSpacing: 4)),
                if (icon != null) Container(width: 10),
                if (icon != null)
                  Icon(
                    icon,
                    size: 25,
                    color: Colors.white,
                  ),
                Container(width: 10),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

TextStyle shadowbodyText1(
  context, {
  double? size,
  double? letterSpacing,
  Color? textColor,
  Color? shadowColor,
  String? fontFamity,
}) {
  return Theme.of(context).textTheme.bodyText1!.copyWith(
      fontSize: size,
      letterSpacing: letterSpacing ?? 0.8,
      fontFamily: fontFamity,
      shadows: [
        BoxShadow(
            color: shadowColor ?? Colors.black,
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(0.7, 0.7))
      ],
      color: textColor ?? Colors.white,
      fontWeight: FontWeight.bold);
}

// Form Error
final RegExp emailValidatorRegExp =
    RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
const String kEmailNullError = "Please Enter your email";
const String kInvalidEmailError = "Please Enter Valid Email";
const String kPassNullError = "Please Enter your password";
const String kShortPassError = "Password is too short";
const String kMatchPassError = "Passwords don't match";
const String kNamelNullError = "Please Enter your name";
const String kPhoneNumberNullError = "Please Enter your phone number";
const String kAddressNullError = "Please Enter your address";

Widget glassLoading() {
  return new ClipRect(
    child: new BackdropFilter(
      filter: new ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
      child: new Container(
          width: double.infinity,
          height: double.infinity,
          decoration:
              new BoxDecoration(color: Colors.grey.shade200.withOpacity(0.5)),
          child: Center(
            child: new Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      //color: Colors.blue.withOpacity(0.3),
                      color: Colors.grey.shade400,
                      blurRadius: 3,
                      spreadRadius: 2,
                      offset: Offset(0.7, 0.7),
                    )
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  color: Colors.black87),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitCircle(
                    color: Colors.white,
                    size: 60,
                  ),
                  SizedBox(height: 10),
                  Text("Please wait...", style: TextStyle(color: Colors.white)),
                ],
              ),
              //  CupertinoActivityIndicator(
              //   animating: true,
              //   radius: 20,

              //   // valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              //   // strokeWidth: 2,
              // ),
            ),
          )),
    ),
  );
}
