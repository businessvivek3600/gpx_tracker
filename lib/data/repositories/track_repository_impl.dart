import '../../domain/entities/track_entity.dart';
import '../../domain/entities/track_point_entity.dart';
import '../../domain/repositories/track_repository.dart';
import '../datasources/local_database.dart';
import '../models/track_model.dart';
import '../models/track_point_model.dart';

class TrackRepositoryImpl implements TrackRepository {
  final LocalDatabase localDatabase;

  TrackRepositoryImpl(this.localDatabase);

  @override
  Future<TrackEntity> startNewTrack() async {
    final track = TrackModel(startTime: DateTime.now());
    return await localDatabase.createTrack(track);
  }

  @override
  Future<void> endTrack(int trackId) async {
    final tracks = await localDatabase.getAllTracks();
    final model = tracks.firstWhere((t) => t.id == trackId);
    
    final updated = model.copyWith(endTime: DateTime.now());
    await localDatabase.updateTrack(updated);
  }

  @override
  Future<List<TrackEntity>> getAllTracks() async {
    return await localDatabase.getAllTracks();
  }

  @override
  Future<TrackPointEntity> addTrackPoint(int trackId, double latitude, double longitude, DateTime timestamp) async {
    final point = TrackPointModel(
      trackId: trackId,
      latitude: latitude,
      longitude: longitude,
      timestamp: timestamp,
    );
    return await localDatabase.insertTrackPoint(point);
  }

  @override
  Future<List<TrackPointEntity>> getTrackPoints(int trackId) async {
    return await localDatabase.getTrackPoints(trackId);
  }

  @override
  Future<void> deleteTrack(int trackId) async {
    await localDatabase.deleteTrack(trackId);
  }
}
