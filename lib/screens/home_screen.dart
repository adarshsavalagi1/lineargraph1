import 'package:flutter/material.dart';
import '../components/EmptyWidget.dart';
import '../data/graph_point.dart';
import '/components/chart_painter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}



class _HomeScreenState extends State<HomeScreen> {
  int _selectedHour = 200;
  bool _isTouched = false;

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
                              child: newSetData.isNotEmpty
                                  ? CustomPaint(
                                      size: Size.infinite,
                                      painter: ChartPainter(
                                          gPoints: newSetData,
                                          isToday: true,
                                          selectedHour: _selectedHour,
                                          isTouched: _isTouched, maxBound: 210),
                                    )
                                  : const EmptyWidget(),
                            ),
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
      _selectedHour = _getHourIndex(position, context);
    });
  }

  int _getHourIndex(Offset position, BuildContext context) {
    final double graphWidth = MediaQuery.of(context).size.width -
        MediaQuery.of(context).size.width * 0.15 -
        32 -
        6;
    const hoursInDay = 48;
    final double stepX = graphWidth / hoursInDay;
    return (position.dx / stepX).round().clamp(0, hoursInDay - 1);
  }
}
