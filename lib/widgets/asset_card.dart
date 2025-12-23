import 'package:flutter/material.dart';

import '../core/core.dart';
import '../models/asset_model.dart';
import 'crypto_avatar.dart';

class AssetCard extends StatelessWidget {
  final Asset asset;
  final String price;
  final double percent;
  final double volume;
  final bool recentlyChanged;
  final Widget? trailing;

  const AssetCard({
    super.key,
    required this.asset,
    required this.price,
    required this.percent,
    required this.volume,
    required this.recentlyChanged,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = percent >= 0;
    final changeColor = isPositive ? Colors.green : Colors.red;

    final displaySymbol = (asset.symbol ?? '').toUpperCase();
    final clippedSymbol =
        displaySymbol.isNotEmpty
            ? displaySymbol.substring(
              0,
              displaySymbol.length > 3 ? 3 : displaySymbol.length,
            )
            : '?';
    final displayName = asset.name ?? 'unknown'.translate();
    final displayRank = asset.rank ?? '-';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        dense: true,
        leading: CryptoAvatar(
          iconUrl: asset.iconUrl,
          leading: clippedSymbol,
          theme: theme,
        ),
        title: Text(
          displayName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${displaySymbol.isNotEmpty ? displaySymbol : 'unknown'} • Rank #$displayRank',
          style: theme.textTheme.bodySmall,
        ),
        trailing:
            trailing ??
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: changeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${isPositive ? '+' : ''}${percent.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: changeColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
      ),
    );
  }
}
