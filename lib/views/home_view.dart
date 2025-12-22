import 'package:flutter/material.dart';
import 'package:flutter_gap/flutter_gap.dart';
import 'package:provider/provider.dart';

import '../core/extensions/double_extensions.dart';
import '../core/extensions/string_extensions.dart';
import '../core/extensions/widget_extensions.dart';
import '../models/asset_model.dart';
import '../viewmodels/asset_view_model.dart';
import '../viewmodels/market_stream_view_model.dart';
import '../widgets/asset_card.dart';
import '../widgets/stream_header.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AssetViewModel>();
    final theme = Theme.of(context);
    final market = context.watch<MarketStreamViewModel>();

    if (vm.status == AssetStatus.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (vm.status == AssetStatus.error) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const Gap(16),
              Text(
                'error_loading'.translate(),
                style: theme.textTheme.titleLarge,
              ),
              const Gap(8),
              Text(
                vm.error ?? 'unknown_error'.translate(),
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const Gap(16),
              FilledButton.icon(
                onPressed: () => vm.loadAssets(limit: 100),
                icon: const Icon(Icons.refresh),
                label: Text('try_again'.translate()),
              ),
            ],
          ),
        ),
      );
    }

    if (vm.assets.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.currency_bitcoin,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const Gap(16),
              Text(
                'no_assets_found'.translate(),
                style: theme.textTheme.titleLarge,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          StreamHeader(market: market).addPadding(
            const EdgeInsets.only(top: 48, bottom: 12, left: 12, right: 12),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => vm.loadAssets(limit: 100),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: vm.assets.length,
                separatorBuilder: (_, __) => const Gap(15),
                itemBuilder: (context, index) {
                  final Asset asset = vm.assets[index];
                  final percent = vm.percentFor(
                    asset.id,
                    asset.changePercent24HrDouble,
                  );
                  final volume = vm.volumeFor(
                    asset.id,
                    asset.volumeUsd24HrDouble,
                  );
                  final price = vm.priceFor(asset.id, asset.priceUsdDouble);
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

                  return AssetCard(
                    leading: clippedSymbol,
                    title: displayName,
                    subtitle:
                        '${displaySymbol.isNotEmpty ? displaySymbol : 'unknown_symbol'.translate()} • Rank #$displayRank',
                    price: '\$${price.formatPrice()}',
                    percent: percent,
                    volume: volume,
                    recentlyChanged: vm.recentlyChanged(asset.id),
                    isFavorite: vm.isFavorite(asset.id),
                    onFavoriteTap: () => vm.toggleFavorite(asset.id),
                  ).addPadding(const EdgeInsets.symmetric(horizontal: 12));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
