import 'package:flutter/material.dart';

extension SpacingExtension on Widget {
  Widget addPadding(EdgeInsetsGeometry padding) {
    return Padding(padding: padding, child: this);
  }

  Widget addMargin(EdgeInsetsGeometry margin) {
    return Container(margin: margin, child: this);
  }
}
