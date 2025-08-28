import 'dart:async';
import 'package:diagnosticare/app_theme/app_theme.dart';
import 'package:diagnosticare/test_buttons/model/test_result_cases.dart';
import 'package:diagnosticare/test_data_manager/test_data_manager.dart';
import 'package:flutter/material.dart';

class MultiTouchTestScreen extends StatefulWidget {
  final int widgetId;
  const MultiTouchTestScreen({super.key, required this.widgetId});

  @override
  State<MultiTouchTestScreen> createState() => _MultiTouchTestScreenState();
}

enum TouchTestStage { vertical, horizontal }

class _MultiTouchTestScreenState extends State<MultiTouchTestScreen> {
  TouchTestStage currentStage = TouchTestStage.vertical;

  final Map<int, Offset> activePointers = {};

  Timer? _inactivityTimer;
  static const Duration _timeoutDuration = Duration(seconds: 15);

  bool isLeftOrTopPressed = false;
  bool isRightOrBottomPressed = false;

  @override
  void initState() {
    super.initState();
    _startInactivityTimer();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(
      _timeoutDuration,
      () => _exitScreen(success: false),
    );
  }

  void _resetInactivityTimer() {
    _startInactivityTimer();
  }

  void _onPointerDown(PointerDownEvent event) {
    activePointers[event.pointer] = event.localPosition;
    _updatePressedStates();
    _checkIfBothSidesTouched();
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (activePointers.containsKey(event.pointer)) {
      activePointers[event.pointer] = event.localPosition;
      _updatePressedStates();
      _checkIfBothSidesTouched();
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    activePointers.remove(event.pointer);
    _updatePressedStates();
  }

  void _updatePressedStates() {
    final size = MediaQuery.of(context).size;
    final isVertical = currentStage == TouchTestStage.vertical;

    bool leftOrTop = false;
    bool rightOrBottom = false;

    for (final position in activePointers.values) {
      if (isVertical) {
        if (position.dx < size.width / 2) {
          leftOrTop = true;
        } else {
          rightOrBottom = true;
        }
      } else {
        if (position.dy < size.height / 2) {
          leftOrTop = true;
        } else {
          rightOrBottom = true;
        }
      }
    }

    setState(() {
      isLeftOrTopPressed = leftOrTop;
      isRightOrBottomPressed = rightOrBottom;
    });
  }

  void _checkIfBothSidesTouched() {
    _resetInactivityTimer();

    if (isLeftOrTopPressed && isRightOrBottomPressed) {
      if (currentStage == TouchTestStage.vertical) {
        setState(() {
          currentStage = TouchTestStage.horizontal;
          activePointers.clear();
          isLeftOrTopPressed = false;
          isRightOrBottomPressed = false;
        });
        _startInactivityTimer();
      } else {
        //navigator.pop() issues fix contribution
        // Delay exit to after frame to avoid setState conflicts
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _exitScreen(success: true);
        });
      }
    }
  }

  void _exitScreen({required bool success}) {
    var testResult;
    if (!mounted) return;
    if (success) {
      testResult = TestResultCases.testSucceded;
    } else {
      testResult = TestResultCases.testFailed;
    }

    var db = TestDataManager();
    db.updateTestResultById(widget.widgetId, testResult.toString());
    _inactivityTimer?.cancel();

    if (Navigator.of(context).canPop()) {
      print("_exitScreen -> POP");
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVertical = currentStage == TouchTestStage.vertical;

    return Scaffold(
      body: Stack(
        children: [
          Listener(
            onPointerDown: _onPointerDown,
            onPointerMove: _onPointerMove,
            onPointerUp: _onPointerUp,
            child: Flex(
              direction: isVertical ? Axis.horizontal : Axis.vertical,
              children: [
                Expanded(
                  child: Container(
                    color: AppTheme.seedColor,
                    child: Center(
                      child: Text(
                        'Touch Here',
                        style: TextStyle(
                          color: isLeftOrTopPressed
                              ? AppTheme.appBarBottomBorderColor
                              : Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: isVertical ? 2 : double.infinity,
                  height: isVertical ? double.infinity : 2,
                  color: AppTheme.appBarBottomBorderColor,
                ),
                Expanded(
                  child: Container(
                    color: AppTheme.seedColor,
                    child: Center(
                      child: Text(
                        'And Here',
                        style: TextStyle(
                          color: isRightOrBottomPressed
                              ? AppTheme.appBarBottomBorderColor
                              : Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: ClipOval(
              child: Material(
                color: Colors.black54,
                child: InkWell(
                  onTap: () {
                    _inactivityTimer?.cancel();
                    Navigator.pop(context);
                  },
                  child: const SizedBox(
                    width: 36,
                    height: 36,
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
