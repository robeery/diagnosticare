import 'package:diagnosticare/app_theme/app_theme.dart';
import 'package:flutter/material.dart';

class StartTestButtons extends StatefulWidget {
  const StartTestButtons({super.key});

  @override
  State<StartTestButtons> createState() => StartTestButtonsState();
}

class StartTestButtonsState extends State<StartTestButtons> {
  static String popUpName = "Start all tests";
  static String popUpDescription = "blabla";

  void onPressedFunction() {
    print("apasat");
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(popUpName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[Text(popUpDescription)],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Start test'),
              onPressed: () {
                //runTest();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 0.0),
      child: ElevatedButton(
        onPressed: onPressedFunction,
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shape: CircleBorder(),
          padding: EdgeInsets.all(4),
          backgroundColor: AppTheme.seedColor,
          foregroundColor: Colors.white,
          side: BorderSide(color: AppTheme.appBarBottomBorderColor, width: 2),
        ),
        child: Icon(Icons.play_arrow, size: 24),
      ),
    );
  }
}
