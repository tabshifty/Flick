import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:logger/logger.dart';

class DataHelper {
  final String path;
  DataHelper(this.path);
  Future<Database>? _db;

  Future<Database> getDb() {
    _db ??= _initDb();
    return _db!;
  }

  // Guaranteed to be called only once.
  Future<Database> _initDb() async {
    final database = await openDatabase(
      join(await getDatabasesPath() , path),
      onCreate: (db, version) {
        db.execute('CREATE TABLE Media_Table (id TEXT PRIMARY KEY, aspectRatio REAL)');
      },
      version: 1,
    );
    // do "tons of stuff in async mode"
    return database;
  }
}

class Helper {
  static const String apiPrefix = '192.168.1.8';
  static final dio =  Dio();
  static var logger = Logger(
    printer: PrettyPrinter(),
  );
  static Future<Database> db = DataHelper('flick_media.db').getDb();
  static final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
  static String formatDuration(Duration? duration) {
    if (duration == null) {
      return '';
    }
    int hour = duration.inHours;
    if (hour > 0) {
      return [hour, duration.inMinutes, duration.inSeconds].map((ele) {
        return ele.remainder(60).toString().padLeft(2, '0');
      }).join(':');
    }
    return [duration.inMinutes, duration.inSeconds].map((ele) {
      return ele.remainder(60).toString().padLeft(2, '0');
    }).join(':');
  }
  static void showLoading (BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:(context) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Color.fromRGBO(0, 0, 0, 0.33),
        child: Center(
          child: LoadingAnimationWidget.flickr(leftDotColor: Color.fromRGBO(201,45,83,1), rightDotColor: Color.fromRGBO(248,193,31,1), size: 50),
        ),
      );
    });
  }
}