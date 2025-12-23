import 'dart:async';

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
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<Asset> _topAssets = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    _loadTop3Assets();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final value = _searchController.text.trim();
      if (value.isNotEmpty) {
        context.read<AssetViewModel>().loadAssets(search: value);
      } else {
        context.read<AssetViewModel>().loadAssets(limit: 30).then((_) {
          if (mounted) _loadTop3Assets();
        });
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final _ = context.read<AssetViewModel>()..loadMoreAssets();
    }
  }

  Future<void> _loadTop3Assets() async {
    final vm = context.read<AssetViewModel>();
    if (vm.assets.isEmpty && vm.status != AssetStatus.loading) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (vm.topThreeByMarketCap.isNotEmpty && mounted) {
      setState(() {
        _topAssets = vm.topThreeByMarketCap;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AssetViewModel>();
    final theme = Theme.of(context);

    if (vm.status == AssetStatus.loading && vm.assets.isEmpty) {
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

    return Scaffold(
      body: RefreshIndicator(
        onRefresh:
            () => vm.loadAssets(
              limit: 30,
              search:
                  _searchController.text.trim().isEmpty
                      ? null
                      : _searchController.text.trim(),
            ),
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
                                    topAssets:
                                        _topAssets.isEmpty
                                            ? vm.topThreeByMarketCap
                                            : _topAssets,
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
                                topAssets:
                                    _topAssets.isEmpty
                                        ? vm.topThreeByMarketCap
                                        : _topAssets,
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
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'search_hint'.translate(),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (vm.status == AssetStatus.loading)
                                    const Padding(
                                      padding: EdgeInsets.only(right: 8),
                                      child: SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                  ),
                                ],
                              )
                              : null,
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (value) {
                      _debounce?.cancel();
                      if (value.trim().isNotEmpty) {
                        vm.loadAssets(search: value.trim());
                      } else {
                        vm.loadAssets(limit: 30);
                      }
                    },
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: const Gap(4)),
            if (vm.assets.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                      ),
                      const Gap(16),
                      Text(
                        'no_assets_found'.translate(),
                        style: theme.textTheme.titleLarge,
                      ),
                      const Gap(8),
                      Text(
                        'try_another_search'.translate(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${price.formatPrice()}',
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
                                  color: (percent >= 0
                                          ? Colors.green
                                          : Colors.red)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${percent >= 0 ? '+' : ''}${percent.toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    color:
                                        percent >= 0
                                            ? Colors.green
                                            : Colors.red,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Gap(12),
                          IconButton(
                            icon: Icon(
                              vm.isFavorite(asset.id)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                            ),
                            color:
                                vm.isFavorite(asset.id)
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                            onPressed: () => vm.toggleFavorite(asset.id),
                          ),
                        ],
                      ),
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
