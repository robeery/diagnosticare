import 'package:diagnosticare/test_data_manager/test_data_manager.dart';
import 'package:flutter/material.dart';
import 'package:diagnosticare/app_theme/app_theme.dart';
import '../model/test_result_cases.dart';
import 'package:enum_to_string/enum_to_string.dart';

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

  String getPopUpDescription() {
    return widget.popUpDescription;
  }

  String getTestButtonName() {
    return widget.buttonName;
  }

  String getPopUpName() {
    return widget.popUpName;
  }

  String getImagePath();

  Future<void> onPressedFunction();

  @override
  void initState() {
    super.initState();
    _initializeTestData();
  }

  Future<void> _initializeTestData() async {
    var db = TestDataManager();
    await db.loadTestDataListFromDB();

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

        /*
        getIcon(
          EnumToString.fromString(
                TestResultCases.values,
                db.testDataList[widget.testId].testResult.split('.').last,
              ) ??
              TestResultCases.testNotDone,
        ),
        */
        //this makes sure getIcon gets loaded no matter what
        getIcon(
          (widget.testId >= 0 && widget.testId < db.testDataList.length)
              ? EnumToString.fromString(
                      TestResultCases.values,
                      db.testDataList[widget.testId].testResult.split('.').last,
                    ) ??
                    TestResultCases.testNotDone
              : TestResultCases.testNotDone,
        ),

        color: const Color.fromARGB(255, 242, 112, 39),
      ),
      iconAlignment: IconAlignment.end,
      label: Text(getTestButtonName()),
    );
  }
}
