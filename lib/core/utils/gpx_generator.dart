import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/track_entity.dart';
import '../../domain/entities/track_point_entity.dart';

class GpxGenerator {
  static Future<File> generateGpxFile(TrackEntity track, List<TrackPointEntity> points) async {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<gpx version="1.1" creator="GPX Tracker Pro" xmlns="http://www.topografix.com/GPX/1/1">');
    
    buffer.writeln('  <trk>');
    buffer.writeln('    <name>Track ${track.id}</name>');
    buffer.writeln('    <trkseg>');
    
    for (var point in points) {
      final isoTime = point.timestamp.toUtc().toIso8601String();
      buffer.writeln('      <trkpt lat="${point.latitude}" lon="${point.longitude}">');
      buffer.writeln('        <time>$isoTime</time>');
      buffer.writeln('      </trkpt>');
    }
    
    buffer.writeln('    </trkseg>');
    buffer.writeln('  </trk>');
    buffer.writeln('</gpx>');

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/track_${track.id}.gpx');
    await file.writeAsString(buffer.toString());
    
    return file;
  }
}
