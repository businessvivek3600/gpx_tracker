import '../../domain/entities/track_point_entity.dart';

class TrackPointModel extends TrackPointEntity {
  TrackPointModel({
    super.id,
    required super.trackId,
    required super.latitude,
    required super.longitude,
    required super.timestamp,
  });

  factory TrackPointModel.fromMap(Map<String, dynamic> map) {
    return TrackPointModel(
      id: map['id'] as int?,
      trackId: map['track_id'] as int,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'track_id': trackId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}
