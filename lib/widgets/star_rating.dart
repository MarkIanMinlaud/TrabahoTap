import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final int count;
  final double size;
  final bool showValue;
  final bool showCount;
  final String countSuffix;
  final String emptyLabel;

  const StarRating({
    super.key,
    required this.rating,
    this.count = 0,
    this.size = 16,
    this.showValue = true,
    this.showCount = true,
    this.countSuffix = '',
    this.emptyLabel = 'No ratings yet',
  });

  IconData _iconFor(int index) {
    if (rating >= index + 1) return Icons.star;
    if (rating >= index + 0.5) return Icons.star_half;
    return Icons.star_border;
  }

  Color _colorFor(int index) {
    if (rating >= index + 0.5) return AppColors.primary;
    return AppColors.textSecondary;
  }

  String get _label {
    if (!showValue && !showCount) return '';
    final hasRating = rating > 0;
    if (!hasRating) return emptyLabel;
    if (showValue && showCount) {
      return '${rating.toStringAsFixed(1)} ($count$countSuffix)';
    }
    if (showValue) return rating.toStringAsFixed(1);
    return '$count$countSuffix';
  }

  @override
  Widget build(BuildContext context) {
    final label = _label;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++)
          Icon(_iconFor(i), color: _colorFor(i), size: size),
        if (label.isNotEmpty) ...[
          SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: size * 0.8,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
