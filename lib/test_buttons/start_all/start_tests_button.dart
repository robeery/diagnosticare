import 'dart:async';
import 'package:diagnosticare/app_pages/main_page.dart';
import 'package:diagnosticare/app_theme/app_theme.dart';
import 'package:diagnosticare/test_buttons/base_button.dart';
import 'package:flutter/material.dart';

class StartTestButtons extends StatefulWidget {
  final List<GlobalKey<BaseButtonState>>? Function()? getButtonKeys;
  final ScrollController? Function()? getScrollController;

  const StartTestButtons({
    super.key,
    this.getButtonKeys,
    this.getScrollController,
  });

  @override
  State<StartTestButtons> createState() => StartTestButtonsState();
}

class StartTestButtonsState extends State<StartTestButtons> {
  static String popUpName = "Start all tests";
  static String popUpDescription =
      "This will trigger all diagnostic tests sequentially. Each test will show its own dialog and instructions.";

  void runAllTests() async {
    if (!mounted) {
      print("widget not mounted runAllTests functions");
      return;
    }
    // Get button keys when we actually need them
    final buttonKeys = widget.getButtonKeys?.call();
    print("$buttonKeys");

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
    //BUG1: STEREO SOUND, MULTITOUCH AND TOUCHSCREEN RETURN BUTTONSTATE NULL, INVESTIGATE WHY
    //BUG2: MAKE ALL FUNCTIONS onPressed() peste tot de tip Future<void> .. await, maybe this will fix the sloppyness
    //BUG2: that fixed it
    //BUG1: they return null because the Buttons are generated lazy, FIX1: don't generate them lazy // FIX2: scroll to each one
    //investigate code more
    try {
      // Run each test and wait for it to complete
      print(buttonKeys.length);
      for (int i = 0; i < buttonKeys.length; i++) {
        // First, try to scroll to make the button visible

        await _scrollToButton(
          i,
        ); // <-- HERE: Scroll to each button before testing

        // Small delay to ensure the widget is built
        await Future.delayed(const Duration(milliseconds: 300));
        final buttonState = buttonKeys[i].currentState;
        if (buttonState == null)
          print(
            "i= $i ; buttonState = $buttonState ; buttonKeys[i] = ${buttonKeys[i]};}",
          );
        if (buttonState != null && mounted) {
          print('Starting test ${i + 1}: ${buttonState.widget.buttonName}');

          // Call the button's onPressedFunction to show the dialog
          await buttonState.onPressedFunction();

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
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> _scrollToButton(int index) async {
    print("_scrollToButton for index $index");

    try {
      // Get the scroll controller directly from the callback
      final scrollController = widget.getScrollController?.call();

      if (scrollController == null) {
        print('scrollController is null - skipping scroll');
        return;
      }

      if (!scrollController.hasClients) {
        print('scrollController has no clients - skipping scroll');
        return;
      }

      // Calculate target position
      final targetOffset = index * 145.0;
      final maxExtent = scrollController.position.maxScrollExtent;
      final safeTargetOffset = targetOffset.clamp(0.0, maxExtent);

      print("Smoothly scrolling to offset $safeTargetOffset");

      // Use animateTo for smooth transition
      await scrollController.animateTo(
        safeTargetOffset,
        duration: const Duration(milliseconds: 200), // Smooth 800ms animation
        curve: Curves.easeInOut, // Nice easing curve
      );

      // Short delay after animation completes
      // await Future.delayed(const Duration(milliseconds: 100));

      print("Smooth scroll completed for index $index");
    } catch (e) {
      print("Error scrolling: $e - continuing anyway");
      // Don't rethrow, just continue
    }
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
