import 'package:flutter/material.dart';
import '../data/graph_point.dart';
import '/components/chart_painter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedHour = 200;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Linear Graph"),
      ),
      body: Container(
        margin: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                SizedBox(
                  height: 270,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 30.0,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 3),
                              height: 200,
                              child:  CustomPaint(
                                size: Size.infinite,
                                painter: ChartPainter(
                                  gPoints: actualData,
                                  selectedHour: _selectedHour,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                GestureDetector(
                  onTapDown: (details) {
                    _handleTouch(details.localPosition, context);
                  },
                  onHorizontalDragUpdate: (details) {
                    _handleTouch(details.localPosition, context);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleTouch(Offset position, BuildContext context) {
    setState(() {
      _selectedHour = _getHourIndex(position, context);
    });
  }

  int _getHourIndex(Offset position, BuildContext context) {
    final double graphWidth = MediaQuery.of(context).size.width - 32;
    const hoursInDay = 48;
    final double stepX = graphWidth / hoursInDay;
    return (position.dx / stepX).round().clamp(0, hoursInDay - 1);
  }
}
