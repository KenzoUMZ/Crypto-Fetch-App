import '../core/constants/api_endpoints.dart';

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

  double get priceUsdDouble => double.tryParse(priceUsd ?? '') ?? 0.0;
  double get changePercent24HrDouble =>
      double.tryParse(changePercent24Hr ?? '') ?? 0.0;
  double get marketCapUsdDouble => double.tryParse(marketCapUsd ?? '') ?? 0.0;
  double get volumeUsd24HrDouble => double.tryParse(volumeUsd24Hr ?? '') ?? 0.0;
  int get rankInt => int.tryParse(rank ?? '') ?? 0;

  bool get isPositiveChange => changePercent24HrDouble >= 0;

  String? get iconUrl {
    if (symbol == null) return null;
    return ApiEndpoints.assetIcon(symbol!);
  }
}
