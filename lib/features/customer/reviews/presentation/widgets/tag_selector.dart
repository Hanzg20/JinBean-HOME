// 标签选择器组件
// 支持多选标签，可自定义样式和交互

import 'package:flutter/material.dart';

class TagSelector extends StatelessWidget {
  final List<String> availableTags;
  final List<String> selectedTags;
  final Function(String) onTagToggled;
  final int maxSelection;
  final Color? selectedColor;
  final Color? unselectedColor;
  final double borderRadius;

  const TagSelector({
    super.key,
    required this.availableTags,
    required this.selectedTags,
    required this.onTagToggled,
    this.maxSelection = 5,
    this.selectedColor,
    this.unselectedColor,
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableTags.map((tag) {
        final isSelected = selectedTags.contains(tag);
        final canSelect = isSelected || selectedTags.length < maxSelection;

        return GestureDetector(
          onTap: canSelect ? () => onTagToggled(tag) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? (selectedColor ?? Colors.blue[100])
                  : (unselectedColor ?? Colors.grey[100]),
              border: Border.all(
                color: isSelected
                    ? (selectedColor ?? Colors.blue[600]!)
                    : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  Icon(
                    Icons.check,
                    size: 16,
                    color: selectedColor ?? Colors.blue[600],
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  tag,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? (selectedColor ?? Colors.blue[700])
                        : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
} 