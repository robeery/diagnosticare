import 'package:diagnosticare/app_theme/app_theme.dart';
import 'package:diagnosticare/test_buttons/model/test_result_cases.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResetTestDataButton extends StatelessWidget {
  static String popUpName = "Reset all test data";
  static String popUpDescription =
      "This will reset all test data stored on the device. Are you sure this is what you want to do?";

  late Set<void> Function() callback;
  ResetTestDataButton(Set<void> Function() param0) {
    callback = param0;
  }

  void resetData() async {
    for (int i = 0; i < testData.length; i++) {
      testData[i] = TestResultCases.testNotDone;
    }
    await saveTestData(testData);
    callback.call();
  }

  Future<void> saveTestData(List<TestResultCases> testData) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert each enum to string using Enum_to_string plugin
    List<String> stringList = testData
        .map((e) => EnumToString.convertToString(e))
        .toList();

    await prefs.setStringList('testData', stringList);
  }

  void onPressedFunctionReset(BuildContext context) {
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
              child: const Text('Reset data'),
              onPressed: () {
                Navigator.pop(context);
                resetData();
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
        onPressed: () => onPressedFunctionReset(context),
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shape: CircleBorder(),
          padding: EdgeInsets.all(4),
          backgroundColor: AppTheme.seedColor,
          foregroundColor: Colors.white,
          side: BorderSide(color: AppTheme.appBarBottomBorderColor, width: 2),
        ),
        child: Icon(Icons.delete_forever_sharp, size: 24),
      ),
    );
  }
}
