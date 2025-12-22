extension DoubleExtensions on double {
  String formatPrice() {
    if (this >= 1000) {
      return toStringAsFixed(2);
    } else if (this >= 1) {
      return toStringAsFixed(4);
    } else {
      return toStringAsFixed(6);
    }
  }

  String formatVolume() {
    if (this >= 1e12) {
      return '${(this / 1e12).toStringAsFixed(2)}T';
    } else if (this >= 1e9) {
      return '${(this / 1e9).toStringAsFixed(2)}B';
    } else if (this >= 1e6) {
      return '${(this / 1e6).toStringAsFixed(2)}M';
    } else if (this >= 1e3) {
      return '${(this / 1e3).toStringAsFixed(2)}K';
    } else {
      return toStringAsFixed(2);
    }
  }
}
