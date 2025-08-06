/// 服务详情页面事件模型
abstract class ServiceDetailEvent {
  const ServiceDetailEvent();
}

/// 加载服务详情事件
class LoadServiceDetail extends ServiceDetailEvent {
  final String serviceId;
  const LoadServiceDetail(this.serviceId);
}

/// 切换收藏状态事件
class ToggleFavorite extends ServiceDetailEvent {
  const ToggleFavorite();
}

/// 请求报价事件
class RequestQuote extends ServiceDetailEvent {
  final Map<String, dynamic> quoteDetails;
  const RequestQuote(this.quoteDetails);
}

/// 预订服务事件
class BookService extends ServiceDetailEvent {
  final Map<String, dynamic> bookingDetails;
  const BookService(this.bookingDetails);
}

/// 加载评价事件
class LoadReviews extends ServiceDetailEvent {
  final String serviceId;
  const LoadReviews(this.serviceId);
}

/// 筛选评价事件
class FilterReviews extends ServiceDetailEvent {
  final String filterKey;
  final bool value;
  const FilterReviews(this.filterKey, this.value);
}

/// 排序评价事件
class SortReviews extends ServiceDetailEvent {
  final String sortType;
  const SortReviews(this.sortType);
}

/// 联系提供商事件
class ContactProvider extends ServiceDetailEvent {
  final String contactType;
  const ContactProvider(this.contactType);
}
