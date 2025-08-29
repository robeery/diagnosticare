import 'package:diagnosticare/test_buttons/abstract/automatic_test_button.dart';

import 'abstract/base_button.dart';
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

class GyroscopeButtonState extends AutomaticTestButtonState<GyroscopeButton> {
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
  String getImagePath() {
    return 'images/gyroscope_photo.png';
  }

  @override
  Future<void> onPressedCancel() async {
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
  }

  @override
  Future<void> onPressedStartTest(StateSetter dialogSetState) async {
    //this function may need a lot of optimization and revision, to be done later

    if (!isTestRunning) {
      dialogSetState(() {
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
  }
}
