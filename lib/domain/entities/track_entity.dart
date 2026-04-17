class TrackEntity {
  final int? id;
  final DateTime startTime;
  final DateTime? endTime;
  final double? distance;

  TrackEntity({
    this.id,
    required this.startTime,
    this.endTime,
    this.distance,
  });
}
