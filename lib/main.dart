import 'package:flutter/material.dart';
import 'package:lineargraph/screens/home_screen.dart';
import 'package:lineargraph/screens/spot_graph.dart';
import 'package:lineargraph/screens/static_graph_screen.dart';
import 'package:lineargraph/screens/week_screen.dart';



void main(){
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SpotGraphScreen(),
    )
  );
}