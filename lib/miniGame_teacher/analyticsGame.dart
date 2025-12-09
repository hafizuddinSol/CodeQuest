import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import 'dart:math';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseService _service = FirebaseService();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text(
          "Game Analytics",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _service.getAllResults(), // collection('game_results').snapshots()
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No results yet'));
          }

          // Compute average score and game counts
          double avgScore = 0;
          Map<String, int> gameCount = {};

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;

            // Safe score handling
            final scoreValue = data['score'];
            final double score = (scoreValue is int)
                ? scoreValue.toDouble()
                : (scoreValue is double ? scoreValue : 0.0);
            avgScore += score;

            // Count games
            final title = (data['gameTitle'] ?? 'Unknown').toString();
            gameCount[title] = (gameCount[title] ?? 0) + 1;
          }

          avgScore = avgScore / docs.length;

          // Prepare sorted data
          final chartData = gameCount.entries
              .map((e) => _GameData(game: e.key, count: e.value))
              .toList()
            ..sort((a, b) => b.count.compareTo(a.count));

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Average Score: ${avgScore.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Text("Games Played:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Expanded(
                  child: LayoutBuilder(builder: (context, constraints) {
                    double minWidth = chartData.length * 120.0;
                    double chartWidth =
                    minWidth > constraints.maxWidth ? minWidth : constraints.maxWidth;

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: chartWidth,
                          maxWidth: chartWidth,
                          maxHeight: constraints.maxHeight,
                        ),
                        child: CustomPaint(
                          size: Size(chartWidth, constraints.maxHeight),
                          painter: _BarChartPainter(chartData),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GameData {
  final String game;
  final int count;
  _GameData({required this.game, required this.count});
}

/// Custom painter with dynamic colors for each bar
class _BarChartPainter extends CustomPainter {
  final List<_GameData> data;
  final double topPadding = 24;
  final double bottomPadding = 60;
  final double leftPadding = 16;
  final double rightPadding = 16;

  _BarChartPainter(this.data);

  final List<Color> _barColors = [
    Colors.blue,
    Colors.green,
    Colors.pinkAccent,
    Colors.purple,
    Colors.teal,
    Colors.red,
    Colors.indigo,
    Colors.cyan,
    Colors.amber,
    Colors.orange,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final Paint axisPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;

    final double chartHeight = size.height - topPadding - bottomPadding;
    final double chartWidth = size.width - leftPadding - rightPadding;

    // Draw horizontal axis
    final Offset axisStart = Offset(leftPadding, topPadding + chartHeight);
    final Offset axisEnd = Offset(leftPadding + chartWidth, topPadding + chartHeight);
    canvas.drawLine(axisStart, axisEnd, axisPaint);

    if (data.isEmpty) return;

    final int maxCount = data.map((e) => e.count).reduce((a, b) => a > b ? a : b);
    final int gridMax = maxCount <= 0 ? 1 : maxCount;
    final double barAreaWidth = chartWidth / data.length;
    final double barWidth = barAreaWidth * 0.6;

    // Draw horizontal grid lines
    final int gridLines = gridMax < 6 ? gridMax : 6;
    for (int i = 0; i <= gridLines; i++) {
      final double y = topPadding + chartHeight - (chartHeight * (i / gridLines));
      canvas.drawLine(
          Offset(leftPadding, y),
          Offset(leftPadding + chartWidth, y),
          axisPaint..color = Colors.grey.withOpacity(0.15));

      final int value = ((gridMax * i) / gridLines).round();
      final tp = TextPainter(
        text: TextSpan(
          text: value.toString(),
          style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftPadding - tp.width - 6, y - tp.height / 2));
    }

    // Draw bars and labels with dynamic colors
    final random = Random(42); // consistent colors across rebuilds
    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final double xCenter = leftPadding + barAreaWidth * i + barAreaWidth / 2;
      final double barLeft = xCenter - barWidth / 2;
      final double normalized = item.count / gridMax;
      final double barHeight = normalized * chartHeight;
      final double top = topPadding + (chartHeight - barHeight);

      // Pick color dynamically
      final Paint barPaint = Paint()
        ..color = _barColors[i % _barColors.length].withOpacity(0.9);

      // Draw bar background (light)
      final RRect bgRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(barLeft, topPadding, barWidth, chartHeight),
        const Radius.circular(6),
      );
      canvas.drawRRect(bgRect, Paint()..color = Colors.grey.withOpacity(0.06));

      // Draw bar
      final RRect barRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(barLeft, top, barWidth, barHeight),
        const Radius.circular(6),
      );
      canvas.drawRRect(barRect, barPaint);

      // Draw count above bar
      final tpCount = TextPainter(
        text: TextSpan(
          text: item.count.toString(),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tpCount.paint(canvas, Offset(xCenter - tpCount.width / 2, top - tpCount.height - 6));

      // Draw label below axis
      final tpLabel = TextPainter(
        text: TextSpan(
          text: item.game,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLines: 2,
        ellipsis: '...',
      )..layout(maxWidth: barAreaWidth - 8);
      tpLabel.paint(canvas, Offset(xCenter - tpLabel.width / 2, topPadding + chartHeight + 8));
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    if (oldDelegate.data.length != data.length) return true;
    for (int i = 0; i < data.length; i++) {
      if (oldDelegate.data[i].count != data[i].count || oldDelegate.data[i].game != data[i].game) return true;
    }
    return false;
  }
}
