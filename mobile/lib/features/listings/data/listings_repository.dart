import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../models/listing.dart';

class ListingsPage {
  const ListingsPage({
    required this.listings,
    required this.currentPage,
    required this.lastPage,
  });

  final List<Listing> listings;
  final int currentPage;
  final int lastPage;

  bool get hasMore => currentPage < lastPage;
}

class ListingSearchFilters {
  const ListingSearchFilters({
    this.type,
    this.category,
    this.city,
    this.keyword,
    this.dateFrom,
    this.dateTo,
    this.lat,
    this.lng,
    this.radiusKm,
  });

  final String? type;
  final String? category;
  final String? city;
  final String? keyword;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final double? lat;
  final double? lng;
  final double? radiusKm;

  Map<String, dynamic> toQuery() {
    final query = <String, dynamic>{};
    if (type != null && type!.isNotEmpty) query['type'] = type;
    if (category != null && category!.isNotEmpty) query['category'] = category;
    if (city != null && city!.isNotEmpty) query['city'] = city;
    if (keyword != null && keyword!.isNotEmpty) query['keyword'] = keyword;
    if (dateFrom != null) query['date_from'] = _formatDate(dateFrom!);
    if (dateTo != null) query['date_to'] = _formatDate(dateTo!);
    if (lat != null) query['lat'] = lat;
    if (lng != null) query['lng'] = lng;
    if (radiusKm != null) query['radius_km'] = radiusKm;
    return query;
  }
}

String _formatDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

class ListingsRepository {
  ListingsRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<Listing> create({
    required String type,
    required String category,
    required String description,
    required String city,
    String? neighborhood,
    required DateTime eventDate,
    required double lat,
    required double lng,
  }) async {
    final json = await _api.post('/listings', data: {
      'type': type,
      'category': category,
      'description': description,
      'city': city,
      if (neighborhood != null && neighborhood.isNotEmpty) 'neighborhood': neighborhood,
      'event_date': _formatDate(eventDate),
      'lat': lat,
      'lng': lng,
    });
    return Listing.fromJson(json);
  }

  Future<Listing> uploadPhotos(int listingId, List<File> photos) async {
    final formData = FormData();
    for (final file in photos) {
      formData.files.add(MapEntry('photos[]', await MultipartFile.fromFile(file.path)));
    }
    final json = await _api.postMultipart('/listings/$listingId/photos', formData);
    return Listing.fromJson(json);
  }

  /// `GET /api/listings` — all listings, newest first. There is no
  /// backend endpoint scoped to the current user, so "my listings" is
  /// built by paging through this and filtering client-side.
  Future<ListingsPage> index({int page = 1}) async {
    final json = await _api.get('/listings', query: {'page': page});
    final data = (json['data'] as List<dynamic>? ?? [])
        .map((item) => Listing.fromJson(item as Map<String, dynamic>))
        .toList();
    return ListingsPage(
      listings: data,
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
    );
  }

  Future<ListingsPage> search(ListingSearchFilters filters, {int page = 1}) async {
    final query = filters.toQuery()..['page'] = page;
    final json = await _api.get('/listings/search', query: query);
    final data = (json['data'] as List<dynamic>? ?? [])
        .map((item) => Listing.fromJson(item as Map<String, dynamic>))
        .toList();
    return ListingsPage(
      listings: data,
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
    );
  }

  Future<Listing> show(int id) async {
    final json = await _api.get('/listings/$id');
    return Listing.fromJson(json);
  }

  Future<Listing> resolve(int id) async {
    final json = await _api.patch('/listings/$id/resolve');
    return Listing.fromJson(json);
  }

  Future<void> delete(int id) => _api.delete('/listings/$id');

  /// Submits photo proof + a short description for the listing owner to
  /// review, instead of opening a conversation immediately — used for both
  /// "I found this" (on a lost listing) and "this is mine" (on a found
  /// listing) claims. Throws [ApiException] (422) if a pending claim
  /// already exists from this user for this listing.
  Future<void> claimFound(int listingId, File photo, String description) async {
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(photo.path),
      'description': description,
    });
    await _api.postMultipart('/listings/$listingId/claim', formData);
  }
}
