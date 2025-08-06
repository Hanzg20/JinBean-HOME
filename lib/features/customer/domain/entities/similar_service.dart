/// 相似服务实体类
class SimilarService {
  final String id;
  final String title;
  final String description;
  final double? price;
  final String? currency;
  final String? pricingType;
  final String? categoryId;
  final String? providerId;
  final List<String>? images;
  final double? rating;
  final int? reviewCount;
  final double? similarityScore;
  final Map<String, dynamic>? metadata;

  SimilarService({
    required this.id,
    required this.title,
    required this.description,
    this.price,
    this.currency,
    this.pricingType,
    this.categoryId,
    this.providerId,
    this.images,
    this.rating,
    this.reviewCount,
    this.similarityScore,
    this.metadata,
  });

  factory SimilarService.fromJson(Map<String, dynamic> json) {
    return SimilarService(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: json['price']?.toDouble(),
      currency: json['currency'],
      pricingType: json['pricingType'],
      categoryId: json['categoryId'],
      providerId: json['providerId'],
      images: json['images'] != null 
          ? List<String>.from(json['images'])
          : null,
      rating: json['rating']?.toDouble(),
      reviewCount: json['reviewCount'],
      similarityScore: json['similarityScore']?.toDouble(),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'currency': currency,
      'pricingType': pricingType,
      'categoryId': categoryId,
      'providerId': providerId,
      'images': images,
      'rating': rating,
      'reviewCount': reviewCount,
      'similarityScore': similarityScore,
      'metadata': metadata,
    };
  }
} 