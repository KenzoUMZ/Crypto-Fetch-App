import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/core.dart';
import '../models/asset_model.dart';
import '../models/assets_response_model.dart';
import '../repositories/asset_repository.dart';

enum AssetStatus { idle, loading, error }

class AssetViewModel extends ChangeNotifier {
  final AssetRepository repository;
  final FavoritesStorage _favoritesStorage = FavoritesStorage();
  final Map<String, double> _livePrices = {};
  final Map<String, double> _livePercent = {};
  final Map<String, double> _liveVolume = {};
  final Map<String, DateTime> _lastUpdated = {};
  final Set<String> _recentlyChanged = {};
  final Map<String, Timer> _highlightTimers = {};
  AssetStatus _status = AssetStatus.idle;
  List<Asset> _assets = const [];
  Set<String> _favorites = {};
  List<BinanceTickersWsClient> _tickerClients = const [];
  int _currentOffset = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String? _error;
  String _searchQuery = '';
  Timer? _refreshTimer;
  AssetStatus get status => _status;
  List<Asset> get assets => _assets;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  Set<String> get favorites => _favorites;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  AssetViewModel({required this.repository}) {
    _initFavorites();
  }

  Future<void> _initFavorites() async {
    _favorites = await _favoritesStorage.loadFavorites();
    notifyListeners();
  }

  Future<void> loadAssets({String? search, int? limit}) async {
    _status = AssetStatus.loading;
    _error = null;
    _searchQuery = search ?? '';
    _currentOffset = 0;
    _hasMore = true;
    notifyListeners();

    try {
      final AssetsResponse response = await repository.fetchAssets(
        search: search,
        limit: limit ?? 30,
        offset: 0,
      );
      _assets = response.data;
      _currentOffset = _assets.length;
      _hasMore = _assets.length >= (limit ?? 30);
      _status = AssetStatus.idle;

      _startBinanceTickerStreams();
      _startPeriodicRefresh();
    } catch (e) {
      _error = e.toString();
      _status = AssetStatus.error;
      _assets = [];
      _hasMore = false;
    }
    notifyListeners();
  }

  Future<void> loadMoreAssets() async {
    if (_isLoadingMore || !_hasMore || _status == AssetStatus.loading) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final AssetsResponse response = await repository.fetchAssets(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        limit: 30,
        offset: _currentOffset,
      );

      if (response.data.isNotEmpty) {
        _assets = [..._assets, ...response.data];
        _currentOffset += response.data.length;
        _hasMore = response.data.length >= 30;
      } else {
        _hasMore = false;
      }
    } catch (e) {
      _hasMore = false;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchQuery = '';
    loadAssets();
  }

  Future<void> toggleFavorite(String? id) async {
    if (id == null || id.isEmpty) return;
    _favorites = await _favoritesStorage.toggleFavorite(id);
    notifyListeners();
  }

  bool isFavorite(String? id) {
    if (id == null || id.isEmpty) return false;
    return _favorites.contains(id);
  }

  double priceFor(String? id, double fallback) {
    if (id == null || id.isEmpty) return fallback;
    return _livePrices[id] ?? fallback;
  }

  double percentFor(String? id, double fallback) {
    if (id == null || id.isEmpty) return fallback;
    return _livePercent[id] ?? fallback;
  }

  double volumeFor(String? id, double fallback) {
    if (id == null || id.isEmpty) return fallback;
    return _liveVolume[id] ?? fallback;
  }

  bool recentlyChanged(String? id) {
    if (id == null || id.isEmpty) return false;
    return _recentlyChanged.contains(id);
  }

  List<Asset> get topThreeByMarketCap {
    if (_assets.length < 3) return const [];
    final list =
        _assets.where((a) => a.marketCapUsdDouble > 0).toList()..sort(
          (a, b) => b.marketCapUsdDouble.compareTo(a.marketCapUsdDouble),
        );
    return list.take(3).toList();
  }

  void _startBinanceTickerStreams() {
    final assets = _assets.where((a) => (a.symbol ?? '').isNotEmpty).toList();
    if (assets.isEmpty) return;

    for (final c in _tickerClients) {
      c.close();
    }
    _tickerClients = [];

    final symbolToId = <String, String>{};
    final pairs = <String>[];
    for (final a in assets) {
      final sym = (a.symbol ?? '').toLowerCase();
      final id = a.id;
      if (sym.isEmpty || id == null) continue;
      symbolToId[sym] = id;
      pairs.add('${sym}usdt');
    }

    const chunkSize = 100;
    for (var i = 0; i < pairs.length; i += chunkSize) {
      final chunk = pairs.sublist(
        i,
        i + chunkSize > pairs.length ? pairs.length : i + chunkSize,
      );
      final client = BinanceTickersWsClient(chunk);
      _tickerClients.add(client);
      client.connect();
      client.tickers.listen((t) {
        final sLower = t.symbol.toLowerCase();
        final sym = sLower.replaceAll('usdt', '');
        final id = symbolToId[sym];
        if (id == null) return;
        _livePrices[id] = t.lastPrice;
        _livePercent[id] = t.priceChangePercent;
        _liveVolume[id] = t.volume;
        _lastUpdated[id] = DateTime.now();
        _recentlyChanged.add(id);
        _highlightTimers[id]?.cancel();
        _highlightTimers[id] = Timer(const Duration(milliseconds: 1000), () {
          _recentlyChanged.remove(id);
          notifyListeners();
        });
        notifyListeners();
      });
    }
  }

  void _startPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) async {
      try {
        final AssetsResponse response = await repository.fetchAssets(
          search: _searchQuery.isEmpty ? null : _searchQuery,
          limit: _assets.length,
        );
        _assets = response.data;
        notifyListeners();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    for (final c in _tickerClients) {
      c.close();
    }
    for (final t in _highlightTimers.values) {
      t.cancel();
    }
    super.dispose();
  }
}
