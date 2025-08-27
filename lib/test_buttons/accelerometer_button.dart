import 'package:diagnosticare/test_data_manager/test_data_manager.dart';

import 'base_button.dart';
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
    extends BaseButtonState<AccelerometerTestButton> {
  late StreamSubscription<AccelerometerEvent> subscription;
  late Completer<TestResultCases> completer = Completer<TestResultCases>();
  bool isTestRunning = false;
  Future<TestResultCases> accelerometerTest() async {
    bool xPassed = false, yPassed = false, zPassed = false;
    completer = Completer<TestResultCases>();
    bool firstAccelerometerIteration = false;
    double x = 0, y = 0, z = 0;
    //segments of old timebased implementation

    //var testStartTime = DateTime.now();
    //var timePassed = Duration();
    subscription = accelerometerEvents.listen(
      (AccelerometerEvent event) {
        //segments of old timebased implementation
        if (firstAccelerometerIteration == false) {
          firstAccelerometerIteration = true;
          x = event.x;
          y = event.y;
          z = event.z;
          print('first');
        }
        //timePassed = testStartTime.difference(event.timestamp);
        //print(timePassed.inSeconds);
        //if (timePassed.inSeconds.abs() > 7) {
        //  print("Fail");

        // subscription.cancel();
        // completer.complete(TestResultCases.testFailed);
        // }
        /*
        print('Start accelerometer test: $numberOfTests');
        numberOfTests++;
        */
        print(event);

        if (!xPassed && (event.x - x).abs() >= 2.0) xPassed = true;
        if (!yPassed && (event.y - y).abs() >= 2.0) yPassed = true;
        if (!zPassed && (event.z - z).abs() >= 2.0) zPassed = true;

        if (xPassed && yPassed && zPassed) {
          print("Success");

          subscription.cancel();
          if (!completer.isCompleted) {
            completer.complete(
              TestResultCases.testSucceded,
            ); // Return testat = 1
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
    //print(testData);
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
                'images/accelerometer_photo.png',
                width: 150,
                height: 150,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                if (!isTestRunning) {
                  Navigator.pop(context);
                } else {
                  subscription.cancel();

                  if (!completer.isCompleted) {
                    completer.complete(TestResultCases.testNotDone);
                  }

                  if (context.mounted) {
                    //
                    setState(() {
                      isTestRunning = false;
                    });
                  }

                  testData[widget.testId] = TestResultCases.testNotDone;
                  saveTestData(testData);

                  db.updateTestResultById(
                    widget.testId,
                    testData[widget.testId].toString(),
                  );
                }
              },
            ),
            TextButton(
              child: Text(!isTestRunning ? 'Start Test' : 'Fail test'),
              onPressed: () async {
                //this function needs a lot of optimization and revision, to be done later
                //one visual bug is the fact that after the press of 'Fail test' the AlertDialog updates the text into 'Start test' again before closing
                //maybe add an 500ms timer await

                if (!isTestRunning) {
                  setState(() {
                    isTestRunning = true;
                  });

                  testResult = await runTest(param: testResult);
                  testData[widget.testId] = testResult;
                  await saveTestData(testData);

                  db.updateTestResultById(
                    widget.testId,
                    testData[widget.testId].toString(),
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    setState(() {
                      isTestRunning = false;
                    });
                  }
                } else {
                  print('Fail button press');

                  subscription.cancel();

                  if (!completer.isCompleted) {
                    completer.complete(TestResultCases.testFailed);
                  }
                  testData[widget.testId] = TestResultCases.testFailed;
                  await saveTestData(testData);

                  db.updateTestResultById(
                    widget.testId,
                    testData[widget.testId].toString(),
                  );

                  if (context.mounted) {
                    setState(() {
                      isTestRunning = false;
                    });
                  }
                  isTestRunning = false;
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
