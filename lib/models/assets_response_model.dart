import 'asset_model.dart';

class AssetsResponse {
  final int timestamp;
  final List<Asset> data;

  const AssetsResponse({required this.timestamp, required this.data});

  factory AssetsResponse.fromJson(Map<String, dynamic> json) {
    return AssetsResponse(
      timestamp: json['timestamp'] as int,
      data:
          (json['data'] as List<dynamic>)
              .map((e) => Asset.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp);
}
