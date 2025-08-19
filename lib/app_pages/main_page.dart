import 'package:diagnosticare/test_buttons/gyroscope_button.dart';
import 'package:diagnosticare/test_buttons/speaker/speaker_button.dart';
import 'package:diagnosticare/test_buttons/touchscreen/touchscreen_button.dart';
import 'package:flutter/material.dart';
import 'package:diagnosticare/test_buttons/accelerometer_button.dart';
import 'package:diagnosticare/test_buttons/simple_button.dart';
import 'package:diagnosticare/app_theme/app_theme.dart';
import 'package:diagnosticare/test_buttons/camera/camera_button.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});
  // add title maybe?

  final String title;
  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  final ValueNotifier<bool> isBusyNotifier = ValueNotifier(false);

  late final List<Widget> testButtons;

  @override
  void initState() {
    super.initState();
    testButtons = [
      SimpleTestButton(isBusyNotifier: isBusyNotifier),
      AccelerometerTestButton(isBusyNotifier: isBusyNotifier),
      GyroscopeButton(isBusyNotifier: isBusyNotifier),
      SimpleTestButton(isBusyNotifier: isBusyNotifier),
      SimpleTestButton(isBusyNotifier: isBusyNotifier),
      SimpleTestButton(isBusyNotifier: isBusyNotifier),
      SimpleTestButton(isBusyNotifier: isBusyNotifier),

      SimpleTestButton(isBusyNotifier: isBusyNotifier),
      GyroscopeButton(isBusyNotifier: isBusyNotifier),
      CameraTestButton(
        isBusyNotifier: isBusyNotifier,
        buttonName: 'Back Camera',
        testId: 3,
        cameraNumber: 0,
      ),

      CameraTestButton(
        isBusyNotifier: isBusyNotifier,
        buttonName: 'Front Camera',
        testId: 4,
        cameraNumber: 1,
      ),

      SpeakerTestButton(
        isBusyNotifier: isBusyNotifier,
        buttonName: 'Speaker',
        testId: 5,
      ),

      SpeakerTestButton(
        isBusyNotifier: isBusyNotifier,
        buttonName: 'Earpiece',
        testId: 6,
      ),
      TouchScreenTestButton(isBusyNotifier: isBusyNotifier),

      SpeakerTestButton(
        isBusyNotifier: isBusyNotifier,
        buttonName: 'Stereo Sound',
        testId: 7,
      ),

      TouchScreenTestButton(isBusyNotifier: isBusyNotifier),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary, //Color.fromARGB(255, 246, 246, 246),

          body: Stack(
            children: [
              // Background image
              Positioned.fill(
                child: Image.asset(
                  'images/background_aplicatie.png', // Replace with your image path
                  fit: BoxFit.cover,
                ),
              ),
              RawScrollbar(
                //to be optimized
                //hints: ListView.separated, ListView builder
                thumbColor: AppTheme.appBarBottomBorderColor,
                radius: Radius.circular(10),
                // trackColor: const Color.fromARGB(255, 54, 244, 168),
                // trackBorderColor: Colors.amber,
                // trackVisibility: true,

                //first, if we use a normal list (List<Widget>) that renders all the buttons at once there may be optimization issues
                //second, if we use a lazy list builder (List<WidgetBuilder>) the test buttons on reconstruction aren't drawn with the last test icon
                //also third: if we rebuild using lazy list builder or any other form or rebuild and scroll away while the test takes place, the app crashes
                child: ListView.separated(
                  key: Key("1"),
                  primary: true,
                  padding: const EdgeInsets.all(60),
                  itemCount: testButtons.length,
                  itemBuilder: (context, index) {
                    /*
                return RepaintBoundary(
                  child: KeyedSubtree(
                    key: Key(index.toString()),
                    child: testButtonsBuilders[index],
                  ),
                );
                */
                    return RepaintBoundary(child: testButtons[index]);
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 30),
                ),

                //experimental format for homepage
                /*
            child: ListWheelScrollView(
              itemExtent: 115,
              children: [
                SizedBox(height: 10),
                SimpleTestButton(),
                SizedBox(height: 10),
                AccelerometerTestButton(),
                SizedBox(height: 10),
                GyroscopeButton(),
                SizedBox(height: 10),
                SimpleTestButton(),
                SizedBox(height: 10),
                SimpleTestButton(),
                SizedBox(height: 5),
                SimpleTestButton(),
                SizedBox(height: 10),
                SimpleTestButton(),
              ],
            ),
            */
              ),
              ValueListenableBuilder<bool>(
                valueListenable: isBusyNotifier,
                builder: (context, isBusy, _) {
                  return isBusy
                      ? Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.all(11),
                            child: CircularProgressIndicator(
                              color: AppTheme.appBarBottomBorderColor,
                            ),
                          ),
                        )
                      : const SizedBox.shrink();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
