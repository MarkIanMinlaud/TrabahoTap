import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

class StarInput extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final double size;

  const StarInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final filled = i < value;
        return InkResponse(
          onTap: () => onChanged(i + 1),
          radius: size * 0.7,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Icon(
              filled ? Icons.star : Icons.star_border,
              color: filled ? AppColors.primary : AppColors.textSecondary,
              size: size,
            ),
          ),
        );
      }),
    );
  }
}
