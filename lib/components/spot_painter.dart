import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../data/graph_point.dart';

class SpotPainter extends CustomPainter {
  final List<Graphpoint> gPoints;
  final int maxBound;
  SpotPainter({required this.gPoints, required this.maxBound});

  @override
  void paint(Canvas canvas, Size size) {
    const x1 = 0;
    const y1 = 0;
    final x2 = size.width;
    final y2 = size.height;
    final xStep = (x2 - x1) / 40;
    const lowerBound = 20;
    int maximumValue = maxBound + lowerBound;
    while (maximumValue % 10 != 0) {
      maximumValue++;
    }
    final upperBound = maximumValue;
    final yStep = (y2 - y1) / (upperBound - lowerBound + 20);

    constructGraph(canvas, y1, y2, x1, x2, xStep, yStep);
    plotGraph(canvas, xStep, yStep, y1.toDouble(), y2,x2);
    minMaxToolTip(canvas, xStep, yStep, y2, x1.toDouble());
  }

  void minMaxToolTip(
      Canvas canvas, double xStep, double yStep, double y2, double x1) {
    final textPainter = TextPainter(
        textAlign: TextAlign.center, textDirection: TextDirection.ltr);

    final Paint minMaxToolTipPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Min-Max Tooltip start
    int minValue = gPoints.map((gp) => gp.min).reduce(min).toInt();
    int maxValue = gPoints.map((gp) => gp.max).reduce(max).toInt();

    // Find their corresponding points
    final minIndex = gPoints.where((gp) => gp.min == minValue).first.hour;
    final maxIndex = gPoints.where((gp) => gp.max == maxValue).first.hour;
    final minX = minIndex * xStep;
    final maxX = maxIndex * xStep;

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
    final textX = minX + paddingX + 5;
    final textY = y2 - minValue * yStep - paddingY - 10;

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
    final textYMax = y2 - maxValue * yStep - paddingY - 15;

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

  void plotGraph(Canvas canvas, double xStep, double yStep, double y1, double y2,double x2) {
    // Paint for graph lines
    final graphLinePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    // Gradient shader
    final gradientShader = LinearGradient(
      colors: [Colors.red, Colors.red.withOpacity(0.1)],
      stops: const [0.0, 1.0],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTRB(0, 0, x2, y2));

    gPoints.sort((a, b) => a.hour.compareTo(b.hour));

    final List<Offset> medianPoints = [];

    for (int i = 0; i < gPoints.length; i++) {
      final gp = gPoints[i];
      final x = gp.hour * xStep;
      final yMedian = y2 - yStep * gp.median;

      // Draw the point for median
      canvas.drawPoints(PointMode.points, [Offset(x, yMedian)], graphLinePaint);

      medianPoints.add(Offset(x, yMedian));

      // Draw cubic Bezier curves and shade only between consecutive points
      if (i > 0 && gp.hour == gPoints[i - 1].hour + 1) {
        // for median
        final p1 = medianPoints[i - 1];
        final p2 = medianPoints[i];
        final controlPoint1 = Offset((p1.dx + p2.dx) / 2, p1.dy);
        final controlPoint2 = Offset((p1.dx + p2.dx) / 2, p2.dy);

        final path = Path()
          ..moveTo(p1.dx, p1.dy)
          ..cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx,
              controlPoint2.dy, p2.dx, p2.dy)
          ..lineTo(p2.dx, y2)
          ..lineTo(p1.dx, y2)
          ..close();

        // Fill the path with gradient shader
        canvas.drawPath(path, Paint()..shader = gradientShader);

        // Draw the median line
        final graphPath = Path()
          ..moveTo(p1.dx, p1.dy)
          ..cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx,
              controlPoint2.dy, p2.dx, p2.dy);

        canvas.drawPath(graphPath, graphLinePaint);
      }
    }
  }


  void constructGraph(Canvas canvas, int y1, double y2, int x1, double x2,
      double xStep, double yStep) {
    Paint secondsLinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    const double dashWidth = 8;
    const double dashSpace = 5;

    // lines along y axis
    const List<int> seconds = [0, 13, 27, 40];
    for (int i in seconds) {
      final x = i * xStep;
      double startY = y1.toDouble();
      while (startY < y2) {
        double dashEnd = startY + dashWidth;
        if (dashEnd > y2) {
          dashEnd = y2;
        }
        canvas.drawLine(
            Offset(x, startY), Offset(x, dashEnd), secondsLinePaint);
        startY += dashWidth + dashSpace;
      }
    }
    // x labels
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    for (int i in seconds) {
      final x = i * xStep;
      final textSpan = TextSpan(
        text: '${i}s',
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
    return false;
  }
}
