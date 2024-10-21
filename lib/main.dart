import 'package:flutter/material.dart';

import 'feed_calculator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feed Formulation Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FeedCalculator(), // Use the FeedCalculator widget
    );
  }
}
