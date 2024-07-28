import 'dart:ui';
import 'package:flutter/material.dart';

class WeekPainter extends CustomPainter {
  final bool isTouched;
  final int weekIndex;

  WeekPainter({required this.isTouched, required this.weekIndex});

  @override
  void paint(Canvas canvas, Size size) {
    const x1 = 0.0;
    final x2 = size.width - (size.width * 0.15);
    const y1 = 0.0;
    final y2 = size.height;
    final xStep = (x2 - x1) / 7;
    final yStep = (y2 - y1) / 140;
    constructGraph(canvas, size, x1, x2, xStep, yStep, y1, y2);
    plotGraph(canvas, x1, x2, y1, y2, xStep, yStep);
    markSelectedLine(canvas, y1, y2, xStep);
  }

  void markSelectedLine(Canvas canvas, double y1, double y2, double xStep) {
    final selectedLinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    const double dashHeight = 5.0;
    const double dashSpace = 3.0;

    if (!isTouched) {
      int selectedIndex = DateTime.now().weekday % 7;
      final dx = xStep * selectedIndex + 13;

      double startY = y1;
      while (startY < y2) {
        canvas.drawLine(
          Offset(dx, startY),
          Offset(dx, startY + dashHeight),
          selectedLinePaint,
        );
        startY += dashHeight + dashSpace;
      }
    } else {
      final dx = xStep * weekIndex + 13;
      double startY = y1;
      while (startY < y2) {
        canvas.drawLine(
          Offset(dx, startY),
          Offset(dx, startY + dashHeight),
          selectedLinePaint,
        );
        startY += dashHeight + dashSpace;
      }
    }
  }

  void plotGraph(Canvas canvas, double x1, double x2, double y1, double y2,
      double xStep, double yStep) {
    Paint plotPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    const double width = 25.0;
    const double radius = 16.0;
    const double startY = -10.0;
    // int numberOfRectangles = DateTime.now().weekday;
    int numberOfRectangles = 6;
    for (int i = 0; i <= numberOfRectangles; i++) {
      double height = 10 + i * 20;
      Rect rect = Rect.fromLTWH(x1 + i * xStep, startY, width, height);
      RRect rrect =
          RRect.fromRectAndRadius(rect, const Radius.circular(radius));
      canvas.drawRRect(rrect, plotPaint);
    }
  }

  void constructGraph(Canvas canvas, Size size, double x1, double x2,
      double xStep, double yStep, double y1, double y2) {
    final dashedLinePaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
        textAlign: TextAlign.center, textDirection: TextDirection.ltr);

    // 1. Draw y-axis dashed lines at specific positions
    final List<double> yPositions = [20, 80, 140];
    const double dashWidth = 5; // Length of each dash
    const double dashSpace = 8; // Space between dashes

    for (double y in yPositions) {
      double startX = x1;
      double lineY = y2 - (y * yStep);
      while (startX < x2) {
        double dashEndX = startX + dashWidth;
        if (dashEndX > x2) {
          dashEndX = x2;
        }
        canvas.drawLine(
          Offset(startX, lineY),
          Offset(dashEndX, lineY),
          dashedLinePaint,
        );
        startX += dashWidth + dashSpace;
      }
    }

    // 2. Coordinates text along y axis
    for (int i = 0; i < yPositions.length; i++) {
      final yLabel = '${yPositions[i]}bpm';
      textPainter.text = TextSpan(
        text: yLabel,
        style: const TextStyle(color: Colors.black, fontSize: 10),
      );
      textPainter.layout();
      final y = y2 - yPositions[i] * yStep - 5;
      textPainter.paint(canvas, Offset(x2 + 10, y));
    }

    // 3. Dots along x axis
    final List<Offset> Xpoints2 = List.generate(7, (i) {
      final x = i * xStep + 13;
      return Offset(x, size.height);
    });

    canvas.drawPoints(PointMode.points, Xpoints2, dotPaint);
    canvas.drawPoints(PointMode.points,
        Xpoints2.map((xp) => Offset(xp.dx, xp.dy - 2)).toList(), dotPaint);

    // 4. Draw x-axis labels
    const xLabels1 = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final xLabels2 = getCurrentWeekDays();
    for (int i = 0; i < xLabels1.length; i++) {
      final xLabel = xLabels1[i];
      textPainter.text = TextSpan(
        text: xLabel,
        style: const TextStyle(color: Colors.black, fontSize: 10),
      );
      textPainter.layout();
      final x = i * xStep + 13;
      textPainter.paint(
          canvas, Offset(x - textPainter.width / 2, size.height + 7));
      final xLabel1 = xLabels2[i];
      textPainter.text = TextSpan(
        text: xLabel1.toString(),
        style: const TextStyle(color: Colors.black, fontSize: 10),
      );
      textPainter.layout();
      final x1 = i * xStep + 13;
      textPainter.paint(
          canvas, Offset(x1 - textPainter.width / 2, size.height + 7 + 15));
    }
  }

  List<int> getCurrentWeekDays() {
    DateTime now = DateTime.now();
    int currentDayOfWeek = now.weekday; // 1 is Monday, 7 is Sunday
    int offset = currentDayOfWeek % 7;

    List<int> weekDays = List.generate(7, (index) {
      DateTime day = now.subtract(Duration(days: offset - index));
      return day.day;
    });

    return weekDays;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
