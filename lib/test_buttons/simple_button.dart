import 'package:flutter/material.dart';
import 'base_button.dart';
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
    print(testData.length);
    return testResult;
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

    testResult = await runTest(param: testResult);
    testData[widget.testId] = testResult;

    saveTestData(testData);

    setState(() {});
  }
}
