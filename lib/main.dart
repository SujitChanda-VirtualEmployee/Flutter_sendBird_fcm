import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_sendbird_fcm/constants.dart';
import 'package:flutter_sendbird_fcm/provider/auth_provider.dart';
import 'package:flutter_sendbird_fcm/provider/chat_provider.dart';
import 'package:flutter_sendbird_fcm/route.dart';
import 'package:flutter_sendbird_fcm/screens/splash_screen.dart';
import 'package:flutter_sendbird_fcm/utility/size_config.dart';
import 'package:get_storage/get_storage.dart';

import 'package:provider/provider.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

final sendbird = SendbirdSdk(appId: '05883CCA-2F39-46F2-9332-FD8B42944920');
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  prefs = await SharedPreferences.getInstance();
  quizAttemptLimit = await SharedPreferences.getInstance();

  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: kSecondaryColor,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LayoutBuilder(builder: (context, constraints) {
          return OrientationBuilder(
            builder: (context, orientation) {
              SizeConfig().init(constraints, orientation);

              return MediaQuery.of(context).size.shortestSide > 600
                  ? SplashScreen()
                  : SplashScreen();
            },
          );
        }),
        theme: AppTheme.lightTheme,
        onGenerateRoute: RouteGenerator.generateRoute,
        builder: EasyLoading.init(),
      ),
    );
  }
}
