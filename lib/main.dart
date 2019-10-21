import 'package:flutter/material.dart';
import 'package:siska/constant/Constant.dart';
import 'package:siska/views/home.dart';
import 'package:siska/views/splashscreen.dart';
import 'package:siska/views/login.dart';
import 'package:siska/views/job.dart';
import 'package:siska/views/Profile.dart';
import 'package:siska/views/detail.dart';
import 'package:siska/views/main_tab.dart';


void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      theme: new ThemeData(primaryColor: Colors.blue,
      ),
      routes: <String, WidgetBuilder>{
        SPLASH_SCREEN: (BuildContext context) => SplashScreen(),
        PAY_TM: (BuildContext context) => MainTab(),
        LOGIN_SCREEN: (BuildContext context) => LoginScreen(),
        JOB_SCREEN : (BuildContext context) => Job(),
        PROFILE : (BuildContext context) => Profile()
      },
    );
  }
}
