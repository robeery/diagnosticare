import 'dart:async';
import 'package:diagnosticare/app_theme/app_theme.dart';
import 'package:flutter/material.dart';

class MultiTouchTestScreen extends StatefulWidget {
  const MultiTouchTestScreen({super.key});

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
        // Delay exit to after frame to avoid setState conflicts
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _exitScreen(success: true);
        });
      }
    }
  }

  void _exitScreen({required bool success}) {
    if (!mounted) return;

    _inactivityTimer?.cancel();

    // Check if can pop; if not, maybe push replacement or show dialog
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(success);
      print("_exitScreen -> POP");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVertical = currentStage == TouchTestStage.vertical;

    return Scaffold(
      body: Listener(
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
    );
  }
}
