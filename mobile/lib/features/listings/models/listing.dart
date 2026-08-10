import 'listing_photo.dart';

class Listing {
  const Listing({
    required this.id,
    required this.userId,
    required this.type,
    required this.category,
    required this.description,
    required this.city,
    required this.eventDate,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.photos,
    required this.createdAt,
    this.neighborhood,
    this.privateDetail,
    this.distanceM,
  });

  final int id;
  final int userId;
  final String type; // 'lost' | 'found'
  final String category;
  final String description;
  final String city;
  final String? neighborhood;
  final DateTime eventDate;
  final String? privateDetail;
  final String status; // 'active' | 'resolved' | 'expired'
  final double latitude;
  final double longitude;
  final double? distanceM;
  final List<ListingPhoto> photos;
  final DateTime createdAt;

  bool get isLost => type == 'lost';
  bool get isActive => status == 'active';

  factory Listing.fromJson(Map<String, dynamic> json) => Listing(
        id: json['id'] as int,
        userId: json['user_id'] as int,
        type: json['type'] as String,
        category: json['category'] as String,
        description: json['description'] as String,
        city: json['city'] as String,
        neighborhood: json['neighborhood'] as String?,
        eventDate: DateTime.parse(json['event_date'] as String),
        privateDetail: json['private_detail'] as String?,
        status: json['status'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        distanceM: json['distance_m'] != null ? (json['distance_m'] as num).toDouble() : null,
        photos: (json['photos'] as List<dynamic>? ?? [])
            .map((p) => ListingPhoto.fromJson(p as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  /// Round-trips through the same shape as [fromJson] — used for the
  /// offline sqflite cache, not sent back to the API.
  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'type': type,
        'category': category,
        'description': description,
        'city': city,
        'neighborhood': neighborhood,
        'event_date': eventDate.toIso8601String(),
        'private_detail': privateDetail,
        'status': status,
        'latitude': latitude,
        'longitude': longitude,
        'distance_m': distanceM,
        'photos': photos.map((p) => p.toJson()).toList(),
        'created_at': createdAt.toIso8601String(),
      };
}
