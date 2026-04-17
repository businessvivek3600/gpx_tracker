import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/track_entity.dart';
import '../../domain/entities/track_point_entity.dart';
import '../../domain/usecases/track_usecases.dart';
import '../../core/utils/gpx_generator.dart';

class TrackMapController extends GetxController {
  final int trackId;
  final TrackEntity track;

  TrackMapController({required this.trackId, required this.track});

  final TrackUsecases _usecases = Get.find<TrackUsecases>();

  var points = <TrackPointEntity>[].obs;
  var route = <LatLng>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPoints();
  }

  Future<void> fetchPoints() async {
    isLoading.value = true;
    final result = await _usecases.fetchTrackPoints(trackId);
    points.assignAll(result);
    route.assignAll(result.map((p) => LatLng(p.latitude, p.longitude)).toList());
    isLoading.value = false;
  }

  Future<void> exportAndShareGpx() async {
    if (points.isEmpty) {
      Get.snackbar('Export Failed', 'No points recorded for this track.');
      return;
    }

    try {
      final file = await GpxGenerator.generateGpxFile(track, points);
      
      Get.snackbar(
        'GPX Exported!', 
        'Saved to: ${file.path}',
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.BOTTOM,
      );

      await Share.shareXFiles([XFile(file.path)], subject: 'GPX Track ${track.id}', text: 'Check out my GPX Route!');
    } catch (e) {
      Get.snackbar('Export Failed', 'Error: $e');
    }
  }
}
