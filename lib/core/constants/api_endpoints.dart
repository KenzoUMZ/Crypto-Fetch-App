class ApiEndpoints {
  static const String baseUrl = 'https://rest.coincap.io/v3';

  // [IconsCDN]
  static const String iconsCdnUrl = 'https://assets.coincap.io/assets/icons';
  static String assetIcon(String symbol) =>
      '$iconsCdnUrl/${symbol.toLowerCase()}@2x.png';

  // [Assets]
  static const String assets = '/assets';
  static String assetById(String id) => '/assets/$id';

  ApiEndpoints._();
}
