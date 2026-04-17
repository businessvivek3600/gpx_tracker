import '../entities/track_entity.dart';
import '../entities/track_point_entity.dart';

abstract class TrackRepository {
  Future<TrackEntity> startNewTrack();
  Future<void> endTrack(int trackId);
  Future<List<TrackEntity>> getAllTracks();
  Future<TrackPointEntity> addTrackPoint(int trackId, double latitude, double longitude, DateTime timestamp);
  Future<List<TrackPointEntity>> getTrackPoints(int trackId);
}
