// 筛选面板组件
// 支持按评分、标签、排序方式等筛选点评

import 'package:flutter/material.dart';
import '../../../../../core/models/review_models.dart';

class ReviewFilterPanel extends StatefulWidget {
  final ReviewFilterOptions filterOptions;
  final Function(ReviewFilterOptions) onApply;

  const ReviewFilterPanel({
    super.key,
    required this.filterOptions,
    required this.onApply,
  });

  @override
  State<ReviewFilterPanel> createState() => _ReviewFilterPanelState();
}

class _ReviewFilterPanelState extends State<ReviewFilterPanel> {
  late ReviewFilterOptions _currentOptions;
  final List<String> _availableTags = [
    'Professional', 'On Time', 'Good Communication', 'Good Value',
    'Clean Work', 'Friendly', 'Responsive', 'Reasonable Price'
  ];

  @override
  void initState() {
    super.initState();
    _currentOptions = widget.filterOptions;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                const Text(
                  'Filter Reviews',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentOptions = ReviewFilterOptions();
                    });
                  },
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    widget.onApply(_currentOptions);
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),
          ),
          
          // 筛选内容
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 评分筛选
                  _buildRatingFilter(),
                  const SizedBox(height: 24),
                  
                  // 排序方式
                  _buildSortFilter(),
                  const SizedBox(height: 24),
                  
                  // 标签筛选
                  _buildTagFilter(),
                  const SizedBox(height: 24),
                  
                  // 其他选项
                  _buildOtherOptions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rating',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Minimum Rating'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<double>(
                    value: _currentOptions.minRating,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Any')),
                      const DropdownMenuItem(value: 1.0, child: Text('1+ Stars')),
                      const DropdownMenuItem(value: 2.0, child: Text('2+ Stars')),
                      const DropdownMenuItem(value: 3.0, child: Text('3+ Stars')),
                      const DropdownMenuItem(value: 4.0, child: Text('4+ Stars')),
                      const DropdownMenuItem(value: 5.0, child: Text('5 Stars')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _currentOptions = _currentOptions.copyWith(minRating: value);
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Maximum Rating'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<double>(
                    value: _currentOptions.maxRating,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Any')),
                      const DropdownMenuItem(value: 1.0, child: Text('1 Star')),
                      const DropdownMenuItem(value: 2.0, child: Text('2 Stars')),
                      const DropdownMenuItem(value: 3.0, child: Text('3 Stars')),
                      const DropdownMenuItem(value: 4.0, child: Text('4 Stars')),
                      const DropdownMenuItem(value: 5.0, child: Text('5 Stars')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _currentOptions = _currentOptions.copyWith(maxRating: value);
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSortFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sort By',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _currentOptions.sortBy,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: const [
            DropdownMenuItem(value: 'newest', child: Text('Newest First')),
            DropdownMenuItem(value: 'oldest', child: Text('Oldest First')),
            DropdownMenuItem(value: 'rating', child: Text('Highest Rating')),
            DropdownMenuItem(value: 'helpful', child: Text('Most Helpful')),
          ],
          onChanged: (value) {
            setState(() {
              _currentOptions = _currentOptions.copyWith(sortBy: value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildTagFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableTags.map((tag) {
            final isSelected = _currentOptions.tags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final newTags = List<String>.from(_currentOptions.tags);
                  if (selected) {
                    newTags.add(tag);
                  } else {
                    newTags.remove(tag);
                  }
                  _currentOptions = _currentOptions.copyWith(tags: newTags);
                });
              },
              selectedColor: Colors.blue[100],
              checkmarkColor: Colors.blue[700],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOtherOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Other Options',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          title: const Text('Has Images'),
          value: _currentOptions.hasImages,
          onChanged: (value) {
            setState(() {
              _currentOptions = _currentOptions.copyWith(hasImages: value);
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: const Text('Has Replies'),
          value: _currentOptions.hasReplies,
          onChanged: (value) {
            setState(() {
              _currentOptions = _currentOptions.copyWith(hasReplies: value);
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
} 