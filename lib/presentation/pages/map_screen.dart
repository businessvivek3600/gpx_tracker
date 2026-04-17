import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/track_entity.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/map_controller.dart';

class MapScreen extends StatelessWidget {
  final int trackId;
  final TrackEntity track;

  const MapScreen({super.key, required this.trackId, required this.track});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      TrackMapController(trackId: trackId, track: track),
      tag: trackId.toString(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Track #$trackId'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => controller.exportAndShareGpx(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.secondaryColor),
          );
        }

        if (controller.route.isEmpty) {
          return const Center(child: Text('No location points recorded.'));
        }

        final initialCenter = controller.route.first;
        final mapController = MapController();

        return FlutterMap(
          mapController: mapController,
          options: MapOptions(initialCenter: initialCenter, initialZoom: 15.0),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.gpx_tracker',
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: controller.route,
                  strokeWidth: 4.0,
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: controller.route.first,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.green,
                    size: 40,
                  ),
                ),
                if (controller.route.length > 1)
                  Marker(
                    point: controller.route.last,
                    child: const Icon(Icons.flag, color: Colors.red, size: 40),
                  ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
