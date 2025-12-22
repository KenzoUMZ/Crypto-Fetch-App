import 'package:localization/localization.dart';

extension StringExtensions on String {
  String translate([List<String> args = const []]) => i18n(args);

  /// Normaliza a string para ser usada na URL de ícones do CoinCap
  /// Remove espaços, converte para lowercase, remove USDT e caracteres especiais
  String normalizeForIconUrl() {
    return toLowerCase()
        .replaceAll('usdt', '') // Remove USDT
        .replaceAll(RegExp(r'\s+'), '') // Remove espaços
        .replaceAll(
          RegExp(r'[^\w-]'),
          '',
        ) // Remove caracteres especiais exceto hífen
        .replaceAll(RegExp(r'-+$'), '') // Remove hífens no final
        .replaceAll(RegExp(r'^-+'), ''); // Remove hífens no início
  }
}
