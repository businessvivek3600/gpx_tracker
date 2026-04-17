# GPX Tracker Pro

This is a Flutter mobile app that tracks user location, saves it locally, and allows exporting the recorded route as a GPX file.

## What the app does

* Start and stop location tracking
* Record latitude, longitude, and time continuously
* Store all data locally using SQLite
* Show previous tracking history
* Display route on map
* Export and share track as a `.gpx` file

## How it works

* When tracking starts, a new track is created in the database
* Background service collects location updates
* Each location is saved as a track point
* When tracking stops, the track is completed
* History screen shows all saved tracks
* Map screen displays route using stored points
* GPX file is generated from recorded data

## Project structure

* `core/` → common utilities (theme, constants, background service, GPX generator)
* `data/` → database, models, repository implementation
* `domain/` → entities, repository interface, usecases
* `presentation/` → UI screens and controllers

## Main features used

* GetX (state management and dependency injection)
* Sqflite (local database)
* Geolocator (location tracking)
* Flutter Background Service (background tracking)
* Flutter Map (route display)
* Share Plus (file sharing)


## Notes

* Location permission is required (including background location)
* App works best when "Allow all the time" permission is granted
* Background tracking depends on device OS restrictions
# GPX-Tracker
