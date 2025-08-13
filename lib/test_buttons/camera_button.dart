// A screen that allows users to take a picture using a given camera.

import 'dart:async';
import 'dart:io';
import 'package:diagnosticare/test_buttons/model/test_result_cases.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'base_button.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
    required this.widgetId,
  });

  final CameraDescription camera;
  final int widgetId;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();

            if (!context.mounted) return;

            // If the picture was taken, display it on a new screen.
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  // Pass the automatically generated path to
                  // the DisplayPictureScreen widget.
                  imagePath: image.path,
                  widgetId: widget.widgetId,
                ),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),

      //Cancel button - to be worked on later, it has a weird placement
      /*
      bottomNavigationBar: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              testData[widget.widgetId] = TestResultCases.testNotDone;
            },
            icon: const Icon(Icons.cancel, color: Colors.white),
            label: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      */
    );
  }
}

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

class CameraTestButton extends BaseButton {
  final int cameraNumber;
  const CameraTestButton({
    Key? key,
    required ValueNotifier<bool> isBusyNotifier,
    required String buttonName,
    required int testId,
    required this.cameraNumber,
  }) : super(
         key: key,
         testId: testId,
         buttonName: buttonName,
         popUpName: '$buttonName Test',
         popUpDescription:
             'After pressing the start button, various permisions may be asked. After accepting them, you will need to take a picture and determine is the selected camera is functional or not in order to conclude the test.',
         isBusyNotifier: isBusyNotifier,
       );

  @override
  State<CameraTestButton> createState() => CameraTestButtonState();
}

class CameraTestButtonState extends BaseButtonState<CameraTestButton> {
  @override
  runTest({TestResultCases? param}) async {
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();

    final selectedCamera = cameras[widget.cameraNumber];

    if (context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TakePictureScreen(
            camera: selectedCamera,
            widgetId: widget.testId,
          ),
        ),
      );
    }
    setState(() {});
  }

  @override
  void onPressedFunction() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(widget.popUpName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(widget.popUpDescription),
              SizedBox(height: 10),
              if (widget.testId == 3)
                Image.asset(
                  'images/back_camera_image.png',
                  width: 150,
                  height: 150,
                )
              else if (widget.testId == 4)
                Image.asset(
                  'images/front_camera_image.png',
                  width: 150,
                  height: 150,
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
                runTest();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
