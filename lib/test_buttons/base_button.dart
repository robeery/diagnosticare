import 'package:flutter/material.dart';
import 'package:diagnosticare/app_theme/app_theme.dart';
import 'model/test_result_cases.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class BaseButton extends StatefulWidget {
  final int testId;
  final String buttonName;
  final String popUpName;
  final String popUpDescription;
  final ValueNotifier<bool> isBusyNotifier;

  const BaseButton({
    Key? key,
    required this.testId,
    required this.buttonName,
    required this.popUpName,
    required this.popUpDescription,
    required this.isBusyNotifier,
  }) : super(key: key);
}

abstract class BaseButtonState<T extends BaseButton> extends State<T> {
  TestResultCases testResult = TestResultCases.testNotDone;

  IconData getIcon(TestResultCases result) {
    return switch (result) {
      TestResultCases.testSucceded => Icons.check_box,
      TestResultCases.testFailed => Icons.close,
      TestResultCases.testNotDone => Icons.check_box_outline_blank,
    };
  }

  final ValueNotifier<bool> isBusyNotifier = ValueNotifier(false);

  //param is a possible needed variable for future tests, hence why it is an optional parameter
  runTest({TestResultCases? param});
  void onPressedFunction();

  //function that saves tests results
  Future<void> saveTestData(List<TestResultCases> testData) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert each enum to string using Enum_to_string plugin
    List<String> stringList = testData
        .map((e) => EnumToString.convertToString(e))
        .toList();

    await prefs.setStringList('testData', stringList);
  }

  //function that loads test results
  Future<List<TestResultCases>> loadTestData() async {
    final prefs = await SharedPreferences.getInstance();
    final stringList = prefs.getStringList('testData');

    if (stringList == null) {
      // return default list if nothing is saved
      return List.filled(9, TestResultCases.testNotDone);
    }
    //If the app crashes due to shared preferences loading after adding a new button, add a forced return List.filled(4, TestResultCases.testNotDone);

    return stringList
        .map(
          (e) =>
              EnumToString.fromString(TestResultCases.values, e) ??
              TestResultCases.testNotDone,
        )
        .toList();

    //return List.filled(9, TestResultCases.testNotDone);
  }

  @override
  void initState() {
    super.initState();
    _initializeTestData();
  }

  Future<void> _initializeTestData() async {
    testData = await loadTestData();
    setState(() {}); // To rebuild the widget with updated data
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.isBusyNotifier,
      builder: (context, isBusy, _) {
        return TextButton.icon(
          style: AppTheme().buttonStyle,
          onPressed: isBusy
              ? null // disables the button
              : () => onPressedFunction(),
          icon: Icon(
            getIcon(testData[widget.testId]),
            color: const Color.fromARGB(255, 242, 112, 39),
          ),
          iconAlignment: IconAlignment.end,
          label: Text(widget.buttonName),
        );
      },
    );
  }
}
//future buttons:
//gyroscope
//touchscreen
//speakers
//microphone
//camera