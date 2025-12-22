import '../core/api/api_client.dart';
import '../core/constants/api_endpoints.dart';
import '../models/asset_model.dart';
import '../models/assets_response_model.dart';

class AssetRepository {
  final ApiClient apiClient;
  const AssetRepository({required this.apiClient});

  Future<AssetsResponse> fetchAssets({
    String? search,
    List<String>? ids,
    int? limit,
    int? offset,
  }) async {
    var path = ApiEndpoints.assets;
    final params = <String>[];

    if (search != null && search.isNotEmpty) params.add('search=$search');
    if (ids != null && ids.isNotEmpty) {
      params.add('ids=${ids.join(',').toLowerCase()}');
    }
    if (limit != null) params.add('limit=$limit');
    if (offset != null) params.add('offset=$offset');

    if (params.isNotEmpty) {
      path = '$path?${params.join('&')}';
    }

    final json = await apiClient.get(path);
    return AssetsResponse.fromJson(json as Map<String, dynamic>);
  }

  Future<Asset> fetchAssetById(String id) async {
    final json = await apiClient.get(ApiEndpoints.assetById(id));
    final data = json['data'] as Map<String, dynamic>;
    return Asset.fromJson(data);
  }
}
