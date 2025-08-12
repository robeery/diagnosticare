//de organizat si importurile astea ca sa nu am 100..

//import 'dart:developer' show log;
import 'package:diagnosticare/test_buttons/gyroscope_button.dart';
import 'package:flutter/material.dart';
import 'test_buttons/simple_button.dart';
import 'test_buttons/accelerometer_button.dart';
import 'app_theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.lightTheme,
      home: const MyHomePage(title: 'Certus Mobile Diagnosis Tool'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    //final ValueNotifier<bool> isBusyNotifier = ValueNotifier(false);
    //here come two issues:
    //first, if we use a normal list (List<Widget>) that renders all the buttons at once there may be optimization issues
    //second, if we use a lazy list builder (List<WidgetBuilder>) the test buttons on reconstruction aren't drawn with the last test icon
    //also third: if we rebuild using lazy list builder or any other form or rebuild and scroll away while the test takes place, the app crashes
    /*
    final List<Widget> testButtonsBuilders = [
      SimpleTestButton(isBusyNotifier: isBusyNotifier),
      AccelerometerTestButton(isBusyNotifier: isBusyNotifier),
      GyroscopeButton(isBusyNotifier: isBusyNotifier),
      SimpleTestButton(isBusyNotifier: isBusyNotifier),
      SimpleTestButton(isBusyNotifier: isBusyNotifier),
      SimpleTestButton(isBusyNotifier: isBusyNotifier),
      SimpleTestButton(isBusyNotifier: isBusyNotifier),
      SimpleTestButton(isBusyNotifier: isBusyNotifier),
      SimpleTestButton(isBusyNotifier: isBusyNotifier),
      GyroscopeButton(isBusyNotifier: isBusyNotifier),
    ];
    */

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = MainPage(title: 'Certus');
      //break;

      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary, //Color.fromARGB(255, 246, 246, 246),
          appBar: AppBar(
            backgroundColor: AppTheme.seedColor,
            title: Text(widget.title, style: TextStyle(color: Colors.white)),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(2),
              child: Container(
                color: AppTheme.appBarBottomBorderColor,
                height: 2,
              ),
            ),
          ),
          bottomNavigationBar: NavigationBar(
            destinations: [
              NavigationDestination(
                selectedIcon: Icon(Icons.home),
                icon: Icon(Icons.home_outlined),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Badge(child: Icon(Icons.notifications_sharp)),
                label: 'Notifications',
              ),
            ],
            onDestinationSelected: (int index) {
              setState(() {
                selectedIndex = index;
              });
            },
            indicatorColor: AppTheme.appBarBottomBorderColor,
          ),

          body: Column(
            children: [Expanded(child: Container(child: page))],
          ),
        );
      },
    );
  }
}

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
      SimpleTestButton(isBusyNotifier: isBusyNotifier),
      GyroscopeButton(isBusyNotifier: isBusyNotifier),
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

//old checkbox widget
/*
class CheckBox extends StatefulWidget {
  const CheckBox({super.key});

  @override
  State<CheckBox> createState() => _CheckBoxState();
}

class _CheckBoxState extends State<CheckBox> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<WidgetState> states) {
      const Set<WidgetState> interactiveStates = <WidgetState>{
        WidgetState.pressed,
        WidgetState.hovered,
        WidgetState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }

    return Checkbox(
      checkColor: Colors.white,
      fillColor: WidgetStateProperty.resolveWith(getColor),
      value: isChecked,
      onChanged: (bool? value) {
        setState(() {
          isChecked = value!;
        });
      },
    );
  }
}
*/
