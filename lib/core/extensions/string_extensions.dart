import 'package:localization/localization.dart';

extension StringExtensions on String {
  String translate([List<String> args = const []]) => i18n(args);

  String normalizeForIconUrl() {
    return toLowerCase()
        .replaceAll('usdt', '')
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(RegExp(r'[^\w-]'), '')
        .replaceAll(RegExp(r'-+$'), '')
        .replaceAll(RegExp(r'^-+'), '');
  }
}
