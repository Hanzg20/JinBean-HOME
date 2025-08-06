/// 服务详情实体类
class ServiceDetail {
  final String id;
  final String serviceId;
  final String? pricingType;
  final double? price;
  final String? currency;
  final String? negotiationDetails;
  final String? durationType;
  final int? duration;
  final List<String>? images;
  final List<String>? tags;
  final List<String>? serviceAreaCodes;
  final Map<String, dynamic>? serviceDetailsJson;
  final Map<String, dynamic>? details;

  ServiceDetail({
    required this.id,
    required this.serviceId,
    this.pricingType,
    this.price,
    this.currency,
    this.negotiationDetails,
    this.durationType,
    this.duration,
    this.images,
    this.tags,
    this.serviceAreaCodes,
    this.serviceDetailsJson,
    this.details,
  });

  factory ServiceDetail.fromJson(Map<String, dynamic> json) {
    return ServiceDetail(
      id: json['id'] ?? '',
      serviceId: json['serviceId'] ?? '',
      pricingType: json['pricingType'],
      price: json['price']?.toDouble(),
      currency: json['currency'],
      negotiationDetails: json['negotiationDetails'],
      durationType: json['durationType'],
      duration: json['duration'],
      images: json['images'] != null 
          ? List<String>.from(json['images'])
          : null,
      tags: json['tags'] != null 
          ? List<String>.from(json['tags'])
          : null,
      serviceAreaCodes: json['serviceAreaCodes'] != null 
          ? List<String>.from(json['serviceAreaCodes'])
          : null,
      serviceDetailsJson: json['serviceDetailsJson'],
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'pricingType': pricingType,
      'price': price,
      'currency': currency,
      'negotiationDetails': negotiationDetails,
      'durationType': durationType,
      'duration': duration,
      'images': images,
      'tags': tags,
      'serviceAreaCodes': serviceAreaCodes,
      'serviceDetailsJson': serviceDetailsJson,
      'details': details,
    };
  }
} 