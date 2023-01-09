import 'package:flutter/material.dart';

const String modelName = "assets/mobilenet_v1_1.0_224.tflite";
const String classLabels = "assets/mobilenet_v1_1.0_224.txt";
const Color kblue = Colors.blueAccent;
const Color kTextColor = Colors.white;
const TextStyle kButtonTextStyle = TextStyle(color: kTextColor);
const EdgeInsets kButtonTextPadding = EdgeInsets.symmetric(horizontal: 10, vertical: 15);
const BoxDecoration kButtonDecoration = BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)));