import 'package:flutter/material.dart';
import 'agri_city.dart';

enum SprayStatus {
  optimal,        // سبز: بہترین وقت
  caution,        // پیلا: احتیاط کریں
  notRecommended, // سرخ: اسپرے ہرگز نہ کریں
}

class CurrentWeather {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final double precipitation;
  final int weatherCode;
  final bool isDay;
  final String conditionEnglish;
  final String conditionUrdu;
  final IconData icon;

  const CurrentWeather({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.precipitation,
    required this.weatherCode,
    required this.isDay,
    required this.conditionEnglish,
    required this.conditionUrdu,
    required this.icon,
  });
}

class SprayAdvisory {
  final SprayStatus status;
  final String titleEnglish;
  final String titleUrdu;
  final String reasonEnglish;
  final String reasonUrdu;
  final String bestWindowEnglish;
  final String bestWindowUrdu;
  final Color statusColor;

  const SprayAdvisory({
    required this.status,
    required this.titleEnglish,
    required this.titleUrdu,
    required this.reasonEnglish,
    required this.reasonUrdu,
    required this.bestWindowEnglish,
    required this.bestWindowUrdu,
    required this.statusColor,
  });
}

class IrrigationAdvisory {
  final bool canIrrigate;
  final String titleEnglish;
  final String titleUrdu;
  final String descriptionEnglish;
  final String descriptionUrdu;

  const IrrigationAdvisory({
    required this.canIrrigate,
    required this.titleEnglish,
    required this.titleUrdu,
    required this.descriptionEnglish,
    required this.descriptionUrdu,
  });
}

class HourlyForecastItem {
  final String hourString;
  final double temperature;
  final int rainChance;
  final IconData icon;

  const HourlyForecastItem({
    required this.hourString,
    required this.temperature,
    required this.rainChance,
    required this.icon,
  });
}

class DailyForecastItem {
  final String dayNameEnglish;
  final String dayNameUrdu;
  final double minTemp;
  final double maxTemp;
  final int rainChance;
  final String conditionEnglish;
  final String conditionUrdu;
  final IconData icon;

  const DailyForecastItem({
    required this.dayNameEnglish,
    required this.dayNameUrdu,
    required this.minTemp,
    required this.maxTemp,
    required this.rainChance,
    required this.conditionEnglish,
    required this.conditionUrdu,
    required this.icon,
  });
}

class AgriWeatherReport {
  final AgriCity city;
  final CurrentWeather current;
  final SprayAdvisory sprayAdvisory;
  final IrrigationAdvisory irrigationAdvisory;
  final List<HourlyForecastItem> hourlyForecast;
  final List<DailyForecastItem> dailyForecast;
  final DateTime lastUpdated;

  const AgriWeatherReport({
    required this.city,
    required this.current,
    required this.sprayAdvisory,
    required this.irrigationAdvisory,
    required this.hourlyForecast,
    required this.dailyForecast,
    required this.lastUpdated,
  });
}
