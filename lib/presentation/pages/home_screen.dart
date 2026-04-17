import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/home_controller.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('GPX Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Get.to(() => const HistoryScreen());
            },
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 10,
                    )
                  ],
                ),
                child: Obx(() {
                  return Icon(
                    controller.isTracking.value ? Icons.satellite_alt : Icons.location_off,
                    size: 80,
                    color: controller.isTracking.value ? AppTheme.secondaryColor : AppTheme.textSecondaryColor,
                  );
                }),
              ),
              const SizedBox(height: 48),
              Obx(() {
                return Text(
                  _formatDuration(controller.trackDuration.value),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                );
              }),
              const SizedBox(height: 16),
              Obx(() {
                return Text(
                  controller.currentLocationText.value,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                );
              }),
              const SizedBox(height: 48),
              Obx(() {
                final isTracking = controller.isTracking.value;
                return SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () => controller.toggleTracking(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isTracking ? AppTheme.errorColor : AppTheme.primaryColor,
                    ),
                    child: Text(
                      isTracking ? 'STOP TRACKING' : 'START TRACKING',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }
}
