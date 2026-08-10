import '../../../core/models/user.dart';
import '../../listings/models/listing.dart';

class ListingClaim {
  const ListingClaim({
    required this.id,
    required this.listing,
    required this.claimant,
    required this.photoUrl,
    required this.description,
    required this.status,
  });

  final int id;
  final Listing listing;
  final User claimant;
  final String photoUrl;
  final String description;
  final String status; // 'pending' | 'accepted' | 'rejected'

  factory ListingClaim.fromJson(Map<String, dynamic> json) => ListingClaim(
        id: json['id'] as int,
        listing: Listing.fromJson(json['listing'] as Map<String, dynamic>),
        claimant: User.fromJson(json['claimant'] as Map<String, dynamic>),
        photoUrl: json['photo_url'] as String,
        description: json['description'] as String,
        status: json['status'] as String,
      );
}
