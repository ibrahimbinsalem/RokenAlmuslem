import 'package:hive/hive.dart';


@HiveType(typeId: 0)
class PrayerTimeModel {
  @HiveField(0)
  final String fajr;
  
  @HiveField(1)
  final String sunrise;
  
  @HiveField(2)
  final String dhuhr;
  
  @HiveField(3)
  final String asr;
  
  @HiveField(4)
  final String maghrib;
  
  @HiveField(5)
  final String isha;
  
  @HiveField(6)
  final String date;

  PrayerTimeModel({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.date,
  });
}