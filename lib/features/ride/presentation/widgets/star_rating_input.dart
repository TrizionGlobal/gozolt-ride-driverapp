import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class StarRatingInput extends StatefulWidget {
  final ValueChanged<int> onRatingChanged;

  const StarRatingInput({super.key, required this.onRatingChanged});

  @override
  State<StarRatingInput> createState() => _StarRatingInputState();
}

class _StarRatingInputState extends State<StarRatingInput> {
  int _currentRating = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        return GestureDetector(
          onTap: () {
            setState(() => _currentRating = starIndex);
            widget.onRatingChanged(starIndex);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(
              starIndex <= _currentRating ? Icons.star : Icons.star_border_rounded,
              color: AppColors.primaryGold,
              size: 36,
            ),
          ),
        );
      }),
    );
  }
}
