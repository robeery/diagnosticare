import 'package:diagnosticare/test_buttons/base_button.dart';
import 'package:diagnosticare/test_buttons/gyroscope_button.dart';
import 'package:diagnosticare/test_buttons/multitouch/multitouch_button.dart';
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
  late final ScrollController scrollController = ScrollController();
  ScrollController? getScrollController() {
    try {
      return scrollController.hasClients ? scrollController : null;
    } catch (e) {
      print("Error getting scroll controller: $e");
      return null;
    }
  }

  late final List<Widget> testButtons;
  late final List<GlobalKey<BaseButtonState>> buttonStateKeys;

  @override
  void initState() {
    super.initState();
    buttonStateKeys = List.generate(9, (index) => GlobalKey<BaseButtonState>());

    testButtons = [
      // Individual test buttons only
      AccelerometerTestButton(
        key: buttonStateKeys[0],
        isBusyNotifier: isBusyNotifier,
      ),
      GyroscopeButton(key: buttonStateKeys[1], isBusyNotifier: isBusyNotifier),

      // SimpleTestButton(key: buttonStateKeys[2], isBusyNotifier: isBusyNotifier),
      CameraTestButton(
        key: buttonStateKeys[2],
        isBusyNotifier: isBusyNotifier,
        buttonName: 'Back Camera',
        testId: 3,
        cameraNumber: 0,
      ),
      CameraTestButton(
        key: buttonStateKeys[3],
        isBusyNotifier: isBusyNotifier,
        buttonName: 'Front Camera',
        testId: 4,
        cameraNumber: 1,
      ),
      SpeakerTestButton(
        key: buttonStateKeys[4],
        isBusyNotifier: isBusyNotifier,
        buttonName: 'Speaker',
        testId: 5,
      ),
      SpeakerTestButton(
        key: buttonStateKeys[5],
        isBusyNotifier: isBusyNotifier,
        buttonName: 'Earpiece',
        testId: 6,
      ),
      SpeakerTestButton(
        key: buttonStateKeys[6],
        isBusyNotifier: isBusyNotifier,
        buttonName: 'Stereo Sound',
        testId: 7,
      ),
      TouchScreenTestButton(
        key: buttonStateKeys[7],
        isBusyNotifier: isBusyNotifier,
      ),

      MultiTouchTestButton(
        key: buttonStateKeys[8],
        isBusyNotifier: isBusyNotifier,
      ),
    ];
  }

  List<GlobalKey<BaseButtonState>>? getButtonKeys() {
    // Return all test button keys
    return buttonStateKeys;
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
                controller: scrollController,
                thumbColor: AppTheme.appBarBottomBorderColor,
                radius: Radius.circular(10),

                trackColor: const Color.fromARGB(255, 54, 244, 168),
                trackBorderColor: Colors.amber,
                trackVisibility: true,

                //first, if we use a normal list (List<Widget>) that renders all the buttons at once there may be optimization issues
                //second, if we use a lazy list builder (List<WidgetBuilder>) the test buttons on reconstruction aren't drawn with the last test icon
                //also third: if we rebuild using lazy list builder or any other form or rebuild and scroll away while the test takes place, the app crashes

                //built lazy:
                child: ListView.separated(
                  controller: scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
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
              //StartTestButtons(),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // Only dispose if the controller was actually created and used
    if (scrollController.hasClients) {
      scrollController.dispose();
    } else {
      // If no clients, we can still dispose but more safely
      try {
        scrollController.dispose();
      } catch (e) {
        print("Error disposing scroll controller: $e");
      }
    }
    super.dispose();
  }
}
