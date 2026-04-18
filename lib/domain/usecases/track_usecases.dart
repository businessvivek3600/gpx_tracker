import '../entities/track_entity.dart';
import '../entities/track_point_entity.dart';
import '../repositories/track_repository.dart';

class TrackUsecases {
  final TrackRepository repository;

  TrackUsecases(this.repository);

  Future<TrackEntity> startTrack() => repository.startNewTrack();
  
  Future<void> stopTrack(int trackId) => repository.endTrack(trackId);
  
  Future<List<TrackEntity>> fetchAllTracks() => repository.getAllTracks();
  
  Future<TrackPointEntity> recordPoint(int trackId, double lat, double lon, DateTime time) {
    return repository.addTrackPoint(trackId, lat, lon, time);
  }

  Future<List<TrackPointEntity>> fetchTrackPoints(int trackId) {
    return repository.getTrackPoints(trackId);
  }

  Future<void> deleteTrack(int trackId) {
    return repository.deleteTrack(trackId);
  }
}
