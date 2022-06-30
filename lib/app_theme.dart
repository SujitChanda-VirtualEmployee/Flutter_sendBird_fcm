import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static Color _iconColor = Colors.black;
  static const Color _lightPrimaryColor = Colors.blue;
  static Color _lightPrimaryVarientColor = Colors.blue;

  static Color _lightSecondaryColor = Colors.blue; // Color(0XFFe3292c);
  static const Color _lightOnPrimaryColor = Colors.black;

  static final ThemeData lightTheme = ThemeData(
    visualDensity: VisualDensity.adaptivePlatformDensity,
    scaffoldBackgroundColor: _lightPrimaryColor,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: _lightOnPrimaryColor,
      selectionColor: _lightSecondaryColor.withOpacity(0.5),
      selectionHandleColor: Colors.blue,
    ),
    appBarTheme: AppBarTheme(
      color: _lightSecondaryColor,
      iconTheme: IconThemeData(color: _lightOnPrimaryColor),
    ),
    colorScheme: ColorScheme.light(
      primary: _lightPrimaryColor,
      primaryVariant: _lightPrimaryVarientColor,
      secondary: _lightSecondaryColor,
      onPrimary: _lightOnPrimaryColor,
    ),
    iconTheme: IconThemeData(color: _iconColor, size: 30),
    textTheme: GoogleFonts.nunitoTextTheme(_lightTextTheme),
    // _lightTextTheme,
    accentColor: Colors.white.withOpacity(0.1),
  );

 

  static final TextTheme _lightTextTheme = TextTheme(
    headline6: _lightScreenHeadingTextStyle,
    bodyText1: _lightScreenTaskNameTextStyle,
    bodyText2: _lightScreenTaskDurationTextStyle,
  );

  // static final TextTheme _darkTextTheme = TextTheme(
  //   headline: _darkScreenHeadingTextStyle,
  //   body1: _darkScreenTaskNameTextStyle,
  //   body2: _darkScreenTaskDurationTextStyle,
  // );

  static final TextStyle _lightScreenHeadingTextStyle = TextStyle(
      fontFamily: "RobotoCondensed",
      fontSize: 18.0,
      
      color: _lightOnPrimaryColor,
      fontWeight: FontWeight.bold);
  static final TextStyle _lightScreenTaskNameTextStyle = TextStyle(
      fontFamily: "RobotoCondensed",
      fontSize: 15.0,
      color: _lightOnPrimaryColor,
      fontWeight: FontWeight.normal);
  static final TextStyle _lightScreenTaskDurationTextStyle = TextStyle(
      fontFamily: "RobotoCondensed",
      fontSize: 13.0,
      color: Colors.grey.shade800,
      fontWeight: FontWeight.normal);

  // static final TextStyle _darkScreenHeadingTextStyle =
  //     TextStyle(fontSize: 40.0, color: _darkOnPrimaryColor,fontWeight: FontWeight.w300);
  // static final TextStyle _darkScreenTaskNameTextStyle =
  //     TextStyle(fontSize: 18.0, color: _darkOnPrimaryColor,fontWeight: FontWeight.w400);
  // static final TextStyle _darkScreenTaskDurationTextStyle =
  //     TextStyle(fontSize: 14.0, color: Colors.white, fontWeight: FontWeight.w400);
}

List<BoxShadow> customShadow = [
  //  BoxShadow(

  //    color: Colors.white.withOpacity(0.3),
  //    blurRadius: 30,
  //    offset: Offset(-5,-5),
  //    spreadRadius: -5),

  BoxShadow(
    //color: Colors.blue.withOpacity(0.3),
    color: Colors.grey.shade400,
    blurRadius: 3,
    spreadRadius: 2,
    offset: Offset(0.7, 0.7),
  )
];

List<BoxShadow> customShadow2 = [
  BoxShadow(
      color: Colors.grey[300]!,
      blurRadius: 2,
      offset: Offset(-2, -2),
      spreadRadius: -2),
  BoxShadow(
    // color: Colors.blue.withOpacity(0.3),
    color: Colors.grey[300]!,
    blurRadius: 3,
    spreadRadius: 2,
    offset: Offset(0.2, 0.2),
  )
];

List<BoxShadow> customGreenShadow = [
  BoxShadow(
      color: Color(0XFF23b574).withOpacity(0.1),
      blurRadius: 30,
      offset: Offset(-5, -5),
      spreadRadius: -5),
  BoxShadow(
      //color: Colors.blue.withOpacity(0.3),
      color: Colors.lightGreen.withOpacity(0.1),
      spreadRadius: 2,
      offset: Offset(7, 7),
      blurRadius: 20)
];
