import '../../listings/models/listing.dart';

class ListingMatch {
  const ListingMatch({
    required this.id,
    required this.score,
    required this.status,
    required this.lostListing,
    required this.foundListing,
  });

  final int id;
  final double score;
  final String status; // 'suggested' | 'confirmed' | 'rejected'
  final Listing lostListing;
  final Listing foundListing;

  factory ListingMatch.fromJson(Map<String, dynamic> json) => ListingMatch(
        id: json['id'] as int,
        score: (json['score'] as num).toDouble(),
        status: json['status'] as String,
        lostListing: Listing.fromJson(json['lost_listing'] as Map<String, dynamic>),
        foundListing: Listing.fromJson(json['found_listing'] as Map<String, dynamic>),
      );
}
