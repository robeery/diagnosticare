import 'dart:async';
import 'dart:io';
import 'package:diagnosticare/test_buttons/model/test_result_cases.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final int widgetId;
  const DisplayPictureScreen({
    super.key,
    required this.imagePath,
    required this.widgetId,
  });

  //function that saves tests results
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
      body: Stack(
        children: [
          Image.file(File(imagePath)),
          Align(
            alignment: Alignment.bottomCenter,
            heightFactor: 14.1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 100.0,
              children: [
                TextButton.icon(
                  onPressed: () {
                    testData[widgetId] = TestResultCases.testFailed;
                    saveTestData(testData);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  label: Text('No', style: TextStyle(color: Colors.white)),
                ),
                TextButton.icon(
                  onPressed: () {
                    testData[widgetId] = TestResultCases.testSucceded;
                    saveTestData(testData);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  label: Text('Yes', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
