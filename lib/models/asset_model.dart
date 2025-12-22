import '../core/extensions/string_extensions.dart';

class Asset {
  final String? id;
  final String? rank;
  final String? symbol;
  final String? name;
  final String? supply;
  final String? maxSupply;
  final String? marketCapUsd;
  final String? volumeUsd24Hr;
  final String? priceUsd;
  final String? changePercent24Hr;
  final String? vwap24Hr;
  final String? explorer;
  final Map<String, dynamic>? tokens;

  const Asset({
    this.id,
    this.rank,
    this.symbol,
    this.name,
    this.supply,
    this.maxSupply,
    this.marketCapUsd,
    this.volumeUsd24Hr,
    this.priceUsd,
    this.changePercent24Hr,
    this.vwap24Hr,
    this.explorer,
    this.tokens,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'] as String?,
      rank: json['rank'] as String?,
      symbol: json['symbol'] as String?,
      name: json['name'] as String?,
      supply: json['supply'] as String?,
      maxSupply: json['maxSupply'] as String?,
      marketCapUsd: json['marketCapUsd'] as String?,
      volumeUsd24Hr: json['volumeUsd24Hr'] as String?,
      priceUsd: json['priceUsd'] as String?,
      changePercent24Hr: json['changePercent24Hr'] as String?,
      vwap24Hr: json['vwap24Hr'] as String?,
      explorer: json['explorer'] as String?,
      tokens: json['tokens'] as Map<String, dynamic>?,
    );
  }

  // Getters com parse numérico
  double get priceUsdDouble => double.tryParse(priceUsd ?? '') ?? 0.0;
  double get changePercent24HrDouble =>
      double.tryParse(changePercent24Hr ?? '') ?? 0.0;
  double get marketCapUsdDouble => double.tryParse(marketCapUsd ?? '') ?? 0.0;
  double get volumeUsd24HrDouble => double.tryParse(volumeUsd24Hr ?? '') ?? 0.0;
  int get rankInt => int.tryParse(rank ?? '') ?? 0;

  bool get isPositiveChange => changePercent24HrDouble >= 0;

  /// Mapa de IDs da API para nomes de ícones no CoinCap
  static const Map<String, String> _iconNameMap = {
    'bitcoin': 'btc',
    'ethereum': 'eth',
    'tether': 'usdt',
    'ripple': 'xrp',
    'binance-coin': 'bnb',
    'solana': 'sol',
    'cardano': 'ada',
    'dogecoin': 'doge',
    'polkadot': 'dot',
    'litecoin': 'ltc',
    'bitcoin-cash': 'bch',
    'chainlink': 'link',
    'stellar': 'xlm',
    'monero': 'xmr',
    'uniswap': 'uni',
    'wrapped-bitcoin': 'wbtc',
    'aave': 'aave',
    'compound': 'comp',
    'maker': 'mkr',
    'yearn-finance': 'yfi',
  };

  String? get iconUrl {
    if (id == null) return null;

    // Primeiro tenta encontrar um mapeamento direto
    final mappedName = _iconNameMap[id];
    final iconName = mappedName ?? id!.normalizeForIconUrl();

    return 'https://assets.coincap.io/assets/icons/$iconName@2x.png';
  }
}
