import 'dart:convert';

import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

// Circular profile photo with a yellow initials fallback.
class UserAvatar extends StatelessWidget {
  final String name;
  final String? photoBase64;
  final double size;

  const UserAvatar({
    super.key,
    required this.name,
    this.photoBase64,
    this.size = 48,
  });

  String _initials() {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Widget _initialCircle() {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Text(
        _initials(),
        style: TextStyle(
          fontSize: size * 0.36,
          fontWeight: FontWeight.bold,
          color: AppColors.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (photoBase64 == null || photoBase64!.isEmpty) {
      return _initialCircle();
    }

    try {
      final bytes = base64Decode(photoBase64!);
      return ClipOval(
        child: Image.memory(
          bytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
          // Bad image data should never crash the screen.
          errorBuilder: (_, _, _) => _initialCircle(),
        ),
      );
    } catch (_) {
      return _initialCircle();
    }
  }
}

// Small green badge shown when a user has uploaded a photo.
class PhotoVerifiedBadge extends StatelessWidget {
  const PhotoVerifiedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.successSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'Photo ✓',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.success,
        ),
      ),
    );
  }
}
