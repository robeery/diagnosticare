// A screen that allows users to take a picture using a given camera.

import 'dart:async';
import 'dart:io';
import 'package:diagnosticare/test_buttons/model/test_result_cases.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'base_button.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({super.key, required this.camera});

  final CameraDescription camera;

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
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),

      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Stack(
        children: [
          Image.file(File(imagePath)),
          Align(
            alignment: Alignment.bottomCenter,

            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 100.0,
              children: [
                TextButton.icon(onPressed: function, label: Text('buton 1')),
                TextButton.icon(onPressed: function, label: Text('buton 2')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void function() {
  print('hei');
}

class CameraTestButton extends BaseButton {
  const CameraTestButton({Key? key, required ValueNotifier<bool> isBusyNotifier})
    : super(
        key: key,
        testId: 3,
        buttonName: 'Camera',
        popUpName: 'Camera Test',
        popUpDescription:
            'After pressing the start button, please shake your phone in order to test the accelerometer.',
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
    final firstCamera = cameras.first;

    if (context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TakePictureScreen(camera: firstCamera),
        ),
      );
    }
  }

  @override
  void onPressedFunction() {
    runTest();
  }
}
