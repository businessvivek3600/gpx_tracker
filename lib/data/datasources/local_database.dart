import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/constants/app_constants.dart';
import '../models/track_model.dart';
import '../models/track_point_model.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;

  LocalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableTracks} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        start_time INTEGER NOT NULL,
        end_time INTEGER,
        distance REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableTrackPoints} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        track_id INTEGER NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        timestamp INTEGER NOT NULL,
        FOREIGN KEY (track_id) REFERENCES ${AppConstants.tableTracks} (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<TrackModel> createTrack(TrackModel track) async {
    final db = await instance.database;
    final id = await db.insert(AppConstants.tableTracks, track.toMap());
    return track.copyWith(id: id);
  }
  
  Future<int> updateTrack(TrackModel track) async {
    final db = await instance.database;
    return await db.update(
      AppConstants.tableTracks,
      track.toMap(),
      where: 'id = ?',
      whereArgs: [track.id],
    );
  }

  Future<List<TrackModel>> getAllTracks() async {
    final db = await instance.database;
    final result = await db.query(AppConstants.tableTracks, orderBy: 'start_time DESC');
    return result.map((json) => TrackModel.fromMap(json)).toList();
  }

  Future<TrackPointModel> insertTrackPoint(TrackPointModel point) async {
    final db = await instance.database;
    final id = await db.insert(AppConstants.tableTrackPoints, point.toMap());
    return TrackPointModel(
      id: id,
      trackId: point.trackId,
      latitude: point.latitude,
      longitude: point.longitude,
      timestamp: point.timestamp,
    );
  }

  Future<List<TrackPointModel>> getTrackPoints(int trackId) async {
    final db = await instance.database;
    final result = await db.query(
      AppConstants.tableTrackPoints,
      where: 'track_id = ?',
      whereArgs: [trackId],
      orderBy: 'timestamp ASC',
    );
    return result.map((json) => TrackPointModel.fromMap(json)).toList();
  }
}
