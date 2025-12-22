import 'package:flutter/material.dart';
import 'package:flutter_gap/flutter_gap.dart';
import 'package:provider/provider.dart';

import '../core/extensions/string_extensions.dart';
import '../models/asset_model.dart';
import '../viewmodels/asset_view_model.dart';
import '../widgets/asset_card.dart';

class AssetsSearchView extends StatefulWidget {
  const AssetsSearchView({super.key});

  @override
  State<AssetsSearchView> createState() => _AssetsSearchViewState();
}

class _AssetsSearchViewState extends State<AssetsSearchView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AssetViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(35),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'search_hint'.translate(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            vm.clearSearch();
                          },
                        )
                        : null,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  vm.loadAssets(search: value.trim());
                } else {
                  vm.clearSearch();
                }
              },
            ),
          ),
        ),
      ),
      body: _buildBody(vm, theme),
    );
  }

  Widget _buildBody(AssetViewModel vm, ThemeData theme) {
    if (vm.status == AssetStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.status == AssetStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
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
              onPressed: () => vm.loadAssets(search: vm.searchQuery),
              icon: const Icon(Icons.refresh),
              label: Text('try_again'.translate()),
            ),
          ],
        ),
      );
    }

    if (vm.assets.isEmpty) {
      return Center(
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
            if (vm.searchQuery.isNotEmpty) ...[
              const Gap(8),
              Text('Tente outra busca', style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => vm.loadAssets(search: vm.searchQuery),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: vm.assets.length,
        separatorBuilder: (_, __) => const Gap(12),
        itemBuilder: (context, index) {
          final Asset asset = vm.assets[index];

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

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: AssetCard(
              leading: clippedSymbol,
              title: displayName,
              subtitle:
                  '${displaySymbol.isNotEmpty ? displaySymbol : 'unknown_symbol'.translate()} • Rank #$displayRank',
              price: '\$${_formatPrice(asset.priceUsdDouble)}',
              percent: asset.changePercent24HrDouble,
              volume: asset.volumeUsd24HrDouble,
              recentlyChanged: false,
              isFavorite: vm.isFavorite(asset.id),
              onFavoriteTap: () => vm.toggleFavorite(asset.id),
            ),
          );
        },
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return price.toStringAsFixed(2);
    } else if (price >= 1) {
      return price.toStringAsFixed(4);
    } else {
      return price.toStringAsFixed(6);
    }
  }
}
