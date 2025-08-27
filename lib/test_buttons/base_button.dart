import 'dart:developer';

import 'package:diagnosticare/test_data_manager/test_data_manager.dart';
import 'package:flutter/material.dart';
import 'package:diagnosticare/app_theme/app_theme.dart';
import 'model/test_result_cases.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diagnosticare/test_data_manager/test_data_manager.dart';

abstract class BaseButton extends StatefulWidget {
  final int testId;
  final String buttonName;
  final String popUpName;
  final String popUpDescription;

  const BaseButton({
    Key? key,
    required this.testId,
    required this.buttonName,
    required this.popUpName,
    required this.popUpDescription,
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

  //param is a possible needed variable for future tests, hence why it is an optional parameter
  runTest({TestResultCases? param});
  Future<void> onPressedFunction();

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
      return List.filled(10, TestResultCases.testNotDone);
    }
    //If the app crashes due to shared preferences loading after adding a new button, add a forced return List.filled(4, TestResultCases.testNotDone);

    return stringList
        .map(
          (e) =>
              EnumToString.fromString(TestResultCases.values, e) ??
              TestResultCases.testNotDone,
        )
        .toList();

    //return List.filled(10, TestResultCases.testNotDone);
  }

  @override
  void initState() {
    super.initState();
    _initializeTestData();
    //loading each button as it is built/reloaded
    //this might cause issues because firstly it may not work with a lazy implementation
    //second of all we repopulate every time the buttons are loaded which is problematic even without a lazy builder
    //every time we enter the 'home' page
    /*
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final state = this;
      final data = TestData(
        id: state.widget.testId,
        name: state.widget.buttonName,
        testResult: 'testNotDone',
        additionalData: '-',
      );
      log("base button init");
      await TestDataManager().insertTestData(data);
    });
    */
  }

  Future<void> _initializeTestData() async {
    var db = TestDataManager();
    await db.loadTestDataListFromDB();
    log(db.testDataList[1].testResult);
    testData = await loadTestData();

    setState(() {}); // To rebuild the widget with updated data
  }

  var db = TestDataManager();
  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: AppTheme().buttonStyle,
      onPressed: () => onPressedFunction(),
      icon: Icon(
        // getIcon(testData[widget.testId]),
        getIcon(
          EnumToString.fromString(
                TestResultCases.values,
                db.testDataList[widget.testId].testResult.split('.').last,
              ) ??
              TestResultCases.testNotDone,
        ),

        color: const Color.fromARGB(255, 242, 112, 39),
      ),
      iconAlignment: IconAlignment.end,
      label: Text(widget.buttonName),
    );
  }
}
