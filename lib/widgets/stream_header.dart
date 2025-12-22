import 'package:flutter/material.dart';
import 'package:flutter_gap/flutter_gap.dart';

import '../core/extensions/double_extensions.dart';
import '../core/extensions/string_extensions.dart';
import '../viewmodels/market_stream_view_model.dart';

class StreamHeader extends StatelessWidget {
  final MarketStreamViewModel market;
  final String symbol;

  const StreamHeader({
    super.key,
    required this.market,
    this.symbol = 'BTCUSDT',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trade = market.lastAggTrade;
    final priceText =
        trade != null ? trade.priceDouble.formatPrice() : 'unknown'.translate();
    final qtyText =
        trade != null ? trade.quantityDouble.toStringAsFixed(4) : '-';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.show_chart, color: theme.colorScheme.primary),
            const Gap(8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(symbol, style: theme.textTheme.titleMedium),
                  const Gap(4),
                  Text(
                    'Price \$$priceText • Qty $qtyText',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (market.connected)
              const Icon(Icons.circle, color: Colors.green, size: 10)
            else
              const Icon(Icons.circle, color: Colors.grey, size: 10),
          ],
        ),
      ),
    );
  }
}
