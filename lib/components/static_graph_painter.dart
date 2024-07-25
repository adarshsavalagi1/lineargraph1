import 'dart:ui';

import 'package:flutter/material.dart';

import '../data/graph_point.dart';

class StaticGraphPainter extends CustomPainter {
  final List<String> hours;
  final List<Graphpoint> gPoints;

  StaticGraphPainter( {required this.hours, required this.gPoints});

  @override
  void paint(Canvas canvas, Size size) {
    const x1 = 0.0;
    final x2 = size.width - (size.width * 0.15);
    const y1 = 0.0;
    final y2 = size.height;
    final xStep = (x2 - x1) / 24;
    final yStep = (y2 - y1) / 140;
    constructGraph(canvas, size);
    plotGraph(canvas, xStep, yStep, y1, y2);
  }

  void plotGraph(Canvas canvas,double xStep,double yStep,double y1,double y2){
    final shadedPaint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final graphLinePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final minMaxLinePaint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.stroke;


    gPoints.sort((a, b) => a.hour.compareTo(b.hour));

    final List<Offset> medianPoints = [];
    final List<Offset> minPoints = [];
    final List<Offset> maxPoints = [];

    for (int i = 0; i < gPoints.length; i++) {
      final gp = gPoints[i];
      final x = i * xStep;
      final yMedian = y2 - yStep * gp.median;
      final yMin = y2 - yStep * gp.min;
      final yMax = y2 - yStep * gp.max;

      // Draw the point for median
      canvas.drawPoints(PointMode.points, [Offset(x, yMedian)], graphLinePaint);

      // Draw the point for min
      canvas.drawPoints(PointMode.points, [Offset(x, yMin)], minMaxLinePaint);

      // Draw the point for max
      canvas.drawPoints(PointMode.points, [Offset(x, yMax)], minMaxLinePaint);

      medianPoints.add(Offset(x, yMedian));
      minPoints.add(Offset(x, yMin));
      maxPoints.add(Offset(x, yMax));

      // Draw cubic Bezier curves and shade only between consecutive points
      if (i > 0 && gp.hour == gPoints[i - 1].hour + 1) {
        // Shading between consecutive min and max points
        final shadedPath = Path();
        final prevMin = minPoints[i - 1];
        final currentMin = minPoints[i];
        final prevMax = maxPoints[i - 1];
        final currentMax = maxPoints[i];

        shadedPath.moveTo(prevMin.dx, prevMin.dy);
        shadedPath.lineTo(currentMin.dx, currentMin.dy);
        shadedPath.lineTo(currentMax.dx, currentMax.dy);
        shadedPath.lineTo(prevMax.dx, prevMax.dy);
        shadedPath.close();

        canvas.drawPath(shadedPath, shadedPaint);

        // for median
        final p1 = medianPoints[i - 1];
        final p2 = medianPoints[i];
        final controlPoint1 = Offset((p1.dx + p2.dx) / 2, p1.dy);
        final controlPoint2 = Offset((p1.dx + p2.dx) / 2, p2.dy);
        final path = Path()
          ..moveTo(p1.dx, p1.dy)
          ..cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx,
              controlPoint2.dy, p2.dx, p2.dy);
        canvas.drawPath(path, graphLinePaint);

        // for min
        final pm1 = minPoints[i - 1];
        final pm2 = minPoints[i];
        final minPoint1 = Offset((pm1.dx + pm2.dx) / 2, pm1.dy);
        final minPoint2 = Offset((pm1.dx + pm2.dx) / 2, pm2.dy);
        final minPath = Path()
          ..moveTo(pm1.dx, pm1.dy)
          ..cubicTo(minPoint1.dx, minPoint1.dy, minPoint2.dx, minPoint2.dy,
              pm2.dx, pm2.dy);
        canvas.drawPath(minPath, minMaxLinePaint);

        // for max
        final pmx1 = maxPoints[i - 1];
        final pmx2 = maxPoints[i];
        final maxPoint1 = Offset((pmx1.dx + pmx2.dx) / 2, pmx1.dy);
        final maxPoint2 = Offset((pmx1.dx + pmx2.dx) / 2, pmx2.dy);
        final maxPath = Path()
          ..moveTo(pmx1.dx, pmx1.dy)
          ..cubicTo(maxPoint1.dx, maxPoint1.dy, maxPoint2.dx, maxPoint2.dy,
              pmx2.dx, pmx2.dy);
        canvas.drawPath(maxPath, minMaxLinePaint);
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
