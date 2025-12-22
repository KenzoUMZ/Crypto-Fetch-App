import 'package:flutter/material.dart';
import 'package:flutter_gap/flutter_gap.dart';
import 'package:provider/provider.dart';

import '../core/core.dart';
import '../models/asset_model.dart';
import '../viewmodels/asset_view_model.dart';
import '../widgets/asset_card.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

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
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: 40,
                ),
                itemBuilder: (context, index) {
                  final Asset asset = assets[index];

                  return AssetCard(
                    asset: asset,
                    price: '\$${asset.priceUsdDouble.formatPrice()}',
                    percent: asset.changePercent24HrDouble,
                    volume: asset.volumeUsd24HrDouble,
                    recentlyChanged: false,
                    isFavorite: true,
                    onFavoriteTap: () async {
                      final confirmed = await context
                          .showConfirmationBottomSheet(
                            title: 'remove_favorite'.translate(),
                            message: 'remove_favorite_message'.translate(),
                            confirmText: 'remove'.translate(),
                            cancelText: 'cancel'.translate(),
                            isDangerous: true,
                          );

                      if (confirmed == true) {
                        vm.toggleFavorite(asset.id);
                      }
                    },
                  );
                },
              ),
    );
  }
}
