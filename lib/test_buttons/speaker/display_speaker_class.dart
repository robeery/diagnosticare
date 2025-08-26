import 'package:diagnosticare/app_theme/app_theme.dart';
import 'package:diagnosticare/test_buttons/model/test_result_cases.dart';
import 'package:diagnosticare/test_data_manager/test_data_manager.dart';
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
    //this function is cursed
    await player.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: false, // this actually switches to earpiece
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

  var db = TestDataManager();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Are the buttons audible?'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: Container(color: AppTheme.appBarBottomBorderColor, height: 2),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //I may need to find a better method to display these
            if (widget.buttonName == 'Speaker')
              ElevatedButton(
                onPressed: () {
                  playOnSpeaker('audio/stereo_both_sound.mp3');
                  setState(() {
                    isPressedButton1 = true;
                    isPressedButton2 = true;
                    yesAndNoButtonColors = AppTheme.appBarBottomBorderColor;
                  });
                },
                style: ElevatedButton.styleFrom(
                  side: BorderSide(
                    color: isPressedButton1
                        ? AppTheme.appBarBottomBorderColor
                        : Colors.transparent,
                    width: 2.0,
                  ),
                ),
                child: Text(
                  'Play Speaker Test',
                  style: TextStyle(fontSize: 22),
                ),
              ),

            if (widget.buttonName == 'Stereo Sound')
              ElevatedButton(
                onPressed: () {
                  play('audio/stereo_left_sound.mp3');
                  setState(() {
                    isPressedButton1 = true;
                    if (isPressedButton2) {
                      yesAndNoButtonColors = AppTheme.appBarBottomBorderColor;
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  side: BorderSide(
                    color: isPressedButton1
                        ? AppTheme.appBarBottomBorderColor
                        : Colors.transparent,
                    width: 2.0,
                  ),
                ),
                child: Text(
                  'Play Left Channel Only',
                  style: TextStyle(fontSize: 22),
                ),
              ),

            if (widget.buttonName == 'Stereo Sound')
              ElevatedButton(
                onPressed: () {
                  play('audio/stereo_right_sound.mp3');
                  setState(() {
                    isPressedButton2 = true;
                    if (isPressedButton1) {
                      yesAndNoButtonColors = AppTheme.appBarBottomBorderColor;
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  side: BorderSide(
                    color: isPressedButton2
                        ? AppTheme.appBarBottomBorderColor
                        : Colors.transparent,
                    width: 2.0,
                  ),
                ),
                child: Text(
                  'Play Right Channel Only',
                  style: TextStyle(fontSize: 22),
                ),
              ),

            if (widget.buttonName == 'Earpiece')
              ElevatedButton(
                onPressed: () {
                  playOnEarpiece('audio/stereo_left_sound.mp3');
                  setState(() {
                    isPressedButton1 = true;
                    isPressedButton2 = true;
                    yesAndNoButtonColors = AppTheme.appBarBottomBorderColor;
                  });
                },
                style: ElevatedButton.styleFrom(
                  side: BorderSide(
                    color: isPressedButton1
                        ? AppTheme.appBarBottomBorderColor
                        : Colors.transparent,
                    width: 2.0,
                  ),
                ),
                child: Text(
                  'Play Earpiece Test',
                  style: TextStyle(fontSize: 22),
                ),
              ),
          ],
        ),
      ),
      bottomSheet: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppTheme.appBarBottomBorderColor,
              width: 3,
            ), // Orange top border
          ),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          color: AppTheme.seedColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: isPressedButton1 && isPressedButton2
                    ? () {
                        testData[widget.widgetId] = TestResultCases.testFailed;
                        saveTestData(testData);
                        db.updateTestResultById(
                          widget.widgetId,
                          testData[widget.widgetId].toString(),
                        );
                        player.stop();
                        Navigator.pop(context);
                      }
                    : null,
                icon: Icon(Icons.close, color: yesAndNoButtonColors),
                label: Text(
                  'No',
                  style: TextStyle(color: yesAndNoButtonColors, fontSize: 20),
                ),
              ),
              TextButton.icon(
                onPressed: isPressedButton1 && isPressedButton2
                    ? () {
                        testData[widget.widgetId] =
                            TestResultCases.testSucceded;
                        saveTestData(testData);
                        db.updateTestResultById(
                          widget.widgetId,
                          testData[widget.widgetId].toString(),
                        );
                        player.stop();
                        Navigator.pop(context);
                      }
                    : null,
                icon: Icon(Icons.check, color: yesAndNoButtonColors),
                label: Text(
                  'Yes',
                  style: TextStyle(color: yesAndNoButtonColors, fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
