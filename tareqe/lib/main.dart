import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tareqe/models/DAO.dart';
import 'package:tareqe/models/theme.dart';
import 'package:tareqe/screens/login.dart';
import 'package:tareqe/screens/mapPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('ar')],
      path:
        'assets/translations', // <-- change the path of the translations files
      fallbackLocale: Locale('en'),
      child: MyApp(),),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      title: '3Tareqe',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          color: appTheme.mainColor
        ),
        primaryColor: appTheme.mainColor
      ),
      home: const MyHomePage(title: '3Tareqe'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(milliseconds: 2500), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => const sessionHandler()),
      );
    });
    return Container(
      color: Colors.white,
      child: Center(
        child: Container(
          width: 250,
          height: 250,
          child: Image.asset(
            "assets/images/3tareqe_splash.gif",
          ),
        ),
      ),
    );
  }
}
