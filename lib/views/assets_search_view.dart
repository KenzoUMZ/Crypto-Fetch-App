import 'package:flutter/material.dart';
import 'package:flutter_gap/flutter_gap.dart';
import 'package:provider/provider.dart';

import '../core/core.dart';
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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final _ = context.read<AssetViewModel>()..loadMoreAssets();
    }
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
      body:
          vm.status == AssetStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : vm.status == AssetStatus.error
              ? Center(
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
                      onPressed: () => vm.loadAssets(search: vm.searchQuery),
                      icon: const Icon(Icons.refresh),
                      label: Text('try_again'.translate()),
                    ),
                  ],
                ),
              )
              : vm.assets.isEmpty
              ? Center(
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
                      Text(
                        'Tente outra busca',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: () => vm.loadAssets(search: vm.searchQuery),
                child: ListView.separated(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: vm.assets.length + (vm.isLoadingMore ? 1 : 0),
                  separatorBuilder: (_, __) => const Gap(12),
                  itemBuilder: (context, index) {
                    if (index >= vm.assets.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final Asset asset = vm.assets[index];

                    return AssetCard(
                      asset: asset,
                      price: '\$${asset.priceUsdDouble.formatPrice()}',
                      percent: asset.changePercent24HrDouble,
                      volume: asset.volumeUsd24HrDouble,
                      recentlyChanged: false,
                      isFavorite: vm.isFavorite(asset.id),
                      onFavoriteTap: () => vm.toggleFavorite(asset.id),
                    );
                  },
                ),
              ),
    );
  }
}
