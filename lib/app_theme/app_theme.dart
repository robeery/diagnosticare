import 'package:flutter/material.dart';

class AppTheme {
  //static const Color seedColor = Color.fromARGB(255, 58, 96, 124);
  static const Color seedColor = Color.fromARGB(255, 58, 96, 124);

  static const Color appBarBackground = Color.fromARGB(255, 145, 154, 160);
  static const Color appBarTitleColor = Colors.white;
  //static const Color appBarBottomBorderColor = Colors.orange;
  static const Color appBarBottomBorderColor = Color.fromARGB(
    255,
    242,
    112,
    39,
  );
  static ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: seedColor, primary: seedColor),
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.green,
    appBarTheme: const AppBarTheme(
      backgroundColor: seedColor,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    buttonTheme: ButtonThemeData(buttonColor: seedColor),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppTheme.seedColor,
      indicatorColor: AppTheme.appBarBottomBorderColor,
      labelTextStyle: MaterialStateProperty.all(
        const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      iconTheme: MaterialStateProperty.all(
        const IconThemeData(color: Colors.white),
      ),
    ),
  );

  ButtonStyle buttonStyle = TextButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: seedColor,
    fixedSize: const Size(250, 100),
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      side: BorderSide(color: Color.fromARGB(255, 242, 112, 39), width: 1),
    ),
  );
}
