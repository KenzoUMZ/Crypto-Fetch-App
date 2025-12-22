import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class CoinCapPricesWsClient {
  final List<String> assets;
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  final StreamController<Map<String, double>> _pricesController =
      StreamController<Map<String, double>>.broadcast();

  CoinCapPricesWsClient(this.assets);

  Stream<Map<String, double>> get prices => _pricesController.stream;

  Future<void> connect() async {
    if (assets.isEmpty) return;
    final ids = assets.join(',');
    final url = 'wss://ws.coincap.io/prices?assets=$ids';
    _channel = WebSocketChannel.connect(Uri.parse(url));
    _subscription = _channel!.stream.listen(
      (message) {
        try {
          final map = json.decode(message as String) as Map<String, dynamic>;
          final parsed = <String, double>{};
          map.forEach((key, value) {
            final v = double.tryParse((value as String?) ?? '') ?? 0.0;
            parsed[key] = v;
          });
          _pricesController.add(parsed);
        } catch (_) {}
      },
      onError: (err) {
        // ignore errors
      },
      onDone: () {},
      cancelOnError: true,
    );
  }

  Future<void> close() async {
    await _subscription?.cancel();
    await _channel?.sink.close();
    await _pricesController.close();
  }
}
