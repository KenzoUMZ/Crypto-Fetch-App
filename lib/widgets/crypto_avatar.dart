import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CryptoAvatar extends StatelessWidget {
  final String? iconUrl;
  final String? leading;
  final ThemeData theme;

  const CryptoAvatar({
    super.key,
    required this.iconUrl,
    required this.leading,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (iconUrl == null || iconUrl!.isEmpty) {
      return CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        radius: 20,
        child: Text(
          leading ?? '?',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      );
    }

    return SizedBox(
      width: 40,
      height: 40,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: iconUrl!,
          fit: BoxFit.cover,
          placeholder:
              (context, url) => CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                radius: 20,
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
          errorWidget:
              (context, url, error) => CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                radius: 20,
                child: Text(
                  leading ?? '?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
        ),
      ),
    );
  }
}
