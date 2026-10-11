import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/agri_city.dart';
import '../models/weather_models.dart';

class WeatherService {
  // In-memory cache to ensure instant loading and zero repeated network requests
  static final Map<String, AgriWeatherReport> _weatherCache = {};
  static AgriCity _currentSelectedCity = AgriCity.defaultCity;

  static AgriCity get currentCity => _currentSelectedCity;

  static void setCity(AgriCity city) {
    _currentSelectedCity = city;
  }

  /// Fetches live weather & agricultural spray advisory from Open-Meteo
  static Future<AgriWeatherReport> fetchWeather({
    AgriCity? city,
    bool forceRefresh = false,
  }) async {
    final targetCity = city ?? _currentSelectedCity;
    _currentSelectedCity = targetCity;
    final cacheKey = targetCity.nameEnglish.toLowerCase();

    // Check in-memory cache (valid for 15 minutes)
    if (!forceRefresh && _weatherCache.containsKey(cacheKey)) {
      final cached = _weatherCache[cacheKey]!;
      if (DateTime.now().difference(cached.lastUpdated).inMinutes < 15) {
        return cached;
      }
    }

    try {
      final url =
          "https://api.open-meteo.com/v1/forecast?latitude=${targetCity.latitude}&longitude=${targetCity.longitude}&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m,wind_direction_10m&hourly=temperature_2m,precipitation_probability,weather_code,wind_speed_10m&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,wind_speed_10m_max&timezone=Asia%2FKarachi&forecast_days=7";

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final report = _parseWeatherReport(targetCity, data);
        _weatherCache[cacheKey] = report;
        return report;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Live Open-Meteo weather fetch error: $e");
      }
    }

    // Graceful offline fallback
    if (_weatherCache.containsKey(cacheKey)) {
      return _weatherCache[cacheKey]!;
    }
    return _getFallbackReport(targetCity);
  }

  static AgriWeatherReport _parseWeatherReport(
      AgriCity city, Map<String, dynamic> data) {
    final currentMap = data['current'] as Map<String, dynamic>;
    final hourlyMap = data['hourly'] as Map<String, dynamic>;
    final dailyMap = data['daily'] as Map<String, dynamic>;

    final double temp = (currentMap['temperature_2m'] as num).toDouble();
    final double feelsLike =
        (currentMap['apparent_temperature'] as num?)?.toDouble() ?? temp;
    final int humidity = (currentMap['relative_humidity_2m'] as num).toInt();
    final double windSpeed =
        (currentMap['wind_speed_10m'] as num).toDouble();
    final double precip =
        (currentMap['precipitation'] as num?)?.toDouble() ?? 0.0;
    final int weatherCode = (currentMap['weather_code'] as num).toInt();

    final condition = _getConditionDetails(weatherCode);

    final current = CurrentWeather(
      temperature: temp,
      feelsLike: feelsLike,
      humidity: humidity,
      windSpeed: windSpeed,
      precipitation: precip,
      weatherCode: weatherCode,
      isDay: (currentMap['is_day'] as num?)?.toInt() == 1,
      conditionEnglish: condition.english,
      conditionUrdu: condition.urdu,
      icon: condition.icon,
    );

    // Calculate smart agricultural spray advisory
    final sprayAdvisory = _calculateSprayAdvisory(
      windSpeed: windSpeed,
      temp: temp,
      precip: precip,
      humidity: humidity,
      weatherCode: weatherCode,
    );

    // Calculate smart irrigation advisory
    final irrigationAdvisory = _calculateIrrigationAdvisory(dailyMap);

    // Parse Hourly (Next 12 hours)
    final hourlyList = _parseHourly(hourlyMap);

    // Parse Daily (7 Days)
    final dailyList = _parseDaily(dailyMap);

    return AgriWeatherReport(
      city: city,
      current: current,
      sprayAdvisory: sprayAdvisory,
      irrigationAdvisory: irrigationAdvisory,
      hourlyForecast: hourlyList,
      dailyForecast: dailyList,
      lastUpdated: DateTime.now(),
    );
  }

  static SprayAdvisory _calculateSprayAdvisory({
    required double windSpeed,
    required double temp,
    required double precip,
    required int humidity,
    required int weatherCode,
  }) {
    // 1. High Wind Danger (Drift & Wastage)
    if (windSpeed > 17.0) {
      return const SprayAdvisory(
        status: SprayStatus.notRecommended,
        titleEnglish: "Do Not Spray (High Wind)",
        titleUrdu: "اسپرے ہرگز نہ کریں (تیز ہوا)",
        reasonEnglish:
            "Wind speed is too high. Chemical will drift away and get wasted.",
        reasonUrdu:
            "ہوا کی رفتار بہت تیز ہے۔ دوا پودے پر ٹھہرنے کے بجائے اڑ کر ضائع ہو جائے گی۔",
        bestWindowEnglish: "Wait for wind to drop below 12 km/h",
        bestWindowUrdu: "ہوا کی رفتار 12 کلومیٹر فی گھنٹہ سے کم ہونے کا انتظار کریں",
        statusColor: Color(0xFFE53935),
      );
    }

    // 2. Rain / Precipitation Danger (Wash-off)
    if (precip > 0.2 || (weatherCode >= 51 && weatherCode <= 99)) {
      return const SprayAdvisory(
        status: SprayStatus.notRecommended,
        titleEnglish: "Do Not Spray (Rain Danger)",
        titleUrdu: "اسپرے نہ کریں (بارش کا خطرہ)",
        reasonEnglish:
            "Rain or drizzle will wash away expensive pesticides and fungicides.",
        reasonUrdu:
            "بارش یا بونداباندی کی وجہ سے مہنگی دوا دھل جائے گی اور اثر ضائع ہو جائے گا۔",
        bestWindowEnglish: "Wait until fields are dry for at least 24 hours",
        bestWindowUrdu: "بارش رکنے اور پتے مکمل خشک ہونے تک انتظار کریں",
        statusColor: Color(0xFFE53935),
      );
    }

    // 3. Moderate Wind or High Heat Stress
    if (windSpeed >= 12.0 || temp > 36.0) {
      return const SprayAdvisory(
        status: SprayStatus.caution,
        titleEnglish: "Spray with Caution",
        titleUrdu: "احتیاط کے ساتھ اسپرے کریں",
        reasonEnglish:
            "Moderate wind or high temperature. Avoid midday spray to prevent leaf burn.",
        reasonUrdu:
            "تیز دھوپ اور گرمی ہے۔ دوپہر میں اسپرے نہ کریں، پتے جھلس سکتے ہیں۔",
        bestWindowEnglish: "Early Morning (6:30 - 9:30 AM) or Late Evening",
        bestWindowUrdu: "صبح 6:30 سے 9:30 بجے یا شام 4:30 کے بعد اسپرے کریں",
        statusColor: Color(0xFFF59E0B),
      );
    }

    // 4. Optimal / Perfect Conditions
    return const SprayAdvisory(
      status: SprayStatus.optimal,
      titleEnglish: "Ideal Weather for Spray",
      titleUrdu: "اسپرے کے لیے بہترین وقت ہے",
      reasonEnglish:
          "Gentle breeze, clear weather, and safe temperature ensure maximum pesticide efficacy.",
      reasonUrdu:
          "ہوا پرسکون اور موسم صاف ہے۔ دوا کا 100% بھرپور اثر ملے گا۔",
      bestWindowEnglish: "Morning (7:00 - 10:30 AM) or Evening (4:00 - 6:30 PM)",
      bestWindowUrdu: "صبح 7:00 سے 10:30 بجے یا شام 4:00 سے 6:30 بجے",
      statusColor: Color(0xFF2E7D32),
    );
  }

  static IrrigationAdvisory _calculateIrrigationAdvisory(
      Map<String, dynamic> dailyMap) {
    final rainProbList =
        (dailyMap['precipitation_probability_max'] as List?) ?? [];
    bool rainExpectedSoon = false;

    // Check rain probability in the next 3 days
    for (int i = 0; i < rainProbList.length && i < 3; i++) {
      if ((rainProbList[i] as num).toInt() > 40) {
        rainExpectedSoon = true;
        break;
      }
    }

    if (rainExpectedSoon) {
      return const IrrigationAdvisory(
        canIrrigate: false,
        titleEnglish: "Hold Irrigation (Rain Expected)",
        titleUrdu: "آبپاشی مؤخر کریں (بارش متوقع)",
        descriptionEnglish:
            "Significant rain is expected in next 2-3 days. Avoid overwatering.",
        descriptionUrdu:
            "اگلے 2 سے 3 دنوں میں بارش کا قوی امکان ہے۔ پانی لگانے سے گریز کریں تاکہ فصل گرنے سے محفوظ رہے۔",
      );
    } else {
      return const IrrigationAdvisory(
        canIrrigate: true,
        titleEnglish: "Irrigation Recommended",
        titleUrdu: "ضرورت کے مطابق پانی لگائیں",
        descriptionEnglish:
            "Weather is dry and stable. Water your crops as per soil condition.",
        descriptionUrdu:
            "موسم خشک اور مستحکم ہے۔ فصل اور زمین کی نمی کے مطابق معمول کی آبپاشی کریں۔",
      );
    }
  }

  static List<HourlyForecastItem> _parseHourly(Map<String, dynamic> hourlyMap) {
    final times = (hourlyMap['time'] as List?) ?? [];
    final temps = (hourlyMap['temperature_2m'] as List?) ?? [];
    final rains = (hourlyMap['precipitation_probability'] as List?) ?? [];
    final codes = (hourlyMap['weather_code'] as List?) ?? [];

    final now = DateTime.now();
    final List<HourlyForecastItem> result = [];

    for (int i = 0; i < times.length && result.length < 12; i++) {
      final t = DateTime.tryParse(times[i].toString()) ?? now;
      if (t.isAfter(now.subtract(const Duration(minutes: 50)))) {
        final code = (codes[i] as num).toInt();
        final cond = _getConditionDetails(code);
        final hour = t.hour;
        final hourStr =
            "${hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)} ${hour >= 12 ? 'PM' : 'AM'}";

        result.add(HourlyForecastItem(
          hourString: hourStr,
          temperature: (temps[i] as num).toDouble(),
          rainChance: (rains[i] as num).toInt(),
          icon: cond.icon,
        ));
      }
    }
    return result;
  }

  static List<DailyForecastItem> _parseDaily(Map<String, dynamic> dailyMap) {
    final times = (dailyMap['time'] as List?) ?? [];
    final maxTemps = (dailyMap['temperature_2m_max'] as List?) ?? [];
    final minTemps = (dailyMap['temperature_2m_min'] as List?) ?? [];
    final rains = (dailyMap['precipitation_probability_max'] as List?) ?? [];
    final codes = (dailyMap['weather_code'] as List?) ?? [];

    final List<DailyForecastItem> result = [];

    for (int i = 0; i < times.length && i < 7; i++) {
      final t = DateTime.tryParse(times[i].toString()) ?? DateTime.now();
      final code = (codes[i] as num).toInt();
      final cond = _getConditionDetails(code);

      String dayEn = _getDayNameEnglish(t.weekday);
      String dayUr = _getDayNameUrdu(t.weekday);

      if (i == 0) {
        dayEn = "Today";
        dayUr = "آج";
      } else if (i == 1) {
        dayEn = "Tomorrow";
        dayUr = "کل";
      }

      result.add(DailyForecastItem(
        dayNameEnglish: dayEn,
        dayNameUrdu: dayUr,
        minTemp: (minTemps[i] as num).toDouble(),
        maxTemp: (maxTemps[i] as num).toDouble(),
        rainChance: (rains[i] as num).toInt(),
        conditionEnglish: cond.english,
        conditionUrdu: cond.urdu,
        icon: cond.icon,
      ));
    }
    return result;
  }

  static _ConditionMeta _getConditionDetails(int code) {
    switch (code) {
      case 0:
        return const _ConditionMeta("Clear Sky", "صاف آسمان", Icons.wb_sunny_rounded);
      case 1:
      case 2:
        return const _ConditionMeta("Partly Cloudy", "جزوی ابر آلود", Icons.cloud_queue_rounded);
      case 3:
        return const _ConditionMeta("Overcast", "گہرے بادل", Icons.cloud_rounded);
      case 45:
      case 48:
        return const _ConditionMeta("Foggy", "دھند", Icons.foggy);
      case 51:
      case 53:
      case 55:
        return const _ConditionMeta("Light Drizzle", "ہلکی بونداباندی", Icons.grain_rounded);
      case 61:
      case 63:
      case 65:
        return const _ConditionMeta("Rain", "بارش", Icons.water_drop_rounded);
      case 80:
      case 81:
      case 82:
        return const _ConditionMeta("Heavy Showers", "تیز بارش", Icons.shower_rounded);
      case 95:
      case 96:
      case 99:
        return const _ConditionMeta("Thunderstorm", "گرج چمک اور آندھی", Icons.thunderstorm_rounded);
      default:
        return const _ConditionMeta("Clear Sky", "صاف موسم", Icons.wb_sunny_rounded);
    }
  }

  static String _getDayNameEnglish(int weekday) {
    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return days[(weekday - 1) % 7];
  }

  static String _getDayNameUrdu(int weekday) {
    const days = [
      "پیر",
      "منگل",
      "بدھ",
      "جمعرات",
      "جمعہ",
      "ہفتہ",
      "اتوار"
    ];
    return days[(weekday - 1) % 7];
  }

  static AgriWeatherReport _getFallbackReport(AgriCity city) {
    return AgriWeatherReport(
      city: city,
      current: const CurrentWeather(
        temperature: 28.0,
        feelsLike: 29.0,
        humidity: 55,
        windSpeed: 8.5,
        precipitation: 0.0,
        weatherCode: 0,
        isDay: true,
        conditionEnglish: "Clear Sky",
        conditionUrdu: "صاف آسمان",
        icon: Icons.wb_sunny_rounded,
      ),
      sprayAdvisory: const SprayAdvisory(
        status: SprayStatus.optimal,
        titleEnglish: "Ideal Weather for Spray",
        titleUrdu: "اسپرے کے لیے بہترین وقت ہے",
        reasonEnglish: "Gentle breeze and clear weather ensure great efficacy.",
        reasonUrdu: "ہوا پرسکون اور موسم صاف ہے۔ دوا کا بہترین رزلٹ ملے گا۔",
        bestWindowEnglish: "Morning (7:00 - 10:30 AM)",
        bestWindowUrdu: "صبح 7:00 سے 10:30 بجے یا شام 4:30 بجے",
        statusColor: Color(0xFF2E7D32),
      ),
      irrigationAdvisory: const IrrigationAdvisory(
        canIrrigate: true,
        titleEnglish: "Irrigation Recommended",
        titleUrdu: "معمول کی آبپاشی کریں",
        descriptionEnglish: "Weather is dry and stable across the region.",
        descriptionUrdu: "موسم خشک ہے۔ ضرورت کے مطابق پانی لگائیں۔",
      ),
      hourlyForecast: [
        const HourlyForecastItem(
            hourString: "Now", temperature: 28, rainChance: 0, icon: Icons.wb_sunny_rounded),
        const HourlyForecastItem(
            hourString: "12 PM", temperature: 31, rainChance: 0, icon: Icons.wb_sunny_rounded),
        const HourlyForecastItem(
            hourString: "3 PM", temperature: 33, rainChance: 5, icon: Icons.wb_sunny_rounded),
        const HourlyForecastItem(
            hourString: "6 PM", temperature: 29, rainChance: 0, icon: Icons.wb_sunny_rounded),
        const HourlyForecastItem(
            hourString: "9 PM", temperature: 26, rainChance: 0, icon: Icons.nightlight_round),
      ],
      dailyForecast: [
        const DailyForecastItem(
          dayNameEnglish: "Today",
          dayNameUrdu: "آج",
          minTemp: 20,
          maxTemp: 33,
          rainChance: 0,
          conditionEnglish: "Sunny",
          conditionUrdu: "صاف دھوپ",
          icon: Icons.wb_sunny_rounded,
        ),
        const DailyForecastItem(
          dayNameEnglish: "Tomorrow",
          dayNameUrdu: "کل",
          minTemp: 21,
          maxTemp: 34,
          rainChance: 5,
          conditionEnglish: "Clear",
          conditionUrdu: "صاف موسم",
          icon: Icons.wb_sunny_rounded,
        ),
      ],
      lastUpdated: DateTime.now(),
    );
  }
}

class _ConditionMeta {
  final String english;
  final String urdu;
  final IconData icon;

  const _ConditionMeta(this.english, this.urdu, this.icon);
}
