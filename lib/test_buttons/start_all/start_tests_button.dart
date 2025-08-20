import 'dart:async';
import 'package:diagnosticare/app_pages/main_page.dart';
import 'package:diagnosticare/app_theme/app_theme.dart';
import 'package:diagnosticare/test_buttons/base_button.dart';
import 'package:diagnosticare/test_buttons/model/test_result_cases.dart';
import 'package:flutter/material.dart';

class StartTestButtons extends StatefulWidget {
  final List<GlobalKey<BaseButtonState>>? Function()? getButtonKeys;

  const StartTestButtons({super.key, this.getButtonKeys});

  @override
  State<StartTestButtons> createState() => StartTestButtonsState();
}

class StartTestButtonsState extends State<StartTestButtons> {
  static String popUpName = "Start all tests";
  static String popUpDescription =
      "This will trigger all diagnostic tests sequentially. Each test will show its own dialog and instructions.";

  void runAllTests() async {
    // Get button keys when we actually need them
    final buttonKeys = widget.getButtonKeys?.call();

    if (buttonKeys == null || buttonKeys.isEmpty) {
      print("No test buttons found");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No test buttons available'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    print("Starting all tests sequentially...");
    //STEREO SOUND, MULTITOUCH AND TOUCHSCREEN RETURN BUTTONSTATE NULL, INVESTIGATE WHY
    //FIX: MAKE ALL FUNCTIONS onPressed() peste tot de tip Future<void> .. await, maybe this will fix the sloppyness
    //investigate code more
    try {
      // Run each test and wait for it to complete
      print(buttonKeys.length);
      for (int i = 0; i < buttonKeys.length; i++) {
        final buttonState = buttonKeys[i].currentState;
        print(buttonState);
        if (buttonState != null && mounted) {
          print('Starting test ${i + 1}: ${buttonState.widget.buttonName}');

          // Call the button's onPressedFunction to show the dialog
          buttonState.onPressedFunction();

          // Wait for any navigation/dialogs to complete
          // This approach waits for the modal route (dialog) to be dismissed
          await _waitForTestCompletion();

          print('Test ${i + 1} completed: ${buttonState.widget.buttonName}');
        }
      }

      print("All ${buttonKeys.length} tests have been completed");

      // Show completion message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('All ${buttonKeys.length} tests completed!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Error running tests: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error occurred while running tests'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _waitForTestCompletion() async {
    // Wait for the dialog to appear
    await Future.delayed(const Duration(milliseconds: 100));

    // Wait for all modal routes (dialogs, test screens) to be dismissed
    while (mounted && ModalRoute.of(context)?.isCurrent != true) {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Additional small delay to ensure everything is settled
    await Future.delayed(const Duration(milliseconds: 200));
  }

  void onPressedFunctionStart() {
    print("apasat");
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(popUpName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(popUpDescription),
              const SizedBox(height: 10),
              Text(
                'Total tests: ${widget.getButtonKeys?.call()?.length ?? 0}',
                style: const TextStyle(fontWeight: FontWeight.bold),
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
                runAllTests();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 0.0),
      child: ElevatedButton(
        onPressed: onPressedFunctionStart,
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shape: CircleBorder(),
          padding: EdgeInsets.all(4),
          backgroundColor: AppTheme.seedColor,
          foregroundColor: Colors.white,
          side: BorderSide(color: AppTheme.appBarBottomBorderColor, width: 2),
        ),
        child: Icon(Icons.play_arrow, size: 24),
      ),
    );
  }
}
