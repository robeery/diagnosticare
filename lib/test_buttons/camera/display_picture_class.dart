import 'dart:async';
import 'dart:io';
import 'package:diagnosticare/app_theme/app_theme.dart';
import 'package:diagnosticare/test_buttons/model/test_result_cases.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diagnosticare/test_data_manager/test_data_manager.dart';

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final int widgetId;

  const DisplayPictureScreen({
    super.key,
    required this.imagePath,
    required this.widgetId,
  });

  // Function that saves test results
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
    return Scaffold(
      appBar: AppBar(title: const Text('Is the picture clear?')),

      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Column(
        children: [
          // Image preview takes all space between AppBar and bottom bar
          Expanded(
            child: Image.file(
              File(imagePath),
              fit: BoxFit.cover, // Makes sure the image fills the space
              width: double.infinity,
            ),
          ),

          // Fixed-height confirmation bar at the bottom
          Container(
            height: 80,
            color: AppTheme.seedColor,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // Save 'test failed' result and go back
                    testData[widgetId] = TestResultCases.testFailed;
                    saveTestData(testData);
                    var db = TestDataManager();
                    db.updateTestResultById(
                      widgetId,
                      testData[widgetId].toString(),
                    );
                    Navigator.pop(context); // Close DisplayPictureScreen
                    Navigator.pop(context); // Close TakePictureScreen
                  },
                  icon: const Icon(Icons.close, color: Colors.white),
                  label: const Text(
                    'No',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Save 'test succeeded' result and go back
                    testData[widgetId] = TestResultCases.testSucceded;
                    saveTestData(testData);
                    var db = TestDataManager();
                    db.updateTestResultById(
                      widgetId,
                      testData[widgetId].toString(),
                    );
                    Navigator.pop(context); // Close DisplayPictureScreen
                    Navigator.pop(context); // Close TakePictureScreen
                  },
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text(
                    'Yes',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
