// 评分统计卡片组件
// 显示服务的评分统计信息，包括平均评分、评分分布等

import 'package:flutter/material.dart';
import '../../../../../core/models/review_models.dart';

class RatingStatsCard extends StatelessWidget {
  final ServiceRatingStats stats;

  const RatingStatsCard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            const Text(
              'Rating Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                // 左侧：平均评分
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            stats.averageRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '/ 5',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      _buildRatingStars(stats.averageRating),
                      const SizedBox(height: 4),
                      Text(
                        stats.getRatingLevel(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${stats.totalReviews} reviews',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 右侧：评分分布
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildRatingBar(5, stats.totalReviews > 0 ? (stats.positiveReviews / stats.totalReviews * 100) : 0),
                      _buildRatingBar(4, stats.totalReviews > 0 ? (stats.positiveReviews / stats.totalReviews * 100) : 0),
                      _buildRatingBar(3, stats.totalReviews > 0 ? (stats.totalReviews - stats.positiveReviews - stats.negativeReviews) / stats.totalReviews * 100 : 0),
                      _buildRatingBar(2, stats.totalReviews > 0 ? (stats.negativeReviews / stats.totalReviews * 100) : 0),
                      _buildRatingBar(1, stats.totalReviews > 0 ? (stats.negativeReviews / stats.totalReviews * 100) : 0),
                    ],
                  ),
                ),
              ],
            ),
            
            // 详细评分维度
            if (_hasDetailedRatings()) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Detailed Ratings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _buildDetailedRatingRow('Quality', stats.avgQualityRating),
              _buildDetailedRatingRow('Punctuality', stats.avgPunctualityRating),
              _buildDetailedRatingRow('Communication', stats.avgCommunicationRating),
              _buildDetailedRatingRow('Value', stats.avgValueRating),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: Colors.amber, size: 20);
        } else if (index == rating.floor() && rating % 1 > 0) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 20);
        } else {
          return Icon(Icons.star_border, color: Colors.grey[400], size: 20);
        }
      }),
    );
  }

  Widget _buildRatingBar(int stars, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              '$stars',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage > 0 ? Colors.amber : Colors.grey[300]!,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 30,
            child: Text(
              '${percentage.toInt()}%',
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedRatingRow(String label, double? rating) {
    if (rating == null) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                _buildDetailedRatingStars(rating),
                const SizedBox(width: 8),
                Text(
                  rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: Colors.amber, size: 16);
        } else if (index == rating.floor() && rating % 1 > 0) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 16);
        } else {
          return Icon(Icons.star_border, color: Colors.grey[400], size: 16);
        }
      }),
    );
  }

  bool _hasDetailedRatings() {
    return stats.avgQualityRating != null ||
           stats.avgPunctualityRating != null ||
           stats.avgCommunicationRating != null ||
           stats.avgValueRating != null;
  }
} 