import 'package:diagnosticare/test_buttons/model/test_result_cases.dart';
import 'package:diagnosticare/test_buttons/speaker/display_speaker_class.dart';
import 'package:flutter/material.dart';
import '../base_button.dart';

class SpeakerTestButton extends BaseButton {
  const SpeakerTestButton({
    Key? key,

    required String buttonName,
    required int testId,
  }) : super(
         key: key,
         testId: testId,
         buttonName: buttonName,
         popUpName: '$buttonName Test',
         popUpDescription: 'Temporary',
       );

  @override
  State<SpeakerTestButton> createState() => SpeakerTestButtonState();
}

class SpeakerTestButtonState extends BaseButtonState<SpeakerTestButton> {
  String getImagePath() {
    String imagePath = '';
    switch (widget.buttonName) {
      case 'Speaker':
        imagePath = 'images/speaker_photo.png';

      case 'Earpiece':
        imagePath = 'images/earpiece_photo.png';

      case 'Stereo Sound':
        imagePath = 'images/stereo_photo.png';

      default:
        throw Exception("Not implemented");
    }
    return imagePath;
  }

  String getPopUpDescription() {
    String popUpDescription = widget.popUpDescription;

    switch (widget.buttonName) {
      case 'Speaker':
        popUpDescription =
            'After pressing the start button, you will be taken to a new page with a button which upon pressing plays a sound. You will need to listen and determine if the speaker works accordingly. Make sure the phone is not on mute.';

      case 'Earpiece':
        popUpDescription =
            'After pressing the start button, you will be taken to a new page with a button which upon pressing plays a sound. You will need to put phone near your ear and listen to determine if the earpiece works accordingly. Make sure the phone is not on mute.';

      case 'Stereo Sound':
        popUpDescription =
            'After pressing the start button, you will be taken to a new page with to buttons. One plays a button that should be heard from the right side, another from the left side. If the behaviour is as described, mark the test as a success. Make sure the phone is not on mute.';

      default:
        throw Exception("Not implemented");
    }

    return popUpDescription;
  }

  @override
  runTest({TestResultCases? param}) async {
    if (context.mounted) {
      print('PUSH');
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => StereoTestPage(
            widgetId: widget.testId,
            buttonName: widget.buttonName,
          ),
        ),
      );
    }

    setState(() {});
  }

  @override
  Future<void> onPressedFunction() async {
    bool startTest;
    startTest = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          scrollable: true,
          title: Text(widget.popUpName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(getPopUpDescription()),
              SizedBox(height: 10),
              Image.asset(getImagePath(), width: 150, height: 150),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            TextButton(
              child: const Text('Start test'),
              onPressed: () async {
                // Navigator.pop(context);

                Navigator.pop(context, true);
              },
            ),
          ],
        ),
      ),
    );

    if (startTest == true) {
      await runTest();
    }
  }
}
