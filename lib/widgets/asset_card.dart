import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gap/flutter_gap.dart';
import 'package:http/http.dart' as http;

import '../models/asset_model.dart';

class _CryptoAvatar extends StatefulWidget {
  final String? iconUrl;
  final String? leading;
  final ThemeData theme;

  const _CryptoAvatar({
    required this.iconUrl,
    required this.leading,
    required this.theme,
  });

  @override
  State<_CryptoAvatar> createState() => _CryptoAvatarState();
}

class _CryptoAvatarState extends State<_CryptoAvatar> {
  late Future<bool> _imageAvailable;

  @override
  void initState() {
    super.initState();
    _imageAvailable = _checkImageAvailability();
  }

  Future<bool> _checkImageAvailability() async {
    if (widget.iconUrl == null || widget.iconUrl!.isEmpty) {
      return false;
    }
    try {
      final response = await http
          .head(Uri.parse(widget.iconUrl!), headers: {'Connection': 'close'})
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _imageAvailable,
      builder: (context, snapshot) {
        final imageAvailable = snapshot.data ?? false;

        if (imageAvailable && widget.iconUrl != null) {
          return SizedBox(
            width: 40,
            height: 40,
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: widget.iconUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => CircleAvatar(
                  backgroundColor: widget.theme.colorScheme.primaryContainer,
                  radius: 20,
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: widget.theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => CircleAvatar(
                  backgroundColor: widget.theme.colorScheme.primaryContainer,
                  radius: 20,
                  child: Text(
                    widget.leading ?? '?',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: widget.theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return CircleAvatar(
          backgroundColor: widget.theme.colorScheme.primaryContainer,
          radius: 20,
          child: Text(
            widget.leading ?? '?',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: widget.theme.colorScheme.onPrimaryContainer,
            ),
          ),
        );
      },
    );
  }
}

class AssetCard extends StatelessWidget {
  final Asset asset;
  final String price;
  final double percent;
  final double volume;
  final bool recentlyChanged;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  const AssetCard({
    super.key,
    required this.asset,
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

    final displaySymbol = (asset.symbol ?? '').toUpperCase();
    final clippedSymbol =
        displaySymbol.isNotEmpty
            ? displaySymbol.substring(
              0,
              displaySymbol.length > 3 ? 3 : displaySymbol.length,
            )
            : '?';
    final displayName = asset.name ?? 'Desconhecido';
    final displayRank = asset.rank ?? '-';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        dense: true,
        leading: _CryptoAvatar(
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
