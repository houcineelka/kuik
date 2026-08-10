class ListingPhoto {
  const ListingPhoto({required this.id, required this.listingId, required this.photoUrl});

  final int id;
  final int listingId;
  final String photoUrl;

  factory ListingPhoto.fromJson(Map<String, dynamic> json) => ListingPhoto(
        id: json['id'] as int,
        listingId: json['listing_id'] as int,
        photoUrl: json['photo_url'] as String,
      );

  Map<String, dynamic> toJson() => {'id': id, 'listing_id': listingId, 'photo_url': photoUrl};
}
