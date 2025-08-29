import 'package:diagnosticare/test_buttons/abstract/automatic_test_button.dart';
import 'package:diagnosticare/test_data_manager/test_data_manager.dart';

import 'abstract/base_button.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'model/test_result_cases.dart';

class AccelerometerTestButton extends BaseButton {
  const AccelerometerTestButton({Key? key})
    : super(
        key: key,
        testId: 1,
        buttonName: 'Accelerometer',
        popUpName: 'Accelerometer Test',
        popUpDescription:
            'After pressing the start button, please shake your phone in order to test the accelerometer.',
      );

  @override
  State<AccelerometerTestButton> createState() =>
      AccelerometerTestButtonState();
}

class AccelerometerTestButtonState
    extends AutomaticTestButtonState<AccelerometerTestButton> {
  late StreamSubscription<AccelerometerEvent> subscription;
  late Completer<TestResultCases> completer = Completer<TestResultCases>();

  Future<TestResultCases> accelerometerTest() async {
    bool xPassed = false, yPassed = false, zPassed = false;
    completer = Completer<TestResultCases>();
    bool firstAccelerometerIteration = false;
    double x = 0, y = 0, z = 0;

    subscription = accelerometerEvents.listen(
      (AccelerometerEvent event) {
        if (firstAccelerometerIteration == false) {
          firstAccelerometerIteration = true;
          x = event.x;
          y = event.y;
          z = event.z;
          print('first');
        }

        print(event);

        if (!xPassed && (event.x - x).abs() >= 2.0) xPassed = true;
        if (!yPassed && (event.y - y).abs() >= 2.0) yPassed = true;
        if (!zPassed && (event.z - z).abs() >= 2.0) zPassed = true;

        if (xPassed && yPassed && zPassed) {
          print("Success");

          subscription.cancel();
          if (!completer.isCompleted) {
            completer.complete(TestResultCases.testSucceded);
          }
        }
      },
      onError: (error) {
        print("Accelerometer error: $error");

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
    TestResultCases testResult = await accelerometerTest();

    //print("@runTest -> accelemeter_button $testResult");
    //print("Accelerometru testId -> ${widget.testId}");

    setState(() {});
    return testResult;
  }

  @override
  String getImagePath() {
    return 'images/accelerometer_photo.png';
  }

  @override
  Future<void> onPressedStartTest(StateSetter dialogSetState) async {
    //this function may need a lot of optimization and revision, to be done later

    if (super.isTestRunning == false) {
      dialogSetState(() {
        super.isTestRunning = true;
      });

      testResult = await runTest(param: testResult);
      db.updateTestResultById(widget.testId, testResult.toString());

      if (context.mounted) {
        Navigator.pop(context);

        super.isTestRunning = false;
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

  @override
  Future<void> onPressedCancel() async {
    if (!super.isTestRunning) {
      Navigator.pop(context);
      var db = TestDataManager();
      /*
                  db.printTestDataList();
                  db.printAllTestData();
                  */
    } else {
      subscription.cancel();

      if (!completer.isCompleted) {
        completer.complete(TestResultCases.testNotDone);
      }

      if (context.mounted) {
        setState(() {
          super.isTestRunning = false;
        });
      }

      testResult = TestResultCases.testNotDone;

      db.updateTestResultById(widget.testId, testResult.toString());
      setState(() {});
    }
  }
}
