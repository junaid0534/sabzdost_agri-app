enum AgriProductCategory {
  all,
  seeds,
  fertilizers,
  sprays,
}

class AgriProductModel {
  final String id;
  final String nameEnglish;
  final String nameUrdu;
  final AgriProductCategory category;
  final String companyEnglish;
  final String companyUrdu;
  final String packSizeEnglish;
  final String packSizeUrdu;
  final double price;
  final double originalPrice;
  final double rating;
  final int reviewsCount;
  final bool inStock;
  final String descriptionEnglish;
  final String descriptionUrdu;
  final String dosageEnglish;
  final String dosageUrdu;
  final String targetEnglish;
  final String targetUrdu;
  final String dealerNameEnglish;
  final String dealerNameUrdu;
  final String dealerPhone;
  final String dealerLocationEnglish;
  final String dealerLocationUrdu;
  final String imageUrl;

  const AgriProductModel({
    required this.id,
    required this.nameEnglish,
    required this.nameUrdu,
    required this.category,
    required this.companyEnglish,
    required this.companyUrdu,
    required this.packSizeEnglish,
    required this.packSizeUrdu,
    required this.price,
    required this.originalPrice,
    required this.rating,
    required this.reviewsCount,
    required this.inStock,
    required this.descriptionEnglish,
    required this.descriptionUrdu,
    required this.dosageEnglish,
    required this.dosageUrdu,
    required this.targetEnglish,
    required this.targetUrdu,
    required this.dealerNameEnglish,
    required this.dealerNameUrdu,
    required this.dealerPhone,
    required this.dealerLocationEnglish,
    required this.dealerLocationUrdu,
    required this.imageUrl,
  });

  String getName(bool isUrdu) => isUrdu ? nameUrdu : nameEnglish;
  String getCompany(bool isUrdu) => isUrdu ? companyUrdu : companyEnglish;
  String getPackSize(bool isUrdu) => isUrdu ? packSizeUrdu : packSizeEnglish;
  String getDescription(bool isUrdu) => isUrdu ? descriptionUrdu : descriptionEnglish;
  String getDosage(bool isUrdu) => isUrdu ? dosageUrdu : dosageEnglish;
  String getTarget(bool isUrdu) => isUrdu ? targetUrdu : targetEnglish;
  String getDealerName(bool isUrdu) => isUrdu ? dealerNameUrdu : dealerNameEnglish;
  String getDealerLocation(bool isUrdu) => isUrdu ? dealerLocationUrdu : dealerLocationEnglish;

  String get categoryNameUrdu {
    switch (category) {
      case AgriProductCategory.seeds:
        return "بیج";
      case AgriProductCategory.fertilizers:
        return "کھاد";
      case AgriProductCategory.sprays:
        return "سپرے";
      case AgriProductCategory.all:
        return "سبھی";
    }
  }

  String get categoryNameEnglish {
    switch (category) {
      case AgriProductCategory.seeds:
        return "Seeds";
      case AgriProductCategory.fertilizers:
        return "Fertilizers";
      case AgriProductCategory.sprays:
        return "Sprays";
      case AgriProductCategory.all:
        return "All";
    }
  }
}
