import 'package:get/get.dart';
import '../../../domain/entities/service.dart';
import '../../../domain/entities/service_detail.dart';
import '../../../domain/entities/review.dart';

/// 服务详情页面状态模型
class ServiceDetailState {
  // 服务数据
  final Rx<Service?> service = Rx<Service?>(null);
  final Rx<ServiceDetail?> serviceDetail = Rx<ServiceDetail?>(null);
  
  // 加载状态
  final RxBool isLoading = false.obs;
  final RxBool isLoadingReviews = false.obs;
  final RxBool isLoadingProvider = false.obs;
  
  // 错误状态
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;
  
  // 用户交互状态
  final RxBool isFavorite = false.obs;
  final RxString quoteRequestStatus = ''.obs;
  final RxBool isBooking = false.obs;
  
  // 评价相关
  final RxList<Review> reviews = <Review>[].obs;
  final RxString currentReviewSort = 'newest'.obs;
  final RxMap<String, bool> reviewFilters = <String, bool>{
    'all': true,
    '5star': false,
    '4star': false,
    '3star': false,
    '2star': false,
    '1star': false,
    'withPhotos': false,
    'verified': false,
  }.obs;
  
  // 预订详情
  final RxMap<String, dynamic> bookingDetails = <String, dynamic>{}.obs;
  
  // 重置状态
  void reset() {
    service.value = null;
    serviceDetail.value = null;
    isLoading.value = false;
    isLoadingReviews.value = false;
    isLoadingProvider.value = false;
    errorMessage.value = '';
    hasError.value = false;
    isFavorite.value = false;
    quoteRequestStatus.value = '';
    isBooking.value = false;
    reviews.clear();
    currentReviewSort.value = 'newest';
    reviewFilters.clear();
    bookingDetails.clear();
  }
}
