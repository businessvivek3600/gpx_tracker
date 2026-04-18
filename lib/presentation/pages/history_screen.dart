import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/history_controller.dart';
import 'map_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HistoryController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track History'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.secondaryColor));
        }

        if (controller.tracks.isEmpty) {
          return Center(
            child: Text(
              'No recorded tracks yet.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.tracks.length,
          itemBuilder: (context, index) {
            final track = controller.tracks[index];
            final DateFormat formatter = DateFormat('MMM dd, yyyy - HH:mm');
            final String startStr = formatter.format(track.startTime);
            
            String durationStr = "In Progress";
            if (track.endTime != null) {
              final dur = track.endTime!.difference(track.startTime);
              durationStr = '${dur.inHours}h ${dur.inMinutes.remainder(60)}m ${dur.inSeconds.remainder(60)}s';
            }

            return Dismissible(
              key: Key(track.id.toString()),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.red,
                margin: const EdgeInsets.only(bottom: 16),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) {
                if (track.id != null) {
                  controller.deleteTrack(track.id!);
                  Get.snackbar(
                    'Deleted', 
                    'Track history deleted',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              child: Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: Icon(Icons.route, color: Colors.white),
                  ),
                  title: Text(
                    startStr,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.timer, size: 16, color: AppTheme.textSecondaryColor),
                        const SizedBox(width: 4),
                        Text(durationStr),
                      ],
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: AppTheme.secondaryColor),
                  onTap: () {
                    if (track.id != null) {
                      Get.to(() => MapScreen(trackId: track.id!, track: track));
                    }
                  },
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
