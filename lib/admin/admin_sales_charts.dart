import 'dart:math' as math;

import 'package:flutter/material.dart';

class AdminSalesCharts extends StatelessWidget {
  const AdminSalesCharts({
    required this.weeklyData,
    required this.monthlyData,
    super.key,
  });

  static const Color _currentMonthColor = Color(0xFF8A65C7);
  static const Color _previousMonthColor = Color(0xFFD8C9F0);

  final Map<String, dynamic> weeklyData;
  final Map<String, dynamic> monthlyData;

  static const List<Color> _seriesColors = [
    Color(0xFF5479D8),
    Color(0xFF39966A),
    Color(0xFFD28B31),
  ];

  List<Map<String, dynamic>> _series(Map<String, dynamic> data) {
    final rawSeries = data['series'];
    if (rawSeries is! List) return [];

    return rawSeries
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  double _number(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final weeklySeries = _series(weeklyData);
    final monthlySeries = _series(monthlyData);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 26),
        const Text(
          'Tren Penjualan per PK',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: Color(0xFF332745),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Total pesanan yang pembayarannya sudah dikonfirmasi dalam 7 hari terakhir.',
          style: TextStyle(color: Colors.black54, height: 1.4),
        ),
        const SizedBox(height: 12),
        _weeklyChart(weeklySeries),
        const SizedBox(height: 22),
        const Text(
          'Perbandingan Penjualan Bulanan',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: Color(0xFF332745),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Bulan ini dibandingkan bulan lalu pada rentang tanggal yang sama.',
          style: TextStyle(color: Colors.black54, height: 1.4),
        ),
        const SizedBox(height: 12),
        _monthlyChart(monthlySeries),
      ],
    );
  }

  Widget _weeklyChart(List<Map<String, dynamic>> series) {
    final chartSeries = <_LineSeries>[];
    var labels = <String>[];

    for (var index = 0; index < series.length; index++) {
      final item = series[index];
      final rawData = item['data'];
      if (rawData is! List) continue;

      final points = rawData.whereType<Map>().toList();
      if (labels.isEmpty) {
        labels = points
            .map((point) => point['tanggal']?.toString() ?? '')
            .toList();
      }

      chartSeries.add(
        _LineSeries(
          name: item['nama_pk']?.toString() ?? 'PK ${index + 1}',
          color: _seriesColors[index % _seriesColors.length],
          values: points
              .map((point) => _number(point['total_penjualan']))
              .toList(),
        ),
      );
    }

    if (chartSeries.isEmpty || labels.isEmpty) {
      return _emptyChart('Data penjualan mingguan belum tersedia.');
    }

    return _chartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 220,
            width: double.infinity,
            child: CustomPaint(
              painter: _WeeklySalesPainter(labels: labels, series: chartSeries),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: chartSeries
                .map((item) => _LegendItem(color: item.color, label: item.name))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _monthlyChart(List<Map<String, dynamic>> series) {
    if (series.isEmpty) {
      return _emptyChart('Data perbandingan penjualan belum tersedia.');
    }

    final categories = series.map((item) {
      final change = item['perubahan_persen'] == null
          ? null
          : _number(item['perubahan_persen']);
      return _MonthlySales(
        name: item['nama_pk']?.toString() ?? 'Kantin ${item['nomor_kantin']}',
        current: _number(item['penjualan_bulan_ini']),
        previous: _number(item['penjualan_bulan_lalu']),
        changePercent: change,
      );
    }).toList();

    return _chartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _LegendItem(color: _currentMonthColor, label: 'Bulan ini'),
              _LegendItem(color: _previousMonthColor, label: 'Bulan lalu'),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 230,
            width: double.infinity,
            child: CustomPaint(
              painter: _MonthlySalesPainter(categories: categories),
            ),
          ),
          const Divider(height: 24),
          ...categories.map(_monthlyChangeRow),
        ],
      ),
    );
  }

  Widget _monthlyChangeRow(_MonthlySales item) {
    final change = item.changePercent;
    final hasDecrease = change != null && change < 0;
    final color = change == null
        ? Colors.black54
        : hasDecrease
        ? const Color(0xFFB3261E)
        : const Color(0xFF21834A);
    final changeLabel = change == null
        ? 'Belum ada pembanding'
        : '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}%';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            changeLabel,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          if (change != null) ...[
            const SizedBox(width: 4),
            Icon(
              hasDecrease ? Icons.trending_down : Icons.trending_up,
              size: 18,
              color: color,
            ),
          ],
        ],
      ),
    );
  }

  Widget _chartCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDE6F7)),
      ),
      child: child,
    );
  }

  Widget _emptyChart(String message) {
    return _chartCard(
      child: SizedBox(
        height: 100,
        child: Center(child: Text(message, textAlign: TextAlign.center)),
      ),
    );
  }
}

class _LineSeries {
  const _LineSeries({
    required this.name,
    required this.color,
    required this.values,
  });

  final String name;
  final Color color;
  final List<double> values;
}

class _MonthlySales {
  const _MonthlySales({
    required this.name,
    required this.current,
    required this.previous,
    required this.changePercent,
  });

  final String name;
  final double current;
  final double previous;
  final double? changePercent;
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _WeeklySalesPainter extends CustomPainter {
  const _WeeklySalesPainter({required this.labels, required this.series});

  final List<String> labels;
  final List<_LineSeries> series;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 54.0;
    const right = 8.0;
    const top = 12.0;
    const bottom = 32.0;
    final chartWidth = math.max(0.0, size.width - left - right);
    final chartHeight = math.max(0.0, size.height - top - bottom);
    if (chartWidth == 0 || chartHeight == 0) return;

    final maxValue = series
        .expand((item) => item.values)
        .fold<double>(0, math.max);
    final ceiling = _niceCeiling(maxValue);

    for (var tick = 0; tick <= 4; tick++) {
      final y = top + chartHeight * tick / 4;
      final value = ceiling * (4 - tick) / 4;
      _drawText(
        canvas,
        _compactCurrency(value),
        Offset(0, y - 7),
        maxWidth: left - 6,
        align: TextAlign.right,
      );
      canvas.drawLine(
        Offset(left, y),
        Offset(left + chartWidth, y),
        Paint()
          ..color = const Color(0xFFEDE8F4)
          ..strokeWidth = 1,
      );
    }

    for (var index = 0; index < labels.length; index++) {
      final x =
          left +
          (labels.length <= 1
              ? chartWidth / 2
              : chartWidth * index / (labels.length - 1));
      _drawText(
        canvas,
        _dayLabel(labels[index]),
        Offset(x - 18, top + chartHeight + 8),
        maxWidth: 36,
        align: TextAlign.center,
      );
    }

    for (final item in series) {
      final points = <Offset>[];
      for (var index = 0; index < labels.length; index++) {
        final value = index < item.values.length ? item.values[index] : 0;
        final x =
            left +
            (labels.length <= 1
                ? chartWidth / 2
                : chartWidth * index / (labels.length - 1));
        final y = top + chartHeight - (value / ceiling * chartHeight);
        points.add(Offset(x, y));
      }

      if (points.length > 1) {
        final path = Path()..moveTo(points.first.dx, points.first.dy);
        for (final point in points.skip(1)) {
          path.lineTo(point.dx, point.dy);
        }
        canvas.drawPath(
          path,
          Paint()
            ..color = item.color
            ..strokeWidth = 2.5
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round,
        );
      }

      for (final point in points) {
        canvas.drawCircle(point, 4, Paint()..color = item.color);
        canvas.drawCircle(point, 2, Paint()..color = Colors.white);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WeeklySalesPainter oldDelegate) =>
      oldDelegate.labels != labels || oldDelegate.series != series;
}

class _MonthlySalesPainter extends CustomPainter {
  const _MonthlySalesPainter({required this.categories});

  final List<_MonthlySales> categories;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 54.0;
    const right = 8.0;
    const top = 12.0;
    const bottom = 44.0;
    final chartWidth = math.max(0.0, size.width - left - right);
    final chartHeight = math.max(0.0, size.height - top - bottom);
    if (chartWidth == 0 || chartHeight == 0 || categories.isEmpty) return;

    final maxValue = categories.fold<double>(0, (max, item) {
      return math.max(max, math.max(item.current, item.previous));
    });
    final ceiling = _niceCeiling(maxValue);
    for (var tick = 0; tick <= 4; tick++) {
      final y = top + chartHeight * tick / 4;
      final value = ceiling * (4 - tick) / 4;
      _drawText(
        canvas,
        _compactCurrency(value),
        Offset(0, y - 7),
        maxWidth: left - 6,
        align: TextAlign.right,
      );
      canvas.drawLine(
        Offset(left, y),
        Offset(left + chartWidth, y),
        Paint()
          ..color = const Color(0xFFEDE8F4)
          ..strokeWidth = 1,
      );
    }

    final groupWidth = chartWidth / categories.length;
    final barWidth = math.min(22.0, groupWidth * 0.26);
    for (var index = 0; index < categories.length; index++) {
      final item = categories[index];
      final center = left + groupWidth * (index + 0.5);
      final currentHeight = item.current / ceiling * chartHeight;
      final previousHeight = item.previous / ceiling * chartHeight;
      final radius = const Radius.circular(4);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            center - barWidth - 2,
            top + chartHeight - currentHeight,
            barWidth,
            currentHeight,
          ),
          radius,
        ),
        Paint()..color = const Color(0xFF8A65C7),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            center + 2,
            top + chartHeight - previousHeight,
            barWidth,
            previousHeight,
          ),
          radius,
        ),
        Paint()..color = const Color(0xFFD8C9F0),
      );
      _drawText(
        canvas,
        _shortName(item.name),
        Offset(center - groupWidth / 2, top + chartHeight + 9),
        maxWidth: groupWidth,
        align: TextAlign.center,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MonthlySalesPainter oldDelegate) =>
      oldDelegate.categories != categories;
}

double _niceCeiling(double value) {
  if (value <= 0) return 1;
  return value * 1.15;
}

String _compactCurrency(double value) {
  if (value >= 1000000) return 'Rp${(value / 1000000).toStringAsFixed(1)}jt';
  if (value >= 1000) return 'Rp${(value / 1000).toStringAsFixed(0)}rb';
  return 'Rp${value.toStringAsFixed(0)}';
}

String _dayLabel(String value) {
  final date = DateTime.tryParse(value);
  if (date == null) return value;
  return '${date.day}/${date.month}';
}

String _shortName(String value) {
  if (value.length <= 12) return value;
  return '${value.substring(0, 10)}…';
}

void _drawText(
  Canvas canvas,
  String text,
  Offset offset, {
  required double maxWidth,
  TextAlign align = TextAlign.left,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: const TextStyle(fontSize: 9, color: Color(0xFF756A82)),
    ),
    textDirection: TextDirection.ltr,
    textAlign: align,
    maxLines: 1,
  )..layout(maxWidth: maxWidth);
  painter.paint(canvas, offset);
}
