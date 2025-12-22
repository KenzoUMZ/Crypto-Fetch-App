import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/core.dart';
import '../models/agg_trade_model.dart';

class MarketStreamViewModel extends ChangeNotifier {
  final BinanceWsClient _client;

  AggTrade? _lastAggTrade;
  bool _connected = false;
  String? _error;
  StreamSubscription? _sub;

  MarketStreamViewModel({BinanceWsClient? client})
    : _client = client ?? BinanceWsClient();

  AggTrade? get lastAggTrade => _lastAggTrade;
  bool get connected => _connected;
  String? get error => _error;

  Future<void> connectAndSubscribe() async {
    try {
      await _client.connect();
      _connected = true;
      notifyListeners();

      _client.subscribe(const ['btcusdt@aggTrade', 'btcusdt@depth']);

      _sub = _client.events.listen(
        (event) {
          final type = event['e'] as String?;
          if (type == 'aggTrade') {
            _lastAggTrade = AggTrade.fromJson(event);
            notifyListeners();
          }
        },
        onError: (err) {
          _error = '$err';
          notifyListeners();
        },
      );
    } catch (e) {
      _error = '$e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _client.close();
    super.dispose();
  }
}
