import 'package:diagnosticare/app_theme/app_theme.dart';
import 'package:diagnosticare/test_data_manager/test_data_manager.dart';
import 'package:flutter/material.dart';

class ResetTestDataButton extends StatelessWidget {
  static String popUpName = "Reset all test data";
  static String popUpDescription =
      "This will reset all test data stored on the device. Are you sure this is what you want to do?";

  late Set<void> Function() callback;
  ResetTestDataButton(Set<void> Function() param0) {
    callback = param0;
  }

  void resetData() async {
    var db = TestDataManager();
    await db.deleteAllTestData();

    callback.call();
  }

  void onPressedFunctionReset(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(popUpName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[Text(popUpDescription)],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Reset data'),
              onPressed: () {
                Navigator.pop(context);
                resetData();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 0.0),
      child: ElevatedButton(
        onPressed: () => onPressedFunctionReset(context),
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shape: CircleBorder(),
          padding: EdgeInsets.all(4),
          backgroundColor: AppTheme.seedColor,
          foregroundColor: Colors.white,
          side: BorderSide(color: AppTheme.appBarBottomBorderColor, width: 2),
        ),
        child: Icon(Icons.delete_forever_sharp, size: 24),
      ),
    );
  }
}
