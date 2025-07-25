import 'package:flutter/material.dart';
import 'screens/cgpa_calculator.dart';

void main() => runApp(CGPAApp());

class CGPAApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CGPA Calculator',
      home: CGPACalculator(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
    );
  }
}
