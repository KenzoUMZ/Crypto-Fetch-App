import 'package:localization/localization.dart';

extension StringExtensions on String {
  String translate([List<String> args = const []]) => i18n(args);
}
