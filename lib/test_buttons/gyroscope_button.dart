import 'package:diagnosticare/test_data_manager/test_data_manager.dart';

import 'base_button.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'model/test_result_cases.dart';

class GyroscopeButton extends BaseButton {
  const GyroscopeButton({Key? key})
    : super(
        key: key,
        testId: 2,
        buttonName: 'Gyroscope',
        popUpName: 'Gyroscope Test',
        popUpDescription:
            'After pressing the start button, please twist your wrist in a circular motion with your phone in your hand in order to test the gyroscope.',
      );

  @override
  State<GyroscopeButton> createState() => GyroscopeButtonState();
}

class GyroscopeButtonState extends BaseButtonState<GyroscopeButton> {
  late StreamSubscription<GyroscopeEvent> subscription;
  late Completer<TestResultCases> completer = Completer<TestResultCases>();
  bool isTestRunning = false;
  Future<TestResultCases> gyroscopeTest() async {
    bool xPassed = false, yPassed = false, zPassed = false;
    completer = Completer<TestResultCases>();

    subscription = gyroscopeEvents.listen(
      (GyroscopeEvent event) {
        if (!xPassed && event.x.abs() >= 1.0) xPassed = true;
        if (!yPassed && event.y.abs() >= 1.0) yPassed = true;
        if (!zPassed && event.z.abs() >= 1.0) zPassed = true;

        if (xPassed && yPassed && zPassed) {
          print("Success");

          subscription.cancel();
          if (!completer.isCompleted) {
            completer.complete(TestResultCases.testSucceded);
          }
        }
      },
      onError: (error) {
        print("Gyroscope error: $error");

        subscription.cancel();
        if (!completer.isCompleted) {
          completer.complete(TestResultCases.testFailed);
        }
      },
      cancelOnError: true,
    );

    return completer.future;
  }

  @override
  Future<TestResultCases> runTest({TestResultCases? param}) async {
    TestResultCases testResult = await gyroscopeTest();

    //print("@runTest -> gyroscope_button $testResult");
    //print("Gyroscope testId -> ${widget.testId}");
    setState(() {});
    return testResult;
  }

  @override
  Future<void> onPressedFunction() async {
    var db = TestDataManager();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          scrollable: true,
          title: Text(widget.popUpName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(widget.popUpDescription),
              SizedBox(height: 10),
              Image.asset(
                'images/gyroscope_photo.png',
                width: 150,
                height: 150,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                db.deleteAllTestData();
                if (!isTestRunning) {
                  Navigator.pop(context);
                } else {
                  subscription.cancel();

                  if (!completer.isCompleted) {
                    completer.complete(TestResultCases.testNotDone);
                  }

                  testResult = TestResultCases.testNotDone;

                  db.updateTestResultById(widget.testId, testResult.toString());

                  isTestRunning = false;
                }
              },
            ),
            TextButton(
              child: Text(!isTestRunning ? 'Start Test' : 'Fail test'),
              onPressed: () async {
                //this function may need a lot of optimization and revision, to be done later

                if (!isTestRunning) {
                  setState(() {
                    isTestRunning = true;
                  });

                  testResult = await runTest(param: testResult);

                  db.updateTestResultById(widget.testId, testResult.toString());

                  if (context.mounted) {
                    Navigator.pop(context);

                    isTestRunning = false;
                  }
                } else {
                  //print('Fail button press');

                  subscription.cancel();

                  if (!completer.isCompleted) {
                    completer.complete(TestResultCases.testFailed);
                  }
                  testResult = TestResultCases.testFailed;

                  db.updateTestResultById(widget.testId, testResult.toString());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
