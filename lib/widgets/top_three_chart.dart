import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/core.dart';
import '../models/asset_model.dart';

class TopThreeChart extends StatelessWidget {
  final List<Asset> top3Assets;
  final bool compact;

  const TopThreeChart({
    super.key,
    required this.top3Assets,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (top3Assets.length < 3) {
      return const SizedBox.shrink();
    }
    final top3 = top3Assets;
    final values = top3Assets.map((a) => a.marketCapUsdDouble).toList();
    final total = values.fold<double>(0, (sum, v) => sum + v);
    final colors = AppColors.medalColors;

    if (compact) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: SizedBox(
          height: 24,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: top3.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _CompactLegendItem(
                color: colors[index % colors.length],
                label: _symbolLabel(top3[index]),
                percent: _formatPercent(values[index], total),
              );
            },
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'top3_marketcap_title'.translate(),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 160,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: CustomPaint(
                          painter: _PieChartPainter(
                            values: values,
                            colors: colors,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 140,
                  child: _LegendList(
                    items: [
                      _LegendItem(
                        color: colors[0],
                        label: _symbolLabel(top3[0]),
                        valueLabel: _formatPercent(values[0], total),
                      ),
                      _LegendItem(
                        color: colors[1],
                        label: _symbolLabel(top3[1]),
                        valueLabel: _formatPercent(values[1], total),
                      ),
                      _LegendItem(
                        color: colors[2],
                        label: _symbolLabel(top3[2]),
                        valueLabel: _formatPercent(values[2], total),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatPercent(double value, double total) {
    if (total <= 0) return '0%';
    final pct = value / total * 100;
    return '${pct.toStringAsFixed(1)}%';
  }

  String _symbolLabel(Asset a) {
    return a.symbol?.toUpperCase() ?? a.name ?? '-';
  }
}

class _PieChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  _PieChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final total = values.fold<double>(0, (sum, v) => sum + v);
    if (total <= 0) return;

    final paint =
        Paint()
          ..style = PaintingStyle.fill
          ..isAntiAlias = true;

    double startAngle = -math.pi / 2;
    for (int i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * 2 * math.pi;
      paint.color = colors[i % colors.length];
      canvas.drawArc(rect, startAngle, sweep, true, paint);
      startAngle += sweep;
    }

    final centerPaint =
        Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.black.withValues(alpha: 0.06);
    final radius = math.min(size.width, size.height) * 0.35;
    canvas.drawCircle(size.center(Offset.zero), radius, centerPaint);
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    if (oldDelegate.values.length != values.length) return true;
    for (int i = 0; i < values.length; i++) {
      if (oldDelegate.values[i] != values[i]) return true;
    }
    return false;
  }
}

class _LegendItem {
  final Color color;
  final String label;
  final String valueLabel;

  _LegendItem({
    required this.color,
    required this.label,
    required this.valueLabel,
  });
}

class _CompactLegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String percent;

  const _CompactLegendItem({
    required this.color,
    required this.label,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$label $percent',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _LegendList extends StatelessWidget {
  final List<_LegendItem> items;
  const _LegendList({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children:
          items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: item.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${item.label} • ${item.valueLabel}',
                          style: theme.textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }
}
