import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import '../../../../core/utils/app_logger.dart';
import '../../../../core/models/review_models.dart';
import 'service_detail_card.dart';

class ReviewListCard extends StatelessWidget {
  final List<Review> reviews;
  final String currentSort;
  final Map<String, bool> filters;
  final Function(String) onSortChanged;
  final Function(String, bool) onFilterChanged;
  final VoidCallback? onWriteReview;
  final bool isLoading;

  const ReviewListCard({
    super.key,
    required this.reviews,
    required this.currentSort,
    required this.filters,
    required this.onSortChanged,
    required this.onFilterChanged,
    this.onWriteReview,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ServiceDetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildFiltersAndSort(),
          const SizedBox(height: 16),
          _buildReviewStats(),
          const SizedBox(height: 16),
          _buildReviewList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Text(
          'Customer Reviews',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (onWriteReview != null)
          ElevatedButton.icon(
            onPressed: onWriteReview,
            icon: const Icon(Icons.edit),
            label: const Text('Write Review'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
      ],
    );
  }

  Widget _buildFiltersAndSort() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Sort by: ',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: currentSort,
              items: [
                DropdownMenuItem(value: 'newest', child: Text('Newest')),
                DropdownMenuItem(value: 'oldest', child: Text('Oldest')),
                DropdownMenuItem(
                    value: 'highest', child: Text('Highest Rating')),
                DropdownMenuItem(value: 'lowest', child: Text('Lowest Rating')),
                DropdownMenuItem(
                    value: 'most_helpful', child: Text('Most Helpful')),
              ],
              onChanged: (value) {
                if (value != null) onSortChanged(value);
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: filters.entries.map((entry) {
            return FilterChip(
              label: Text(_getFilterLabel(entry.key)),
              selected: entry.value,
              onSelected: (selected) => onFilterChanged(entry.key, selected),
              selectedColor: Colors.blue.withValues(alpha: 0.2),
              checkmarkColor: Colors.blue,
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getFilterLabel(String key) {
    switch (key) {
      case 'all':
        return 'All';
      case '5star':
        return '5 Stars';
      case '4star':
        return '4 Stars';
      case '3star':
        return '3 Stars';
      case '2star':
        return '2 Stars';
      case '1star':
        return '1 Star';
      case 'withPhotos':
        return 'With Photos';
      case 'verified':
        return 'Verified';
      default:
        return key;
    }
  }

  Widget _buildReviewStats() {
    if (reviews.isEmpty) return const SizedBox.shrink();

    final totalReviews = reviews.length;
    final averageRating =
        reviews.fold(0.0, (sum, review) => sum + review.overallRating) / totalReviews;
    final ratingDistribution = _calculateRatingDistribution();

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const Text(
                'Average Rating',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                '($totalReviews reviews)',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            children: ratingDistribution.entries.map((entry) {
              final rating = entry.key;
              final count = entry.value;
              final percentage =
                  totalReviews > 0 ? (count / totalReviews * 100).round() : 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      child: Text(
                        '$rating',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const Icon(Icons.star, size: 12, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: totalReviews > 0 ? count / totalReviews : 0,
                        backgroundColor: Colors.grey[300],
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.orange),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 30,
                      child: Text(
                        '$count',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Map<int, int> _calculateRatingDistribution() {
    final distribution = <int, int>{};
    for (int i = 1; i <= 5; i++) {
      distribution[i] = 0;
    }

    for (final review in reviews) {
      final rating = review.rating.round();
      if (rating >= 1 && rating <= 5) {
        distribution[rating] = (distribution[rating] ?? 0) + 1;
      }
    }

    return distribution;
  }

  Widget _buildReviewList() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (reviews.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.rate_review, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'No reviews yet',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 4),
              Text(
                'Be the first to review this service!',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: reviews.map((review) => _buildReviewItem(review)).toList(),
    );
  }

  Widget _buildReviewItem(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage:
                    review.userAvatar != null && review.userAvatar!.isNotEmpty
                        ? NetworkImage(review.userAvatar!)
                        : null,
                child: review.userAvatar == null || review.userAvatar!.isEmpty
                    ? Text(
                        review.userName?.isNotEmpty == true
                            ? review.userName![0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName ?? 'Anonymous User',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review.rating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.orange,
                            size: 16,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          review.createdAt.toString().split(' ')[0],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (review.isVerified)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Verified',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: const TextStyle(fontSize: 14),
          ),
          if (review.images != null && review.images!.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: review.images!.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        review.images![index],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image,
                                color: Colors.grey),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
