import 'package:diagnosticare/test_buttons/model/test_result_cases.dart';
import 'package:diagnosticare/test_buttons/touchscreen/touchscreen_test.dart';
import 'package:flutter/material.dart';
import '../base_button.dart';

class TouchScreenTestButton extends BaseButton {
  const TouchScreenTestButton({
    Key? key,
    required ValueNotifier<bool> isBusyNotifier,
  }) : super(
         key: key,
         testId: 8,
         buttonName: 'Touchscreen',
         popUpName: 'Touchscreen Test',
         popUpDescription:
             'After pressing the start button, you will be taken to a new page filled with squares. In order to successfully test the touchscreen, touch or drag with your fingers across all squares. If any given square cannot be pressed, the test will fail after 15 seconds of inactivity.',
         isBusyNotifier: isBusyNotifier,
       );

  @override
  State<TouchScreenTestButton> createState() => TouchScreenTestButtonState();
}

class TouchScreenTestButtonState
    extends BaseButtonState<TouchScreenTestButton> {
  @override
  runTest({TestResultCases? param}) async {
    if (context.mounted) {
      print('PUSH');
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ButtonGridScreen(widgetId: widget.testId),
        ),
      );
    }

    setState(() {});
  }

  @override
  void onPressedFunction() {
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
                'images/touchscreen_image.png',
                width: 150,
                height: 150,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Start test'),
              onPressed: () {
                Navigator.pop(context);
                runTest();
              },
            ),
          ],
        ),
      ),
    );
  }
}
