import 'package:diagnosticare/test_buttons/abstract/base_button.dart';
import 'package:flutter/material.dart';

abstract class ManualTestButtonState<T extends BaseButton>
    extends BaseButtonState<T> {
  @override
  Future<void> onPressedFunction() async {
    bool? startTest;
    startTest = await showDialog(
      context: context,
      barrierDismissible: false,

      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text(getPopUpName()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(getPopUpDescription()),
            SizedBox(height: 10),
            Image.asset(getImagePath(), width: 150, height: 150),
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
            },
          ),
        ],
      ),
    );

    if (startTest == true) {
      await runTest();
    }
  }
}
