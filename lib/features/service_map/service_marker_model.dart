import 'package:google_maps_flutter/google_maps_flutter.dart';

class ServiceMarkerModel {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String category;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final Map<String, dynamic>? titleMap;
  final Map<String, dynamic>? descriptionMap;
  final double? distanceInKm;

  ServiceMarkerModel({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    this.titleMap,
    this.descriptionMap,
    this.distanceInKm,
  });

  LatLng get location => LatLng(latitude, longitude);
} 