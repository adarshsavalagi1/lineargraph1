import 'package:flutter/material.dart';
import 'package:lineargraph/components/spot_painter.dart';
import '../data/graph_point.dart';

class SpotGraphScreen extends StatefulWidget {
  const SpotGraphScreen({super.key});

  @override
  State<SpotGraphScreen> createState() => _SpotGraphScreenState();
}

class _SpotGraphScreenState extends State<SpotGraphScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Static Graph'),
      ),
      body: Container(
        margin: const EdgeInsets.all(16.0),
        height: 250,
        child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Heart rate',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16.0,
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                RichText(
                                  text: const TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '99',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 27.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' bpm',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Text('at 1:00 PM'),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: double.infinity,
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: CustomPaint(
                                painter: SpotPainter(gPoints: actualData, maxBound: 105),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
