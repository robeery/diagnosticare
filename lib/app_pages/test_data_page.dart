import 'package:flutter/material.dart';

class TestDataPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'images/background_aplicatie.png', // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          //Text("TEST_DATA_PAGE_PLACEHOLDER"),
        ],
      ),
    );
  }
}

class TestDataCard extends StatefulWidget {
  @override
  State<TestDataCard> createState() => _TestDataCardState();
}

class _TestDataCardState extends State<TestDataCard> {
  @override
  Widget build(BuildContext context) {
    return Text('placeholder');
  }
}
