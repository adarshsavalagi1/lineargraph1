import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lineargraph/data/graph_point.dart';

class ChartPainter extends CustomPainter {
  final List<Graphpoint> gPoints;
  final int selectedHour;
  final bool isTouched;

  ChartPainter(
      {required this.gPoints,
      required this.selectedHour,
      required this.isTouched});

  @override
  void paint(Canvas canvas, Size size) {
    const x1 = 0.0;
    final x2 = size.width - (size.width * 0.15);
    const y1 = 0.0;
    final y2 = size.height;
    final xStep = (x2 - x1) / 48;
    final yStep = (y2 - y1) / 140;

    // 1. construct graph skeleton
    constructGraph(canvas, size, x1, x2, xStep, yStep, y1, y2);

    // 2. Plotting the graph
    plotGraph(canvas, xStep, yStep, y1, y2);

    // 3. mark the selected Line
    markSelectedLine(canvas, xStep, yStep, y2, x1);

    // 3.1 Selected Tooltip
    drawSelectedToolTip(canvas, xStep);
  }

  void plotGraph(
      Canvas canvas, double xStep, double yStep, double y1, double y2) {
    // Paint for shading
    final shadedPaint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Paint for graph lines
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
      final x = gp.hour * xStep;
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

  void markSelectedLine(
      Canvas canvas, double xStep, double yStep, double y2, double x1) {
    final textPainter = TextPainter(
        textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    final selectedLinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Paint minMaxToolTipPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    bool selectedHourPresent =
        gPoints.where((gp) => gp.hour == selectedHour).isNotEmpty;
    if (isTouched) {
      if (selectedHourPresent) {
        const double dashHeight = 5.0;
        const double dashSpace = 3.0;
        double startY = x1;
        final dx = selectedHour * xStep;

        while (startY < y2) {
          canvas.drawLine(
            Offset(dx, startY),
            Offset(dx, startY + dashHeight),
            selectedLinePaint,
          );
          startY += dashHeight + dashSpace;
        }
      } else {
        // calculate nearest point
        if (selectedHour != 200) {
          final dx = gPoints
                  .reduce((a, b) => (a.hour - selectedHour).abs() <
                          (b.hour - selectedHour).abs()
                      ? a
                      : b)
                  .hour *
              xStep;
          const double dashHeight = 5.0;
          const double dashSpace = 3.0;
          double startY = 0.0;
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
    } else {
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
            color: Colors.black, fontSize: 12, backgroundColor: Colors.white),
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
        style: const TextStyle(color: Colors.black, fontSize: 12),
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
  }

  void constructGraph(Canvas canvas, Size size, double x1, double x2,
      double xStep, double yStep, double y1, double y2) {
    final dashedLinePaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    // dotted paint
    final dotPaint1 = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.5
      ..style = PaintingStyle.fill;

    final dotPaint2 = Paint()
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
      double startX = x1; // Starting x-coordinate of the dashed line
      double lineY = y2 - (y * yStep); // Y-coordinate of the dashed line
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

    //   2. coordinates text along y axis

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

    // 3. dots along x axis

    final List<Offset> Xpoints1 = List.generate(24, (i) {
      if (i % 6 == 0) {
        return Offset(0, size.height);
      }
      final x = i * xStep * 2;
      return Offset(x, size.height);
    });
    canvas.drawPoints(PointMode.points, Xpoints1, dotPaint1);

    final List<Offset> Xpoints2 = List.generate(24, (i) {
      if (i % 6 != 0) {
        return Offset(0, size.height);
      }
      final x = i * xStep * 2;
      return Offset(x, size.height);
    });

    canvas.drawPoints(PointMode.points, Xpoints2, dotPaint2);

    //  4.   Draw x-axis labels
    const xLabels = ['12 AM', '6 AM', '12 PM', '6 PM', '12 AM'];
    for (int i = 0; i < xLabels.length; i++) {
      final xLabel = xLabels[i];
      textPainter.text = TextSpan(
        text: xLabel,
        style: const TextStyle(color: Colors.black, fontSize: 10),
      );
      textPainter.layout();
      final x = i * xStep * 12 + 5;
      textPainter.paint(
          canvas, Offset(x - textPainter.width / 2, size.height + 7));
    }
  }

  void drawSelectedToolTip(Canvas canvas, double xStep) {
    if (selectedHour != 200 && isTouched) {
      final selectedPoint = gPoints.reduce((a, b) =>
          (a.hour - selectedHour).abs() < (b.hour - selectedHour).abs()
              ? a
              : b);
      final paint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      final newX = selectedHour <= 8
          ? 0
          : selectedHour >= 40
              ? 32
              : selectedHour - 8;
      final constraints = [
        0.0 + (newX * xStep),
        -50.0,
        100.0 + (newX * xStep),
        0.0
      ];
      final rect = RRect.fromLTRBR(
        constraints[0],
        constraints[1],
        constraints[2],
        constraints[3],
        const Radius.circular(10.0),
      );
      canvas.drawRRect(rect, paint);
      final textSpanValue = TextSpan(
        text: '${selectedPoint.median.toInt()}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15.0,
          color: Colors.black,
        ),
      );

      final textSpanDateTime = TextSpan(
        text:
            '${intl.DateFormat.yMMMd().format(DateTime.now())} ${selectedPoint.hour}:00PM',
        style: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 9.0,
          color: Colors.black,
        ),
      );

      final textPainterValue = TextPainter(
        text: textSpanValue,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainterValue.layout(
        minWidth: 0,
        maxWidth: constraints[2] - constraints[0],
      );

      final textPainterDateTime = TextPainter(
        textAlign: TextAlign.center,
        text: textSpanDateTime,
        textDirection: TextDirection.ltr,
      );
      textPainterDateTime.layout(
        minWidth: 0,
        maxWidth: constraints[2] - constraints[0],
      );
      const padding = 8.0;

      // Position the text and draw it on the canvas
      final offsetValue = Offset(
          constraints[0] +
              (constraints[2] - constraints[0]) / 2 -
              textPainterValue.width / 2,
          padding + constraints[1]);
      textPainterValue.paint(canvas, offsetValue);

      final offsetDateTime = Offset(padding + constraints[0],
          padding + textPainterValue.height + constraints[1]);
      textPainterDateTime.paint(canvas, offsetDateTime);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
