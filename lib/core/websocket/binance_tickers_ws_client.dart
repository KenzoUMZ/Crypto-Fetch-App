import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../constants/websocket_endpoints.dart';

class BinanceTicker {
  final String stream;
  final String symbol;
  final double lastPrice;
  final double priceChange;
  final double priceChangePercent;
  final double volume;

  BinanceTicker({
    required this.stream,
    required this.symbol,
    required this.lastPrice,
    required this.priceChange,
    required this.priceChangePercent,
    required this.volume,
  });
}

class BinanceTickersWsClient {
  final List<String> pairs;
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  final StreamController<BinanceTicker> _controller =
      StreamController<BinanceTicker>.broadcast();

  BinanceTickersWsClient(this.pairs);

  Stream<BinanceTicker> get tickers => _controller.stream;

  Future<void> connect() async {
    if (pairs.isEmpty) return;
    final url = WebSocketEndpoints.binanceStreams(pairs);
    _channel = WebSocketChannel.connect(Uri.parse(url));
    _subscription = _channel!.stream.listen(
      (message) {
        try {
          final map = json.decode(message as String) as Map<String, dynamic>;
          final stream = map['stream'] as String? ?? '';
          final data = (map['data'] as Map<String, dynamic>?);
          if (data == null) return;
          final symbol = data['s'] as String? ?? '';
          final last = double.tryParse((data['c'] as String?) ?? '') ?? 0.0;
          final change = double.tryParse((data['p'] as String?) ?? '') ?? 0.0;
          final percent = double.tryParse((data['P'] as String?) ?? '') ?? 0.0;
          final volume = double.tryParse((data['v'] as String?) ?? '') ?? 0.0;
          _controller.add(
            BinanceTicker(
              stream: stream,
              symbol: symbol,
              lastPrice: last,
              priceChange: change,
              priceChangePercent: percent,
              volume: volume,
            ),
          );
        } catch (_) {}
      },
      onError: (err) {},
      onDone: () {},
      cancelOnError: true,
    );
  }

  Future<void> close() async {
    await _subscription?.cancel();
    await _channel?.sink.close();
    await _controller.close();
  }
}
