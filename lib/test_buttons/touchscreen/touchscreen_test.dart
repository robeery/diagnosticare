import 'package:diagnosticare/app_theme/app_theme.dart';
import 'package:diagnosticare/test_buttons/model/test_result_cases.dart';
import 'package:enum_to_string/enum_to_string.dart';

import 'package:flutter/material.dart';

import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class ButtonGridScreen extends StatefulWidget {
  final int widgetId;

  const ButtonGridScreen({super.key, required this.widgetId});

  @override
  _ButtonGridScreenState createState() => _ButtonGridScreenState();
}

class _ButtonGridScreenState extends State<ButtonGridScreen> {
  static const double spacing = 2.0;
  static const Duration inactivityDuration = Duration(seconds: 15);

  late int rows;
  late int columns;
  late List<List<bool>> buttonStates;
  final Set<String> toggledDuringDrag = {};
  Timer? inactivityTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final Size screenSize = MediaQuery.of(context).size;

    const double desiredButtonWidth = 100;
    const double desiredButtonHeight = 60;

    columns = (screenSize.width / (desiredButtonWidth + spacing)).floor();
    rows = (screenSize.height / (desiredButtonHeight + spacing)).floor();

    buttonStates = List.generate(
      rows,
      (_) => List.generate(columns, (_) => false),
    );

    _startInactivityTimer(); // Start timer on screen load
  }

  void _handleButtonToggle(int row, int col) {
    setState(() {
      buttonStates[row][col] = true;
    });

    _checkAllButtonsPressed();
    _resetInactivityTimer();
  }

  void _handleDrag(Offset position) {
    final screenSize = MediaQuery.of(context).size;

    final double totalSpacingWidth = spacing * (columns - 1);
    final double totalSpacingHeight = spacing * (rows - 1);

    final double buttonWidth = (screenSize.width - totalSpacingWidth) / columns;
    final double buttonHeight = (screenSize.height - totalSpacingHeight) / rows;

    int col = (position.dx / (buttonWidth + spacing)).floor();
    int row = (position.dy / (buttonHeight + spacing)).floor();

    if (row >= 0 && row < rows && col >= 0 && col < columns) {
      final key = '$row-$col';
      if (!toggledDuringDrag.contains(key)) {
        toggledDuringDrag.add(key);
        _handleButtonToggle(row, col);
      }
    }
  }

  void _checkAllButtonsPressed() {
    bool allPressed = buttonStates.every(
      (row) => row.every((pressed) => pressed),
    );
    if (allPressed) {
      _exitScreen();
    }
  }

  void _startInactivityTimer() {
    inactivityTimer?.cancel();
    inactivityTimer = Timer(
      inactivityDuration,
      () => _exitScreen(fromTimeout: true),
    );
  }

  void _resetInactivityTimer() {
    _startInactivityTimer();
  }

  void _exitScreen({bool fromTimeout = false}) {
    if (mounted) {
      inactivityTimer?.cancel();

      if (fromTimeout) {
        testData[widget.widgetId] = TestResultCases.testFailed;
        print("Touchscreen Test failed");
      } else {
        testData[widget.widgetId] = TestResultCases.testSucceded;
        print("Touchscreen Test succeded");
      }
      saveTestData(testData);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    inactivityTimer?.cancel();
    super.dispose();
  }

  Future<void> saveTestData(List<TestResultCases> testData) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert each enum to string using Enum_to_string plugin
    List<String> stringList = testData
        .map((e) => EnumToString.convertToString(e))
        .toList();

    await prefs.setStringList('testData', stringList);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double totalSpacingWidth = spacing * (columns - 1);
    final double totalSpacingHeight = spacing * (rows - 1);

    final double buttonWidth = (screenWidth - totalSpacingWidth) / columns;
    final double buttonHeight = (screenHeight - totalSpacingHeight) / rows;

    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onPanStart: (details) {
              toggledDuringDrag.clear();
              _handleDrag(details.localPosition);
            },
            onPanUpdate: (details) {
              _handleDrag(details.localPosition);
            },
            onPanEnd: (_) {
              toggledDuringDrag.clear();
            },
            child: SizedBox.expand(
              child: Column(
                children: List.generate(rows, (row) {
                  return Row(
                    children: List.generate(columns, (col) {
                      return Padding(
                        padding: EdgeInsets.only(
                          right: col < columns - 1 ? spacing : 0,
                          bottom: row < rows - 1 ? spacing : 0,
                        ),
                        child: SizedBox(
                          width: buttonWidth,
                          height: buttonHeight,
                          child: GestureDetector(
                            onTap: () {
                              _handleButtonToggle(row, col);
                            },
                            child: Container(
                              color: buttonStates[row][col]
                                  ? AppTheme.appBarBottomBorderColor
                                  : const Color.fromARGB(255, 75, 117, 148),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
            ),
          ),

          // Exit Button (Top-left)
          Positioned(
            top: 16,
            left: 16,
            child: ClipOval(
              child: Material(
                color: Colors.black54,
                child: InkWell(
                  onTap: _exitScreen,
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



//colors  const Color.fromARGB(255, 75, 117, 148)
                              // AppTheme.appBarBottomBorderColor,