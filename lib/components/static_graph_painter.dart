import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../data/graph_point.dart';

class StaticGraphPainter extends CustomPainter {
  final List<String> hours;
  final List<Graphpoint> gPoints;

  StaticGraphPainter({required this.hours, required this.gPoints});

  @override
  void paint(Canvas canvas, Size size) {
    const x1 = 0.0;
    final x2 = size.width;
    const y1 = 0.0;
    final y2 = size.height;
    final xStep = (x2 - x1) / 11;
    final yStep = (y2 - y1) / 140;
    constructGraph(canvas, size);
    plotGraph(canvas, xStep, yStep, y1, y2);
    minMaxToolTip(canvas, xStep, yStep, y2);
  }

  void minMaxToolTip(Canvas canvas, double xStep, double yStep, double y2) {
    final Paint minMaxToolTipPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    final textPainter = TextPainter(
        textAlign: TextAlign.center, textDirection: TextDirection.ltr);

    // Filter out points with a median of zero
    final filteredPoints = gPoints.where((gp) => gp.median != 0).toList();

    if (filteredPoints.isEmpty) {
      return; // If no points remain after filtering, exit the function
    }

    // Min-Max Tooltip start
    int minValue = filteredPoints.map((gp) => gp.min).reduce(min).toInt();
    int maxValue = filteredPoints.map((gp) => gp.max).reduce(max).toInt();
    final minHour = filteredPoints.map((gp) => gp.hour).reduce(min).toInt();

    // Find their corresponding points
    final minIndex = filteredPoints.where((gp) => gp.min == minValue).first.hour;
    final maxIndex = filteredPoints.where((gp) => gp.max == maxValue).first.hour;
    final minX = (minIndex - minHour) * xStep;
    final maxX = (maxIndex - minHour) * xStep;

    const paddingX = 10.0;
    const paddingY = 2.0;
    const borderRadius = 8.0;

    // Draw tooltip for the minimum value
    final textSpan = TextSpan(
      text: '$minValue',
      style: const TextStyle(
          color: Colors.white, fontSize: 12, backgroundColor: Colors.black),
    );
    textPainter.text = textSpan;
    textPainter.layout();
    final textX = minX - paddingX;
    final textY = y2 - minValue * yStep - paddingY - 30;

    final Rect rect1 = Rect.fromPoints(
      Offset(textX - paddingX, textY - paddingY),
      Offset(textX + textPainter.width + paddingX,
          textY + textPainter.height + paddingY),
    );
    final RRect rrect1 =
    RRect.fromRectAndRadius(rect1, const Radius.circular(borderRadius));
    canvas.drawRRect(rrect1, minMaxToolTipPaint);
    textPainter.paint(canvas, Offset(textX, textY));

    // Draw tooltip for the maximum value
    final textSpanMax = TextSpan(
      text: '$maxValue',
      style: const TextStyle(
          color: Colors.white, backgroundColor: Colors.black, fontSize: 12),
    );

    textPainter.text = textSpanMax;
    textPainter.layout();
    final textXMax = maxX + paddingX + 10;
    final textYMax = y2 - maxValue * yStep - paddingY - 12;

    final Rect rect2 = Rect.fromPoints(
      Offset(textXMax - paddingX, textYMax - paddingY),
      Offset(textXMax + textPainter.width + paddingX,
          textYMax + textPainter.height + paddingY),
    );
    final RRect rrect2 =
    RRect.fromRectAndRadius(rect2, const Radius.circular(borderRadius));
    canvas.drawRRect(rrect2, minMaxToolTipPaint);
    textPainter.paint(canvas, Offset(textXMax, textYMax));

    // Min-Max Tooltip end
  }


  void plotGraph(Canvas canvas, double xStep, double yStep, double y1, double y2) {
    final shadedPaint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final graphLinePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    gPoints.sort((a, b) => a.hour.compareTo(b.hour));

    final List<Offset> medianPoints = [];
    final List<Offset> minPoints = [];
    final List<Offset> maxPoints = [];
    final minHour = gPoints.map((gp) => gp.hour).reduce(min);

    for (int i = 0; i < gPoints.length; i++) {
      final gp = gPoints[i];
      final x = (gp.hour - minHour) * xStep;
      final yMedian = y2 - yStep * gp.median;
      final yMin = y2 - yStep * gp.min;
      final yMax = y2 - yStep * gp.max;

      if (gp.median != 0) {
        canvas.drawPoints(PointMode.points, [Offset(x, yMedian)], graphLinePaint);
      }

      medianPoints.add(Offset(x, yMedian));
      minPoints.add(Offset(x, yMin));
      maxPoints.add(Offset(x, yMax));

      // Draw cubic Bezier curves and shade only between consecutive points
      if (medianPoints.length > 1) {
        final prevHour = gPoints[i - 1].hour;
        final currentHour = gp.hour;

        if (prevHour == currentHour - 1 && gPoints[i - 1].median != 0 && gp.median != 0) {
          // Shading between consecutive min and max points
          final shadedPath = Path();
          final prevMin = minPoints[minPoints.length - 2];
          final currentMin = minPoints.last;
          final prevMax = maxPoints[maxPoints.length - 2];
          final currentMax = maxPoints.last;

          // Move to the previous min point
          shadedPath.moveTo(prevMin.dx, prevMin.dy);

          // Draw a cubic Bezier curve to the current min point
          shadedPath.cubicTo(
              (prevMin.dx + currentMin.dx) / 2,
              prevMin.dy,
              (prevMin.dx + currentMin.dx) / 2,
              currentMin.dy,
              currentMin.dx,
              currentMin.dy);

          // Draw a line to the current max point
          shadedPath.lineTo(currentMax.dx, currentMax.dy);

          // Draw a cubic Bezier curve back to the previous max point
          shadedPath.cubicTo(
              (prevMax.dx + currentMax.dx) / 2,
              currentMax.dy,
              (prevMax.dx + currentMax.dx) / 2,
              prevMax.dy,
              prevMax.dx,
              prevMax.dy);

          shadedPath.close();

          canvas.drawPath(shadedPath, shadedPaint);

          // for median
          final p1 = medianPoints[medianPoints.length - 2];
          final p2 = medianPoints.last;
          final controlPoint1 = Offset((p1.dx + p2.dx) / 2, p1.dy);
          final controlPoint2 = Offset((p1.dx + p2.dx) / 2, p2.dy);
          final path = Path()
            ..moveTo(p1.dx, p1.dy)
            ..cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx,
                controlPoint2.dy, p2.dx, p2.dy);
          canvas.drawPath(path, graphLinePaint);

        }
      }
    }
  }




  void constructGraph(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const double dashWidth = 5;
    const double dashSpace = 8;

    const y1 = 0.0;
    final y2 = size.height - 10;

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < 4; i++) {
      final x = size.width * i / 3;
      double startY = y1;
      while (startY < y2) {
        double dashEnd = startY + dashWidth;
        if (dashEnd > y2) {
          dashEnd = y2;
        }
        canvas.drawLine(Offset(x, startY), Offset(x, dashEnd), linePaint);
        startY += dashWidth + dashSpace;
      }

      final textSpan = TextSpan(
        text: hours[i],
        style: const TextStyle(
          fontSize: 12.0,
          color: Colors.black,
        ),
      );
      textPainter.text = textSpan;
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, y2 + 10));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
