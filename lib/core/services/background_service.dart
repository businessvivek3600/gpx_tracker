import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/local_database.dart';
import '../../data/models/track_point_model.dart';

const notificationChannelId = 'my_foreground';
const notificationId = 888;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId,
    'MY FOREGROUND SERVICE',
    description: 'This channel is used for important notifications.',
    importance: Importance.low, 
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: notificationChannelId,
      initialNotificationTitle: 'GPX Tracker is running',
      initialNotificationContent: 'Tracking your location...',
      foregroundServiceNotificationId: notificationId,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? trackId = prefs.getInt('current_track_id');

  if (trackId == null) {
    service.stopSelf();
    return;
  }

  StreamSubscription<Position>? positionStream;

  LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5,
  );

  positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position? position) async {
    if (position != null) {
      final point = TrackPointModel(
        trackId: trackId,
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: position.timestamp,
      );
      await LocalDatabase.instance.insertTrackPoint(point);

      if (service is AndroidServiceInstance) {
        flutterLocalNotificationsPlugin.show(
          id: notificationId,
          title: 'GPX Tracker Active',
          body: 'Pos: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              notificationChannelId,
              'MY FOREGROUND SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: true,
            ),
          ),
        );
      }
      
      service.invoke(
        'update',
        {
          "latitude": position.latitude,
          "longitude": position.longitude,
          "timestamp": position.timestamp.millisecondsSinceEpoch,
        },
      );
    }
  });

  service.on('stopService').listen((event) async {
    await positionStream?.cancel();
    service.stopSelf();
  });
}
