import 'package:diagnosticare/test_buttons/model/test_result_cases.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_audio_output/flutter_audio_output.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StereoTestPage extends StatefulWidget {
  final int widgetId;
  final String buttonName;

  const StereoTestPage({
    super.key,
    required this.widgetId,
    required this.buttonName,
  });

  @override
  StereoTestPageState createState() => StereoTestPageState();
}

class StereoTestPageState extends State<StereoTestPage> {
  bool isPressedButton1 = false;
  bool isPressedButton2 = false;
  Color yesAndNoButtonColors = Colors.white60;

  final AudioPlayer player = AudioPlayer();

  Future<void> play(String fileName) async {
    await player.stop();
    await player.setReleaseMode(ReleaseMode.stop);
    await player.play(AssetSource(fileName));
  }

  Future<void> playOnEarpiece(String fileName) async {
    // Set output to earpiece
    print(FlutterAudioOutput.getCurrentOutput());
    print(FlutterAudioOutput.getAvailableInputs());
    print('EARPIECE');

    await player.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: false, // THIS switches to earpiece
          contentType: AndroidContentType.speech,
          usageType: AndroidUsageType.voiceCommunication,
          audioFocus: AndroidAudioFocus.gain,
        ),
      ),
    );
    await FlutterAudioOutput.changeToReceiver();
    await play(fileName);
  }

  Future<void> playOnSpeaker(String fileName) async {
    // Set output to speaker
    print(FlutterAudioOutput.getCurrentOutput());
    print(FlutterAudioOutput.getAvailableInputs());
    print('SPEAKER');
    await FlutterAudioOutput.changeToSpeaker();
    await play(fileName);
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<void> saveTestData(List<TestResultCases> testData) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> stringList = testData
        .map((e) => EnumToString.convertToString(e))
        .toList();
    await prefs.setStringList('testData', stringList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Are the buttons audible?')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.buttonName == 'Speaker')
              ElevatedButton(
                onPressed: () {
                  playOnSpeaker('audio/stereo_both_sound.mp3');
                  setState(() {
                    isPressedButton1 = true;
                    isPressedButton2 = true;
                    yesAndNoButtonColors = Colors.orange;
                  });
                },
                child: Text('Play Speaker Test'),
              ),

            if (widget.buttonName == 'Stereo Sound')
              ElevatedButton(
                onPressed: () {
                  play('audio/stereo_left_sound.mp3');
                  setState(() {
                    isPressedButton1 = true;
                    if (isPressedButton2) {
                      yesAndNoButtonColors = Colors.orange;
                    }
                  });
                },
                child: Text('Play Left Channel Only'),
              ),

            if (widget.buttonName == 'Stereo Sound')
              ElevatedButton(
                onPressed: () {
                  play('audio/stereo_right_sound.mp3');
                  setState(() {
                    isPressedButton2 = true;
                    if (isPressedButton1) {
                      yesAndNoButtonColors = Colors.orange;
                    }
                  });
                },
                child: Text('Play Right Channel Only'),
              ),

            if (widget.buttonName == 'Earpiece')
              ElevatedButton(
                onPressed: () {
                  playOnEarpiece('audio/stereo_left_sound.mp3');
                  setState(() {
                    isPressedButton1 = true;
                    yesAndNoButtonColors = Colors.orange;
                  });
                },
                child: Text('Test Earpiece (Top Speaker)'),
              ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        color: Colors.black12,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: () {
                testData[widget.widgetId] = TestResultCases.testFailed;
                saveTestData(testData);

                Navigator.pop(context);
              },
              icon: Icon(Icons.close, color: yesAndNoButtonColors),
              label: Text('No', style: TextStyle(color: yesAndNoButtonColors)),
            ),
            TextButton.icon(
              onPressed: isPressedButton1
                  ? () {
                      testData[widget.widgetId] = TestResultCases.testSucceded;
                      saveTestData(testData);

                      Navigator.pop(context);
                    }
                  : null,
              icon: Icon(Icons.check, color: yesAndNoButtonColors),
              label: Text('Yes', style: TextStyle(color: yesAndNoButtonColors)),
            ),
          ],
        ),
      ),
    );
  }
}
