import 'package:diagnosticare/test_data_manager/test_data_manager.dart';
import 'package:flutter/material.dart';
import 'abstract/base_button.dart';
import 'model/test_result_cases.dart';

class SimpleTestButton extends BaseButton {
  const SimpleTestButton({Key? key})
    : super(
        key: key,
        testId: 0,
        buttonName: 'Buton simplu',
        popUpName: 'Buton simplu',
        popUpDescription: 'Doar un buton...',
      );

  @override
  State<SimpleTestButton> createState() => _SimpleTestButtonState();
}

class _SimpleTestButtonState extends BaseButtonState<SimpleTestButton> {
  @override
  TestResultCases runTest({TestResultCases? param}) {
    TestResultCases testResult = param == TestResultCases.testNotDone
        ? TestResultCases.testSucceded
        : TestResultCases.testNotDone;
    print(testResult);
    print("SimpleButton testId -> ${widget.testId}");

    return testResult;
  }

  @override
  String getImagePath() {
    //nothing
    return '';
  }

  @override
  Future<void> onPressedFunction() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text(widget.popUpName),
        content: Text(widget.popUpDescription),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
    var db = TestDataManager();

    db.updateTestResultById(widget.testId, testResult.toString());

    setState(() {});
  }
}
