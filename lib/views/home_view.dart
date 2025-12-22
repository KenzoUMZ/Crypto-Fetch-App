import 'package:flutter/material.dart';
import 'package:flutter_gap/flutter_gap.dart';
import 'package:provider/provider.dart';

import '../core/core.dart';
import '../models/asset_model.dart';
import '../viewmodels/asset_view_model.dart';
import '../widgets/asset_card.dart';
import '../widgets/top_three_chart.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
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
      body: RefreshIndicator(
        onRefresh: () => vm.loadAssets(limit: 30),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              pinned: true,
              expandedHeight: 260,
              collapsedHeight: 56,
              backgroundColor: theme.colorScheme.surface,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final double expandRatio =
                      (constraints.maxHeight - 56) / (260 - 56);
                  final bool isExpanded = expandRatio > 0.3;
                  final double opacity = expandRatio.clamp(0.0, 1.0);

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      if (isExpanded)
                        Opacity(
                          opacity: opacity,
                          child: SafeArea(
                            bottom: false,
                            child: SingleChildScrollView(
                              physics: const NeverScrollableScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 12),
                                  TopThreeChart(
                                    top3Assets: vm.topThreeByMarketCap,
                                  ).addPadding(
                                    const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (!isExpanded)
                        Opacity(
                          opacity: 1 - opacity,
                          child: SafeArea(
                            bottom: false,
                            child: Center(
                              child: TopThreeChart(
                                top3Assets: vm.topThreeByMarketCap,
                                compact: true,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            SliverToBoxAdapter(child: const Gap(12)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, i) {
                  if (i.isOdd) {
                    return const Gap(15);
                  }
                  final index = i ~/ 2;
                  if (index >= vm.assets.length) return null;
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

                  return AssetCard(
                    asset: asset,
                    price: '\$${price.formatPrice()}',
                    percent: percent,
                    volume: volume,
                    recentlyChanged: vm.recentlyChanged(asset.id),
                    isFavorite: vm.isFavorite(asset.id),
                    onFavoriteTap: () => vm.toggleFavorite(asset.id),
                  );
                }, childCount: vm.assets.length * 2 - 1),
              ),
            ),
            if (vm.isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
