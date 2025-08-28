// A screen that allows users to take a picture using a given camera.

import 'package:diagnosticare/test_buttons/model/test_result_cases.dart';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import '../base_button.dart';
import 'take_picture_class.dart';

class CameraTestButton extends BaseButton {
  final int cameraNumber;
  const CameraTestButton({
    Key? key,

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
  String getImagePath() {
    //default return value, might change for a stock/error photo
    String imagePath = 'images/back_camera_image.png';
    //might change logic for photo selection, hardcoding for ID is not a good idea
    //to do later
    if (widget.testId == 3) {
      imagePath = 'images/back_camera_image.png';
    } else if (widget.testId == 4) {
      imagePath = 'images/front_camera_image.png';
    }
    return imagePath;
  }
}
