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
    // Lines paint
    final graphLinePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final dashedLinePaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final selectedLinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // shaded paint
    final shadedPaint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // dotted paint
    final dotPaint1 = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.5
      ..style = PaintingStyle.fill;

    final dotPaint2 = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;

    // text paint
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    // defining paint stop

    // canvas.drawLine(const Offset(0, 0), Offset(0, size.height), graphLinePaint);
    // canvas.drawLine(const Offset(0, 0),
    //     Offset(size.width - (size.width * 0.15), 0), graphLinePaint);
    // canvas.drawLine(Offset(size.width - (size.width * 0.15), size.height),
    //     Offset(0, size.height), graphLinePaint);
    // canvas.drawLine(Offset(size.width - (size.width * 0.15), size.height),
    //     Offset(size.width - (size.width * 0.15), 0), graphLinePaint);

    const x1 = 0.0;
    final x2 = size.width - (size.width * 0.15);

    const y1 = 0.0;
    final y2 = size.height;

    final xStep = (x2 - x1) / 48;
    final yStep = (y2 - y1) / 140;

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

    // 5. Plotting the graph
    gPoints.sort((a, b) => a.hour.compareTo(b.hour));
    final List<Offset> points = [];
    for (int i = 0; i < gPoints.length; i++) {
      final gp = gPoints[i];
      final x = gp.hour * xStep;
      final yMedian = y2 - yStep * gp.median;
      final yMin = y2 - yStep * gp.min;
      final yMax = y2 - yStep * gp.max;

      // Draw the point for median
      canvas.drawPoints(PointMode.points, [Offset(x, yMedian)], graphLinePaint);

      // Draw the point for min
      canvas.drawPoints(PointMode.points, [Offset(x, yMin)], shadedPaint);

      // Draw the point for max
      canvas.drawPoints(PointMode.points, [Offset(x, yMax)], shadedPaint);

      // Draw cubic Bezier curves between consecutive points
      if (i > 0 && gp.hour == gPoints[i - 1].hour + 1) {
        final p1 = points.last;
        final p2 = Offset(x, yMedian);
        final controlPoint1 = Offset((p1.dx + p2.dx) / 2, p1.dy);
        final controlPoint2 = Offset((p1.dx + p2.dx) / 2, p2.dy);
        final path = Path()
          ..moveTo(p1.dx, p1.dy)
          ..cubicTo(
            controlPoint1.dx,
            controlPoint1.dy,
            controlPoint2.dx,
            controlPoint2.dy,
            p2.dx,
            p2.dy,
          );
        canvas.drawPath(path, graphLinePaint);

        // Draw shaded region between median and min using quadratic Bezier curves
        final pathShadedMin = Path()
          ..moveTo(p1.dx, p1.dy)
          ..lineTo(p2.dx, p2.dy)
          ..lineTo(p2.dx, yMin)
          ..quadraticBezierTo(
            (p2.dx + p1.dx) / 2, // Control point x
            yMin, // Control point y
            p1.dx, // End point x (back to p1)
            p1.dy, // End point y (back to p1)
          )
          ..close();
        canvas.drawPath(pathShadedMin, shadedPaint);

        // Draw shaded region between median and max using quadratic Bezier curves
        final pathShadedMax = Path()
          ..moveTo(p1.dx, p1.dy)
          ..lineTo(p2.dx, p2.dy)
          ..lineTo(p2.dx, yMax)
          ..quadraticBezierTo(
            (p2.dx + p1.dx) / 2, // Control point x
            yMax, // Control point y
            p1.dx, // End point x (back to p1)
            p1.dy, // End point y (back to p1)
          )
          ..close();
        canvas.drawPath(pathShadedMax, shadedPaint);
      }

      points.add(Offset(x, yMedian));
    }

    // 6. mark the selected Line
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
      final dx = DateTime.now().hour * xStep * 2;
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
    // Find the smallest and largest values in dataPoints
      int minValue = gPoints.map((gp) => gp.min).reduce(min).toInt();
      int maxValue = gPoints.map((gp) => gp.max).reduce(max).toInt();

      // Find their corresponding points
      final minIndex = gPoints.where((gp) => gp.min == minValue).first.hour;
      final maxIndex = gPoints.where((gp) => gp.max == maxValue).first.hour;
      final minX = minIndex * xStep;
      final maxX = maxIndex * xStep;

      final minText = '$minValue';
      final maxText = '$maxValue';

      // Draw tooltip for the minimum value
      final textSpan = TextSpan(
        text: minText,
        style: const TextStyle(
            color: Colors.black, fontSize: 12, backgroundColor: Colors.white),
      );
      textPainter.text = textSpan;
      textPainter.layout();
      final textX = minX + 10;
      final textY = y2 - minValue * yStep - 10;
      textPainter.paint(canvas, Offset(textX, textY));

      // Draw tooltip for the maximum value
      final textSpanMax = TextSpan(
        text: maxText,
        style: const TextStyle(
            color: Colors.black, fontSize: 12, backgroundColor: Colors.white),
      );
      textPainter.text = textSpanMax;
      textPainter.layout();
      final textXMax = maxX;
      final textYMax = y2 - maxValue * yStep - 10;
      textPainter.paint(canvas, Offset(textXMax, textYMax));

    }



    // Selected Tooltip
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
      final double padding = 8.0;

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
