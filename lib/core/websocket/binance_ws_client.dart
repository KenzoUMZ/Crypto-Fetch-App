import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class BinanceWsClient {
  final String endpoint;
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  final StreamController<Map<String, dynamic>> _eventsController =
      StreamController<Map<String, dynamic>>.broadcast();

  BinanceWsClient({this.endpoint = 'wss://stream.binance.com:9443/ws'});

  Stream<Map<String, dynamic>> get events => _eventsController.stream;

  Future<void> connect() async {
    _channel = WebSocketChannel.connect(Uri.parse(endpoint));
    _subscription = _channel!.stream.listen(
      (message) {
        try {
          final data = json.decode(message as String) as Map<String, dynamic>;
          _eventsController.add(data);
        } catch (_) {}
      },
      onError: (err) {
        // ignore
      },
      onDone: () {},
      cancelOnError: true,
    );
  }

  void subscribe(List<String> params, {int id = 1}) {
    final payload = {'method': 'SUBSCRIBE', 'params': params, 'id': id};
    _channel?.sink.add(json.encode(payload));
  }

  void unsubscribe(List<String> params, {int id = 1}) {
    final payload = {'method': 'UNSUBSCRIBE', 'params': params, 'id': id};
    _channel?.sink.add(json.encode(payload));
  }

  Future<void> close() async {
    await _subscription?.cancel();
    await _channel?.sink.close();
    await _eventsController.close();
  }
}
