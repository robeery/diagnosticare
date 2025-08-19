import 'package:diagnosticare/test_buttons/model/test_result_cases.dart';
import 'package:diagnosticare/test_buttons/multitouch/multitouch_test.dart';

import 'package:flutter/material.dart';
import '../base_button.dart';

class MultiTouchTestButton extends BaseButton {
  const MultiTouchTestButton({
    Key? key,
    required ValueNotifier<bool> isBusyNotifier,
  }) : super(
         key: key,
         testId: 9,
         buttonName: 'Multitouch',
         popUpName: 'Multitouch Test',
         popUpDescription:
             'After pressing the start button, you will be taken to two pages split in half. In order to successfully test the multitouch feature, touch with your fingers simultaneously both sides of the screen. If any given side cannot be pressed, the test will fail after 15 seconds of inactivity.',
         isBusyNotifier: isBusyNotifier,
       );

  @override
  State<MultiTouchTestButton> createState() => MultiTouchTestButtonState();
}

class MultiTouchTestButtonState extends BaseButtonState<MultiTouchTestButton> {
  @override
  runTest({TestResultCases? param}) async {
    if (context.mounted) {
      print('PUSH');
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MultiTouchTestScreen(widgetId: widget.testId),
        ),
      );
    }
    print('multitouch test finish');
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
                'images/multitouch_image.png',
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
