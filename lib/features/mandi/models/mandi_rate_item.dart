import 'package:flutter/material.dart';

enum CropCategory {
  all,
  grains,      // غلہ (گندم، چاول، مکئی)
  cashCrops,   // نقد آور (کپاس، کماد)
  vegetables,  // سبزیاں (آلو، پیاز، ٹماٹر)
  oilseeds,    // تیل دار اجناس (سرسوں، کینولا)
  fertilizers, // کھادیں (یوریا، ڈی اے پی کنٹرول ریٹ)
}

class MandiRateItem {
  final String id;
  final String cropEnglish;
  final String cropUrdu;
  final String categoryEnglish;
  final String categoryUrdu;
  final CropCategory category;
  final String mandiCityEnglish;
  final String mandiCityUrdu;
  final double minRate;
  final double maxRate;
  final double avgRate;
  final double govtRate; // Official Government Notified Support / Benchmark Rate
  final bool isGovtNotified;
  final String govtNotificationRef;
  final double changeAmount;
  final double changePercentage;
  final bool isUp;
  final String unitEnglish;
  final String unitUrdu;
  final IconData icon;

  const MandiRateItem({
    required this.id,
    required this.cropEnglish,
    required this.cropUrdu,
    required this.categoryEnglish,
    required this.categoryUrdu,
    required this.category,
    required this.mandiCityEnglish,
    required this.mandiCityUrdu,
    required this.minRate,
    required this.maxRate,
    required this.avgRate,
    this.govtRate = 0,
    this.isGovtNotified = false,
    this.govtNotificationRef = "Govt. Notified / سرکاری ریٹ",
    required this.changeAmount,
    required this.changePercentage,
    required this.isUp,
    this.unitEnglish = "40 kg (Maund)",
    this.unitUrdu = "۴۰ کلو (من)",
    required this.icon,
  });

  factory MandiRateItem.fromJson(Map<String, dynamic> json) {
    CropCategory cat = CropCategory.all;
    final catStr = json['category']?.toString().toLowerCase() ?? '';
    if (catStr.contains('grain')) {
      cat = CropCategory.grains;
    } else if (catStr.contains('cash')) {
      cat = CropCategory.cashCrops;
    } else if (catStr.contains('veg')) {
      cat = CropCategory.vegetables;
    } else if (catStr.contains('oil')) {
      cat = CropCategory.oilseeds;
    } else if (catStr.contains('fertilizer')) {
      cat = CropCategory.fertilizers;
    }

    IconData icon = Icons.grass_rounded;
    final iconType = json['icon_type']?.toString().toLowerCase() ?? '';
    if (iconType.contains('cloud') || iconType.contains('cotton')) {
      icon = Icons.cloud_rounded;
    } else if (iconType.contains('grain') || iconType.contains('rice')) {
      icon = Icons.grain_rounded;
    } else if (iconType.contains('eco') || iconType.contains('corn')) {
      icon = Icons.eco_rounded;
    } else if (iconType.contains('vertical') || iconType.contains('sugar')) {
      icon = Icons.vertical_align_top_rounded;
    } else if (iconType.contains('fertilizer') || iconType.contains('urea') || iconType.contains('dap')) {
      icon = Icons.science_rounded;
    } else if (iconType.contains('oil') || iconType.contains('mustard')) {
      icon = Icons.water_drop_rounded;
    } else if (iconType.contains('wheat')) {
      icon = Icons.grass_rounded;
    } else if (iconType.contains('circle') || iconType.contains('veg') || iconType.contains('onion') || iconType.contains('potato') || iconType.contains('tomato')) {
      icon = Icons.circle_rounded;
    }

    return MandiRateItem(
      id: json['id']?.toString() ?? UniqueKey().toString(),
      cropEnglish: json['crop_en'] ?? '',
      cropUrdu: json['crop_ur'] ?? '',
      categoryEnglish: json['category_en'] ?? '',
      categoryUrdu: json['category_ur'] ?? '',
      category: cat,
      mandiCityEnglish: json['city_en'] ?? 'Punjab',
      mandiCityUrdu: json['city_ur'] ?? 'پنجاب منڈی',
      minRate: (json['min_rate'] as num?)?.toDouble() ?? 0.0,
      maxRate: (json['max_rate'] as num?)?.toDouble() ?? 0.0,
      avgRate: (json['avg_rate'] as num?)?.toDouble() ?? 0.0,
      govtRate: (json['govt_rate'] as num?)?.toDouble() ?? 0.0,
      isGovtNotified: json['is_govt_notified'] == true,
      govtNotificationRef: json['govt_ref'] ?? "Govt. Notified / سرکاری ریٹ",
      changeAmount: (json['change_amount'] as num?)?.toDouble() ?? 0.0,
      changePercentage: (json['change_pct'] as num?)?.toDouble() ?? 0.0,
      isUp: (json['is_up'] as bool?) ?? true,
      unitEnglish: json['unit_en'] ?? '40 kg (Maund)',
      unitUrdu: json['unit_ur'] ?? '۴۰ کلو (من)',
      icon: icon,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'crop_en': cropEnglish,
      'crop_ur': cropUrdu,
      'category_en': categoryEnglish,
      'category_ur': categoryUrdu,
      'category': category.name,
      'city_en': mandiCityEnglish,
      'city_ur': mandiCityUrdu,
      'min_rate': minRate,
      'max_rate': maxRate,
      'avg_rate': avgRate,
      'govt_rate': govtRate,
      'is_govt_notified': isGovtNotified,
      'govt_ref': govtNotificationRef,
      'change_amount': changeAmount,
      'change_pct': changePercentage,
      'is_up': isUp,
      'unit_en': unitEnglish,
      'unit_ur': unitUrdu,
    };
  }
}
