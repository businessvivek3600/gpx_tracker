import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/usecases/track_usecases.dart';

class HomeController extends GetxController {
  final TrackUsecases _usecases = Get.find<TrackUsecases>();

  var isTracking = false.obs;
  var currentLocationText = "Waiting for location...".obs;
  var trackDuration = Duration.zero.obs;

  Timer? _timer;
  int? _currentTrackId;

  @override
  void onInit() {
    super.onInit();
    _requestInitialPermissions();
    _checkServiceStatus();
  }

  Future<void> _requestInitialPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> _checkServiceStatus() async {
    final service = FlutterBackgroundService();
    bool isRunning = await service.isRunning();
    
    if (isRunning) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _currentTrackId = prefs.getInt('current_track_id');
      if (_currentTrackId != null) {
        isTracking.value = true;
        _startTimer();
      } else {
        service.invoke('stopService');
      }

      service.on('update').listen((event) {
        if (event != null) {
          double lat = event['latitude'];
          double lon = event['longitude'];
          currentLocationText.value = "Lat: ${lat.toStringAsFixed(4)}, Lon: ${lon.toStringAsFixed(4)}";
        }
      });
    }
  }

  Future<bool> _requestPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar(
        'GPS Disabled', 
        'Your device location services are turned off. Please turn on GPS.',
        mainButton: TextButton(
          onPressed: () => Geolocator.openLocationSettings(), 
          child: const Text('ENABLE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
        ),
        duration: const Duration(seconds: 10),
      );
      return false;
    }

    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        'Action Required', 
        'Location permission is permanently denied. Please enable it in Settings.',
        mainButton: TextButton(
          onPressed: () => Geolocator.openAppSettings(), 
          child: const Text('SETTINGS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
        ),
        duration: const Duration(seconds: 10),
      );
      return false;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return false; 
      }
    }

    if (permission == LocationPermission.whileInUse) {
      var alwaysStatus = await Permission.locationAlways.status;
      if (!alwaysStatus.isGranted && !alwaysStatus.isPermanentlyDenied) {
        await Permission.locationAlways.request();
      }
    }

    return true;
  }

  Future<void> toggleTracking() async {
    bool hasPermissions = await _requestPermissions();
    if (!hasPermissions) {
      Get.snackbar('Permissions Denied', 'Please grant location permissions to track.');
      return;
    }

    final service = FlutterBackgroundService();
    
    if (isTracking.value) {
      if (_currentTrackId != null) {
        await _usecases.stopTrack(_currentTrackId!);
        _currentTrackId = null;
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_track_id');
      
      service.invoke('stopService');
      _stopTimer();
      isTracking.value = false;
      currentLocationText.value = "Tracking stopped.";
    } else {
      final track = await _usecases.startTrack();
      _currentTrackId = track.id;
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('current_track_id', _currentTrackId!);
      
      await service.startService();
      
      service.on('update').listen((event) {
        if (event != null) {
          double lat = event['latitude'];
          double lon = event['longitude'];
          currentLocationText.value = "Lat: ${lat.toStringAsFixed(4)}, Lon: ${lon.toStringAsFixed(4)}";
        }
      });
      
      _startTimer();
      isTracking.value = true;
      currentLocationText.value = "Tracking started...";
    }
  }

  void _startTimer() {
    trackDuration.value = Duration.zero;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      trackDuration.value += const Duration(seconds: 1);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    trackDuration.value = Duration.zero;
  }
}
