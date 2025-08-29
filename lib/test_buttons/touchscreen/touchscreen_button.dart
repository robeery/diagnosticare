import 'package:diagnosticare/test_buttons/abstract/manual_test_button.dart';
import 'package:diagnosticare/test_buttons/model/test_result_cases.dart';
import 'package:diagnosticare/test_buttons/touchscreen/touchscreen_test.dart';
import 'package:flutter/material.dart';
import '../abstract/base_button.dart';

class TouchScreenTestButton extends BaseButton {
  const TouchScreenTestButton({Key? key})
    : super(
        key: key,
        testId: 8,
        buttonName: 'Touchscreen',
        popUpName: 'Touchscreen Test',
        popUpDescription:
            'After pressing the start button, you will be taken to a new page filled with squares. In order to successfully test the touchscreen, touch or drag with your fingers across all squares. If any given square cannot be pressed, the test will fail after 15 seconds of inactivity.',
      );

  @override
  State<TouchScreenTestButton> createState() => TouchScreenTestButtonState();
}

class TouchScreenTestButtonState
    extends ManualTestButtonState<TouchScreenTestButton> {
  @override
  runTest({TestResultCases? param}) async {
    if (context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ButtonGridScreen(widgetId: widget.testId),
        ),
      );
    }

    setState(() {});
  }

  @override
  String getImagePath() {
    return 'images/touchscreen_image.png';
  }
}
