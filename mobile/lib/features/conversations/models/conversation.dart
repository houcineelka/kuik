import '../../../core/models/user.dart';
import '../../listings/models/listing.dart';

class Conversation {
  const Conversation({
    required this.id,
    required this.listing,
    required this.userOne,
    required this.userTwo,
    required this.createdAt,
    required this.unreadCount,
  });

  final int id;
  final Listing listing;
  final User userOne;
  final User userTwo;
  final DateTime createdAt;
  final int unreadCount;

  User otherParticipant(int currentUserId) => userOne.id == currentUserId ? userTwo : userOne;

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        id: json['id'] as int,
        listing: Listing.fromJson(json['listing'] as Map<String, dynamic>),
        userOne: User.fromJson(json['user_one'] as Map<String, dynamic>),
        userTwo: User.fromJson(json['user_two'] as Map<String, dynamic>),
        createdAt: DateTime.parse(json['created_at'] as String),
        unreadCount: json['unread_count'] as int? ?? 0,
      );
}
