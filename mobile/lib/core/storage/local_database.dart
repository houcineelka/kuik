import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Local SQLite cache. `cached_listings` holds a degraded offline copy of
/// the last-viewed search results (Part 7) — never the source of truth.
/// `bookmarked_listings` holds device-local saved listings — there is no
/// backend favorites endpoint, so bookmarks never sync across devices.
class LocalDatabase {
  LocalDatabase._();

  static final LocalDatabase instance = LocalDatabase._();

  Database? _database;

  Future<Database> get database async => _database ??= await _open();

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'kuik_local.db');
    return openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE IF NOT EXISTS _meta (key TEXT PRIMARY KEY, value TEXT)');
        await _createCachedListingsTable(db);
        await _createBookmarkedListingsTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createCachedListingsTable(db);
        }
        if (oldVersion < 3) {
          await _createBookmarkedListingsTable(db);
        }
      },
    );
  }

  Future<void> _createCachedListingsTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cached_listings (
        id INTEGER PRIMARY KEY,
        json TEXT NOT NULL,
        cached_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createBookmarkedListingsTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bookmarked_listings (
        id INTEGER PRIMARY KEY,
        bookmarked_at TEXT NOT NULL
      )
    ''');
  }
}
