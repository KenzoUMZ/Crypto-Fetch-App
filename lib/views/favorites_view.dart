import 'package:flutter/material.dart';
import 'package:flutter_gap/flutter_gap.dart';
import 'package:provider/provider.dart';

import '../core/extensions/string_extensions.dart';
import '../models/asset_model.dart';
import '../viewmodels/asset_view_model.dart';
import '../widgets/asset_card.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  String _formatPrice(double price) {
    if (price >= 1000) {
      return price.toStringAsFixed(2);
    } else if (price >= 1) {
      return price.toStringAsFixed(4);
    } else {
      return price.toStringAsFixed(6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final vm = context.watch<AssetViewModel>();
    final favorites = vm.favorites;
    final assets = vm.assets.where((a) => favorites.contains(a.id)).toList();

    return Scaffold(
      appBar: AppBar(title: Text('favorites'.translate())),
      body:
          assets.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 80,
                      color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    const Gap(24),
                    Text(
                      'no_favorites'.translate(),
                      style: theme.textTheme.headlineSmall,
                    ),
                    const Gap(8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Text(
                        'add_favorites'.translate(),
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              )
              : ListView.separated(
                itemCount: assets.length,
                separatorBuilder: (_, __) => const Gap(12),
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final Asset asset = assets[index];
                  final symbol = (asset.symbol ?? '').toUpperCase();
                  final clippedSymbol =
                      symbol.isEmpty
                          ? '?'
                          : symbol.substring(
                            0,
                            symbol.length > 3 ? 3 : symbol.length,
                          );

                  return AssetCard(
                    leading: clippedSymbol,
                    title: asset.name ?? 'unknown'.translate(),
                    subtitle:
                        '${symbol.isNotEmpty ? symbol : 'unknown_symbol'.translate()} • Rank #${asset.rank ?? '-'}',
                    price: '\$${_formatPrice(asset.priceUsdDouble)}',
                    percent: asset.changePercent24HrDouble,
                    volume: asset.volumeUsd24HrDouble,
                    recentlyChanged: false,
                    isFavorite: true,
                    onFavoriteTap: () => vm.toggleFavorite(asset.id),
                  );
                },
              ),
    );
  }
}
