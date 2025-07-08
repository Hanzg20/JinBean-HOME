import 'package:get/get.dart';

class Review {
  final String id;
  final String serviceName;
  final double rating;
  final String comment;
  final String date;

  Review({
    required this.id,
    required this.serviceName,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

class MyReviewsController extends GetxController {
  final isLoading = false.obs;
  final reviews = <Review>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadReviews();
  }

  Future<void> loadReviews() async {
    isLoading.value = true;
    try {
      // TODO: Implement actual API call to fetch reviews
      // For now, using mock data
      await Future.delayed(const Duration(seconds: 1));
      reviews.value = [
        Review(
          id: 'r001',
          serviceName: 'House Cleaning',
          rating: 4.5,
          comment: 'Great service, very thorough and professional!',
          date: '2024-03-20',
        ),
        Review(
          id: 'r002',
          serviceName: 'Plumbing Repair',
          rating: 5.0,
          comment: 'Quick response and fixed the leak perfectly.',
          date: '2024-03-22',
        ),
        Review(
          id: 'r003',
          serviceName: 'Electrical Work',
          rating: 3.0,
          comment: 'Service was okay, but a bit slow.',
          date: '2024-03-25',
        ),
      ];
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load reviews',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshReviews() async {
    await loadReviews();
  }
} 