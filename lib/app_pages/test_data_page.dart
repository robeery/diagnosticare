import 'package:diagnosticare/app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:diagnosticare/test_buttons/model/test_result_cases.dart';

class TestDataPage extends StatelessWidget {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'images/background_aplicatie.png',
              fit: BoxFit.cover,
            ),
          ),

          // Scrollable + centered test cards
          RawScrollbar(
            thumbColor: AppTheme.appBarBottomBorderColor,
            radius: Radius.circular(10),
            thumbVisibility: true, // Optional: always show scrollbar
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TestDataCard(
                          title: 'Passed tests',
                          type: TestResultCases.testSucceded,
                        ),
                        SizedBox(height: 15),
                        TestDataCard(
                          title: 'Failed tests',
                          type: TestResultCases.testFailed,
                        ),
                        SizedBox(height: 15),
                        TestDataCard(
                          title: 'Undone tests',
                          type: TestResultCases.testNotDone,
                        ),
                      ],
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

class TestDataCard extends StatefulWidget {
  final String title;
  final TestResultCases type;
  // final int count;

  const TestDataCard({Key? key, required this.title, required this.type})
    : super(key: key);
  @override
  State<TestDataCard> createState() => _TestDataCardState();
}

class _TestDataCardState extends State<TestDataCard> {
  Color cardBorderColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case TestResultCases.testNotDone:
        cardBorderColor = Colors.white;

      case TestResultCases.testSucceded:
        cardBorderColor = Colors.greenAccent;

      case TestResultCases.testFailed:
        cardBorderColor = Colors.redAccent;
    }

    return Card(
      borderOnForeground: true, // Border shown in front of content
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cardBorderColor, width: 4),
      ),
      child: Container(
        height: 150,
        width: 150,
        color: AppTheme.seedColor,
        child: Center(child: Text('Border Front')),
      ),
    );
  }
}
