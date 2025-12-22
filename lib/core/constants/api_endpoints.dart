/// Endpoints da API CoinCap
class ApiEndpoints {
  // Base URL
  static const String baseUrl = 'https://rest.coincap.io/v3';

  // Assets
  static const String assets = '/assets';
  static String assetById(String id) => '/assets/$id';
  static String assetHistory(String id) => '/assets/$id/history';
  static String assetMarkets(String id) => '/assets/$id/markets';

  // Rates
  static const String rates = '/rates';
  static String rateById(String id) => '/rates/$id';

  // Exchanges
  static const String exchanges = '/exchanges';
  static String exchangeById(String id) => '/exchanges/$id';

  // Markets
  static const String markets = '/markets';

  // Candles
  static String candles({
    required String exchange,
    required String interval,
    required String baseId,
    required String quoteId,
  }) =>
      '/candles?exchange=$exchange&interval=$interval&baseId=$baseId&quoteId=$quoteId';

  ApiEndpoints._();
}
