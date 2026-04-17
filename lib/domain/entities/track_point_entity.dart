
class TrackPointEntity {
  final int? id;
  final int trackId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  TrackPointEntity({
    this.id,
    required this.trackId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });
}
