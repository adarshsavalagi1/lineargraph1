import 'package:flutter/material.dart';
import 'package:lineargraph/screens/home_screen.dart';

void main(){
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    )
  );
}