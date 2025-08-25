//de organizat si importurile astea ca sa nu am 100..

//import 'dart:developer' show log;
import 'dart:developer';

import 'package:diagnosticare/app_pages/test_data_page.dart';
import 'package:diagnosticare/app_pages/main_page.dart';
import 'package:diagnosticare/test_buttons/start_all/reset_test_data_button.dart';
import 'package:diagnosticare/test_buttons/start_all/start_tests_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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

  // Add GlobalKey to access MainPage
  final GlobalKey<MainPageState> mainPageKey = GlobalKey<MainPageState>();

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = MainPage(key: mainPageKey, title: 'Certus');

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
            title: FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(widget.title, style: TextStyle(color: Colors.white)),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(2),
              child: Container(
                color: AppTheme.appBarBottomBorderColor,
                height: 2,
              ),
            ),
            actions: [
              if (selectedIndex == 0)
                Padding(
                  padding: const EdgeInsets.only(right: 5.0),
                  child: StartTestButtons(
                    getButtonKeys: () =>
                        mainPageKey.currentState?.getButtonKeys(),
                    getScrollController: () =>
                        mainPageKey.currentState?.getScrollController(),
                  ),
                ),
              if (selectedIndex == 1)
                Padding(
                  padding: const EdgeInsets.only(right: 5.0),
                  child: ResetTestDataButton(
                    () => {log("Calling callback"), setState(() {})},
                  ),
                ),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppTheme.appBarBottomBorderColor,
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
                  label: 'Tests Results',
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
