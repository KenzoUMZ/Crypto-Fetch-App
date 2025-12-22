import 'package:flutter/material.dart';
import 'package:flutter_gap/flutter_gap.dart';

class AssetCard extends StatelessWidget {
  final String? leading;
  final String title;
  final String subtitle;
  final String price;
  final double percent;
  final double volume;
  final bool recentlyChanged;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  const AssetCard({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.percent,
    required this.volume,
    required this.recentlyChanged,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = percent >= 0;
    final changeColor = isPositive ? Colors.green : Colors.red;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        dense: true,
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            leading ?? '?',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
        trailing: Row(
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
            const Gap(12),
            IconButton(
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
              color:
                  isFavorite
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
              onPressed: onFavoriteTap,
            ),
          ],
        ),
      ),
    );
  }
}
