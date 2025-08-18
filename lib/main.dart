//de organizat si importurile astea ca sa nu am 100..

//import 'dart:developer' show log;
import 'package:diagnosticare/app_pages/test_data_page.dart';
import 'package:diagnosticare/app_pages/main_page.dart';
import 'package:flutter/material.dart';
import 'app_theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
  int selectedIndex = 0;
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
      case 1:
        page = TestDataPage();

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
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppTheme.appBarBottomBorderColor, // Orange border
                  width: 2,
                ),
              ),
            ),
            child: NavigationBar(
              height: 75,
              selectedIndex: selectedIndex,
              animationDuration: const Duration(seconds: 1),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
                NavigationDestination(
                  icon: Icon(Icons.file_copy),
                  label: 'Test Data',
                ),
              ],
              onDestinationSelected: (int index) {
                setState(() {
                  selectedIndex = index;
                });
              },
            ),
          ),
          body: Column(
            children: [Expanded(child: Container(child: page))],
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
