import '../../domain/entities/track_entity.dart';

class TrackModel extends TrackEntity {
  TrackModel({
    super.id,
    required super.startTime,
    super.endTime,
    super.distance,
  });

  factory TrackModel.fromMap(Map<String, dynamic> map) {
    return TrackModel(
      id: map['id'] as int?,
      startTime: DateTime.fromMillisecondsSinceEpoch(map['start_time'] as int),
      endTime: map['end_time'] != null ? DateTime.fromMillisecondsSinceEpoch(map['end_time'] as int) : null,
      distance: map['distance'] as double?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start_time': startTime.millisecondsSinceEpoch,
      'end_time': endTime?.millisecondsSinceEpoch,
      'distance': distance,
    };
  }
  
  TrackModel copyWith({
    int? id,
    DateTime? startTime,
    DateTime? endTime,
    double? distance,
  }) {
    return TrackModel(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      distance: distance ?? this.distance,
    );
  }
}
