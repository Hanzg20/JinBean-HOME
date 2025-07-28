// 评分选择器组件
// 支持星级评分选择，可自定义大小和交互

import 'package:flutter/material.dart';

class RatingSelector extends StatelessWidget {
  final double rating;
  final Function(double) onRatingChanged;
  final double size;
  final bool allowHalfRating;
  final Color? activeColor;
  final Color? inactiveColor;

  const RatingSelector({
    Key? key,
    required this.rating,
    required this.onRatingChanged,
    this.size = 24.0,
    this.allowHalfRating = true,
    this.activeColor,
    this.inactiveColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1.0;
        final isActive = rating >= starValue;
        final isHalfActive = allowHalfRating && 
            rating >= (starValue - 0.5) && 
            rating < starValue;

        return GestureDetector(
          onTap: () => onRatingChanged(starValue),
          onTapDown: allowHalfRating ? (details) {
            final box = context.findRenderObject() as RenderBox;
            final localPosition = details.localPosition;
            final halfWidth = box.size.width / 2;
            
            if (localPosition.dx < halfWidth) {
              onRatingChanged(starValue - 0.5);
            } else {
              onRatingChanged(starValue);
            }
          } : null,
          child: Container(
            padding: const EdgeInsets.all(2),
            child: Icon(
              isActive 
                  ? Icons.star 
                  : isHalfActive 
                      ? Icons.star_half 
                      : Icons.star_border,
              size: size,
              color: isActive || isHalfActive
                  ? (activeColor ?? Colors.amber)
                  : (inactiveColor ?? Colors.grey[400]),
            ),
          ),
        );
      }),
    );
  }
} 