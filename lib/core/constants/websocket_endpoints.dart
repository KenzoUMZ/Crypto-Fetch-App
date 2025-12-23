/// Endpoints dos WebSockets
class WebSocketEndpoints {
  static const String binanceBaseUrl = 'wss://stream.binance.com:9443';
  static const String binanceWs = '$binanceBaseUrl/ws';

  static String binanceStreams(List<String> pairs) {
    if (pairs.isEmpty) return '';
    final streams = pairs.map((p) => '$p@ticker').join('/');
    return '$binanceBaseUrl/stream?streams=$streams';
  }

  static const String coinCapBaseUrl = 'wss://ws.coincap.io';

  static String coinCapPrices(List<String> assets) {
    if (assets.isEmpty) return '';
    final ids = assets.join(',');
    return '$coinCapBaseUrl/prices?assets=$ids';
  }

  WebSocketEndpoints._();
}
