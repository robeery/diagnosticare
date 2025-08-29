import 'package:diagnosticare/test_buttons/abstract/base_button.dart';
import 'package:flutter/material.dart';

abstract class AutomaticTestButtonState<T extends BaseButton>
    extends BaseButtonState<T> {
  bool isTestRunning = false;
  Future<void> onPressedStartTest(StateSetter dialogSetState);
  Future<void> onPressedCancel();

  @override
  Future<void> onPressedFunction() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, dialogSetState) => AlertDialog(
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
            TextButton(onPressed: onPressedCancel, child: const Text('Cancel')),
            TextButton(
              onPressed: () => onPressedStartTest(dialogSetState),
              child: Text(!isTestRunning ? 'Start Test' : 'Fail test'),
            ),
          ],
        ),
      ),
    );
  }
}
