enum AppRole {
  farmer,
  machineryProvider,
  seedFertilizerDealer;

  String get id {
    switch (this) {
      case AppRole.farmer:
        return 'farmer';
      case AppRole.machineryProvider:
        return 'machinery_provider';
      case AppRole.seedFertilizerDealer:
        return 'dealer';
    }
  }

  String get englishTitle {
    switch (this) {
      case AppRole.farmer:
        return 'Farmer / Grower';
      case AppRole.machineryProvider:
        return 'Machinery Provider';
      case AppRole.seedFertilizerDealer:
        return 'Seeds & Fertilizer Seller';
    }
  }

  String get urduTitle {
    switch (this) {
      case AppRole.farmer:
        return 'کسان / زمیندار';
      case AppRole.machineryProvider:
        return 'مشینری پرووائیڈر';
      case AppRole.seedFertilizerDealer:
        return 'کھاد، بیج و زرعی ڈیلر';
    }
  }

  String get englishSubtitle {
    switch (this) {
      case AppRole.farmer:
        return 'Crop Ledger, Mandi Rates, Machinery Renting & Crop Doctor';
      case AppRole.machineryProvider:
        return 'Rent out Harvester, Laser, Baler, Drone & Track Bookings';
      case AppRole.seedFertilizerDealer:
        return 'Sell Fertilizer, Certified Seeds, Pesticides & Manage Orders';
    }
  }

  String get urduSubtitle {
    switch (this) {
      case AppRole.farmer:
        return 'ڈیجیٹل کھاتہ، منڈی ریٹ، مشینری کرایہ اور فصلوں کا علاج';
      case AppRole.machineryProvider:
        return 'ہارویسٹر، لیزر، بیلر اور ڈرون کرائے پر دیں اور بکنگ لیں';
      case AppRole.seedFertilizerDealer:
        return 'کھاد، معیاری بیج، زرعی ادویات فروخت کریں اور گاہک بڑھائیں';
    }
  }
}
