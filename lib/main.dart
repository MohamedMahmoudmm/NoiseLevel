
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myfinalproject/2.dart';
void main() {
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

        theme: ThemeData.dark(),
      home:  NoiseApp(),

    );
  }
}






