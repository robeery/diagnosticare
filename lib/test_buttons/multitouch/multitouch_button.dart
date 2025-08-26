import 'package:diagnosticare/test_buttons/model/test_result_cases.dart';
import 'package:diagnosticare/test_buttons/multitouch/multitouch_test.dart';

import 'package:flutter/material.dart';
import '../base_button.dart';

class MultiTouchTestButton extends BaseButton {
  const MultiTouchTestButton({Key? key})
    : super(
        key: key,
        testId: 9,
        buttonName: 'Multitouch',
        popUpName: 'Multitouch Test',
        popUpDescription:
            'After pressing the start button, you will be taken to two pages split in half. In order to successfully test the multitouch feature, touch with your fingers simultaneously both sides of the screen. If any given side cannot be pressed, the test will fail after 15 seconds of inactivity.',
      );

  @override
  State<MultiTouchTestButton> createState() => MultiTouchTestButtonState();
}

class MultiTouchTestButtonState extends BaseButtonState<MultiTouchTestButton> {
  @override
  runTest({TestResultCases? param}) async {
    if (context.mounted) {
      //print('PUSH');
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MultiTouchTestScreen(widgetId: widget.testId),
        ),
      );
    }
    //print('multitouch test finish');
    setState(() {});
  }

  @override
  Future<void> onPressedFunction() async {
    bool startTest;
    startTest = await showDialog(
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
                Navigator.pop(context, false);
              },
            ),
            TextButton(
              child: const Text('Start test'),
              onPressed: () async {
                Navigator.pop(context, true);
                //await runTest();

                //Navigator.pop(context);

                //putting a Navigator.pop() after runTest() will cause a blackscreen
                //the following logs occur only when starting all tests button
                //manual pressing does not reveal this in the debug log
                //to be investigated/fixed later
                //Error running tests: setState() called after dispose(): StartTestButtonsState#f5cd5(lifecycle state: defunct, not mounted)
                //I/flutter (14444): This error happens if you call setState() on a State object for a widget that no longer appears in the widget tree (e.g., whose parent widget no longer includes the widget in its build). This error can occur when code calls setState() from a timer or an animation callback.
                //I/flutter (14444): The preferred solution is to cancel the timer or stop listening to the animation in the dispose() callback. Another solution is to check the "mounted" property of this object before calling setState() to ensure the object is still in the tree.
                //I/flutter (14444): This error might indicate a memory leak if setState() is being called because another object is retaining a reference to this State object after it has been removed from the tree. To avoid memory leaks, consider breaking the reference to this object during dispose().
              },
            ),
          ],
        ),
      ),
    );
    if (startTest == true) {
      await runTest();
    }
  }
}
