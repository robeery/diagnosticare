import 'package:diagnosticare/app_theme/app_theme.dart';
import 'package:diagnosticare/test_data_manager/test_data_manager.dart';
import 'package:flutter/material.dart';
import 'package:diagnosticare/test_buttons/model/test_result_cases.dart';

class TestDataPage extends StatelessWidget {
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

  const TestDataCard({Key? key, required this.title, required this.type})
    : super(key: key);
  @override
  State<TestDataCard> createState() => _TestDataCardState();
}

class _TestDataCardState extends State<TestDataCard> {
  Color cardBorderColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    var db = TestDataManager();
    final testNames = [
      for (int i = 0; i < db.testDataList.length; i++) db.testDataList[i].name,
    ];

    final filteredTestResults = [
      for (int i = 1; i < db.testDataList.length; i++)
        if (db.testDataList[i].testResult == widget.type.toString())
          testNames[i],
    ];

    switch (widget.type) {
      case TestResultCases.testNotDone:
        cardBorderColor = Colors.white60;

      case TestResultCases.testSucceded:
        cardBorderColor = Colors.greenAccent;

      case TestResultCases.testFailed:
        cardBorderColor = Colors.redAccent;
    }

    return Card(
      color: AppTheme.seedColor,
      borderOnForeground: true, // Border shown in front of content
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cardBorderColor, width: 4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              widget.title,
              style: TextStyle(
                color: cardBorderColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),

            // Content: list of test items or a default message
            if (filteredTestResults.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: filteredTestResults
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Text(
                          "• $item",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
              )
            else
              Text("No tests available.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
