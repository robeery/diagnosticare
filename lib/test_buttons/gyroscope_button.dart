import 'base_button.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'model/test_result_cases.dart';

class GyroscopeButton extends BaseButton {
  const GyroscopeButton({Key? key, required ValueNotifier<bool> isBusyNotifier})
    : super(
        key: key,
        testId: 2,
        buttonName: 'Gyroscope',
        popUpName: 'Gyroscope Test',
        popUpDescription:
            'After pressing the start button, please twist your wrist in a circular motion with your phone in your hand in order to test the gyroscope.',
        isBusyNotifier: isBusyNotifier,
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
    int numberOfTests = 0;
    //var testStartTime = DateTime.now();
    //var timePassed = Duration();
    subscription = gyroscopeEvents.listen(
      (GyroscopeEvent event) {
        //timePassed = testStartTime.difference(event.timestamp);
        //print(timePassed.inSeconds);
        //if (timePassed.inSeconds.abs() > 7) {
        //  print("Fail");

        // subscription.cancel();
        // completer.complete(TestResultCases.testFailed);
        // }
        print('Start gyroscope test: $numberOfTests');
        numberOfTests++;
        if (!xPassed && event.x.abs() >= 1.0) xPassed = true;
        if (!yPassed && event.y.abs() >= 1.0) yPassed = true;
        if (!zPassed && event.z.abs() >= 1.0) zPassed = true;

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
    print("@runTest -> gyroscope_button $testResult");

    print("Gyroscope testId -> ${widget.testId}");
    return testResult;
  }

  @override
  Future<void> onPressedFunction() async {
    widget.isBusyNotifier.value = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
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
                if (!isTestRunning) {
                  widget.isBusyNotifier.value = false;
                  Navigator.pop(context);
                } else {
                  subscription.cancel();

                  if (!completer.isCompleted) {
                    completer.complete(TestResultCases.testNotDone);
                  }
                  /*
                  if (context.mounted) {
                    //
                    setState(() {
                      isTestRunning = false;
                    });
                  }
                  */
                  widget.isBusyNotifier.value = false;
                  testData[widget.testId] = TestResultCases.testNotDone;
                  saveTestData(testData);
                  isTestRunning = false;
                }
              },
            ),
            TextButton(
              child: Text(!isTestRunning ? 'Start Test' : 'Fail test'),
              onPressed: () async {
                //this function needs a lot of optimization and revision, to be done later
                //one visual bug is the fact that after the press of 'Fail test' the AlertDialog updates the text into 'Start test' again before closing
                //to be fixed later
                if (!isTestRunning) {
                  setState(() {
                    //isTestRunning = isTestRunning ? false : true;
                    isTestRunning = true;
                  });

                  testResult = await runTest(param: testResult);
                  testData[widget.testId] = testResult;
                  await saveTestData(testData);

                  if (context.mounted) {
                    Navigator.pop(context);
                    setState(() {
                      //isTestRunning = false;
                    });
                    widget.isBusyNotifier.value = false;
                    isTestRunning = false;
                  }
                } else {
                  print('Fail button press');

                  subscription.cancel();

                  if (!completer.isCompleted) {
                    completer.complete(TestResultCases.testFailed);
                  }
                  testData[widget.testId] = TestResultCases.testFailed;
                  await saveTestData(testData);
                  /*
                  if (context.mounted) {
                    setState(() {
                      //if we add Navigator.pop() here the app crashes (black screen), so better don't do that
                      //Navigator.pop(context);
                      //isTestRunning = false;
                    });
                  }
                  */
                  //isTestRunning = false;
                  widget.isBusyNotifier.value = false;
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

//old gyroscope logic
/*
class GyroscopeButton extends BaseButton {
  const GyroscopeButton({Key? key, required ValueNotifier<bool> isBusyNotifier})
    : super(
        key: key,
        testId: 2,
        buttonName: 'Gyroscope',
        popUpName: 'Gyroscope Test',
        popUpDescription:
            'Please twist your wrist in a circular motion with your phone in your hand in order to test the gyroscope.',
        isBusyNotifier: isBusyNotifier,
      );

  @override
  State<GyroscopeButton> createState() => GyroscopeButtonState();
}

class GyroscopeButtonState extends BaseButtonState<GyroscopeButton> {
  
  static Future<TestResultCases> gyroscopeTest() async {
    bool xPassed = false, yPassed = false, zPassed = false;
    late StreamSubscription<GyroscopeEvent> subscription;
    Completer<TestResultCases> completer = Completer<TestResultCases>();
    var testStartTime = DateTime.now();
    var timePassed = Duration();

    subscription = gyroscopeEvents.listen(
      (GyroscopeEvent event) {
        timePassed = testStartTime.difference(event.timestamp);
        print(timePassed.inSeconds.abs());

        if (timePassed.inSeconds.abs() > 7) {
          print("Fail");

          subscription.cancel();
          completer.complete(TestResultCases.testFailed);
        }

        if (!xPassed && event.x.abs() >= 1.0) xPassed = true;
        if (!yPassed && event.y.abs() >= 1.0) yPassed = true;
        if (!zPassed && event.z.abs() >= 1.0) zPassed = true;

        if (xPassed && yPassed && zPassed) {
          print("Success");

          subscription.cancel();
          completer.complete(TestResultCases.testSucceded); // Return testat = 1
        }
      },
      onError: (error) {
        print("Gyroscope error: $error");

        subscription.cancel();
        completer.complete(TestResultCases.testFailed);
      },
      cancelOnError: true,
    );
    return completer.future;
  }

  @override
  Future<TestResultCases> runTest({TestResultCases? param}) async {
    TestResultCases testResult = await gyroscopeTest();
    print("@runTest -> gyroscope_button $testResult");
    print("Gyroscope testId -> ${widget.testId}");
    return testResult;
  }

  @override
  void onPressedFunction() async {
    widget.isBusyNotifier.value = true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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

    setState(() {});

    widget.isBusyNotifier.value = false;
  }
}
*/
