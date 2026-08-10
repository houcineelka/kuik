import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../core/storage/local_database.dart';
import '../models/listing.dart';

/// Degraded offline fallback: the last search results the user actually
/// saw, not a general-purpose sync cache.
class ListingsLocalCache {
  Future<void> upsertAll(List<Listing> listings) async {
    final db = await LocalDatabase.instance.database;
    final now = listings.isEmpty ? null : DateTime.now().toIso8601String();
    final batch = db.batch();
    for (final listing in listings) {
      batch.insert(
        'cached_listings',
        {'id': listing.id, 'json': jsonEncode(listing.toJson()), 'cached_at': now},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Listing>> recent({int limit = 30}) async {
    final db = await LocalDatabase.instance.database;
    final rows = await db.query('cached_listings', orderBy: 'cached_at DESC', limit: limit);
    return rows.map((row) => Listing.fromJson(jsonDecode(row['json'] as String) as Map<String, dynamic>)).toList();
  }
}
