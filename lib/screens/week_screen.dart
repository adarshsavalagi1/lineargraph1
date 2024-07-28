import 'package:flutter/material.dart';

import '../components/week_painter.dart';

class WeekScreen extends StatefulWidget {
  const WeekScreen({super.key});

  @override
  State<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends State<WeekScreen> {
  int _selectedWeek = 200;
  bool _isTouched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Week chart"),
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
                                child: CustomPaint(
                                  size: Size.infinite,
                                  painter: WeekPainter(
                                      isTouched: _isTouched,
                                      weekIndex: _selectedWeek),
                                )),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                GestureDetector(
                  onTapDown: (details) {
                    setState(() {
                      _isTouched = true;
                    });
                    _handleTouch(details.localPosition, context);
                  },
                  onHorizontalDragUpdate: (details) {
                    _handleTouch(details.localPosition, context);
                    setState(() {
                      _isTouched = true;
                    });
                  },
                  onTapUp: (details) {
                    setState(() {
                      _isTouched = false;
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    setState(() {
                      _isTouched = false;
                    });
                  },
                  onTapCancel: () {
                    setState(() {
                      _isTouched = false;
                    });
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
      _selectedWeek = _getWeekIndex(position, context);
    });
  }

  int _getWeekIndex(Offset position, BuildContext context) {
    final double graphWidth = MediaQuery.of(context).size.width -
        MediaQuery.of(context).size.width * 0.15 -
        32 -
        6;
    const weekCount = 7;
    final double stepX = graphWidth / weekCount;
    return (position.dx / stepX).round().clamp(0, weekCount - 1);
  }
}
