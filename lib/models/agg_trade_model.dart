class AggTrade {
  final String? eventType;
  final int? eventTime;
  final String? symbol;
  final int? aggregateTradeId;
  final String? price;
  final String? quantity;
  final int? firstTradeId;
  final int? lastTradeId;
  final int? tradeTime;
  final bool? isBuyerMarketMaker;

  const AggTrade({
    this.eventType,
    this.eventTime,
    this.symbol,
    this.aggregateTradeId,
    this.price,
    this.quantity,
    this.firstTradeId,
    this.lastTradeId,
    this.tradeTime,
    this.isBuyerMarketMaker,
  });

  factory AggTrade.fromJson(Map<String, dynamic> json) {
    return AggTrade(
      eventType: json['e'] as String?,
      eventTime: (json['E'] as num?)?.toInt(),
      symbol: json['s'] as String?,
      aggregateTradeId: (json['a'] as num?)?.toInt(),
      price: json['p'] as String?,
      quantity: json['q'] as String?,
      firstTradeId: (json['f'] as num?)?.toInt(),
      lastTradeId: (json['l'] as num?)?.toInt(),
      tradeTime: (json['T'] as num?)?.toInt(),
      isBuyerMarketMaker: json['m'] as bool?,
    );
  }

  double get priceDouble => double.tryParse(price ?? '') ?? 0.0;
  double get quantityDouble => double.tryParse(quantity ?? '') ?? 0.0;
}
