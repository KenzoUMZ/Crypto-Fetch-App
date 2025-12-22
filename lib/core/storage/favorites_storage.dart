import 'package:shared_preferences/shared_preferences.dart';

class FavoritesStorage {
  static const String _key = 'favorite_asset_ids';

  Future<Set<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? const [];
    return list.toSet();
  }

  Future<void> saveFavorites(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, ids.toList());
  }

  Future<Set<String>> toggleFavorite(String id) async {
    final current = await loadFavorites();
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
    await saveFavorites(current);
    return current;
  }

  Future<bool> isFavorite(String id) async {
    final current = await loadFavorites();
    return current.contains(id);
  }
}
