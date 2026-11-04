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
  final List<String> imageUrls;

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
    this.rating = 5.0,
    this.reviewsCount = 0,
    this.inStock = true,
    this.descriptionEnglish = '',
    this.descriptionUrdu = '',
    this.dosageEnglish = '',
    this.dosageUrdu = '',
    this.targetEnglish = '',
    this.targetUrdu = '',
    this.dealerNameEnglish = '',
    this.dealerNameUrdu = '',
    this.dealerPhone = '',
    this.dealerLocationEnglish = '',
    this.dealerLocationUrdu = '',
    this.imageUrl = '',
    this.imageUrls = const [],
  });

  List<String> get allImages => imageUrls.isNotEmpty ? imageUrls : (imageUrl.isNotEmpty ? [imageUrl] : []);

  AgriProductModel copyWith({
    String? id,
    String? nameEnglish,
    String? nameUrdu,
    AgriProductCategory? category,
    String? companyEnglish,
    String? companyUrdu,
    String? packSizeEnglish,
    String? packSizeUrdu,
    double? price,
    double? originalPrice,
    double? rating,
    int? reviewsCount,
    bool? inStock,
    String? descriptionEnglish,
    String? descriptionUrdu,
    String? dosageEnglish,
    String? dosageUrdu,
    String? targetEnglish,
    String? targetUrdu,
    String? dealerNameEnglish,
    String? dealerNameUrdu,
    String? dealerPhone,
    String? dealerLocationEnglish,
    String? dealerLocationUrdu,
    String? imageUrl,
    List<String>? imageUrls,
  }) {
    return AgriProductModel(
      id: id ?? this.id,
      nameEnglish: nameEnglish ?? this.nameEnglish,
      nameUrdu: nameUrdu ?? this.nameUrdu,
      category: category ?? this.category,
      companyEnglish: companyEnglish ?? this.companyEnglish,
      companyUrdu: companyUrdu ?? this.companyUrdu,
      packSizeEnglish: packSizeEnglish ?? this.packSizeEnglish,
      packSizeUrdu: packSizeUrdu ?? this.packSizeUrdu,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      inStock: inStock ?? this.inStock,
      descriptionEnglish: descriptionEnglish ?? this.descriptionEnglish,
      descriptionUrdu: descriptionUrdu ?? this.descriptionUrdu,
      dosageEnglish: dosageEnglish ?? this.dosageEnglish,
      dosageUrdu: dosageUrdu ?? this.dosageUrdu,
      targetEnglish: targetEnglish ?? this.targetEnglish,
      targetUrdu: targetUrdu ?? this.targetUrdu,
      dealerNameEnglish: dealerNameEnglish ?? this.dealerNameEnglish,
      dealerNameUrdu: dealerNameUrdu ?? this.dealerNameUrdu,
      dealerPhone: dealerPhone ?? this.dealerPhone,
      dealerLocationEnglish: dealerLocationEnglish ?? this.dealerLocationEnglish,
      dealerLocationUrdu: dealerLocationUrdu ?? this.dealerLocationUrdu,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }

  Map<String, dynamic> toMap() {
    final list = allImages;
    return {
      'id': id,
      'nameEnglish': nameEnglish,
      'nameUrdu': nameUrdu,
      'category': category.name,
      'companyEnglish': companyEnglish,
      'companyUrdu': companyUrdu,
      'packSizeEnglish': packSizeEnglish,
      'packSizeUrdu': packSizeUrdu,
      'price': price,
      'originalPrice': originalPrice,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'inStock': inStock,
      'descriptionEnglish': descriptionEnglish,
      'descriptionUrdu': descriptionUrdu,
      'dosageEnglish': dosageEnglish,
      'dosageUrdu': dosageUrdu,
      'targetEnglish': targetEnglish,
      'targetUrdu': targetUrdu,
      'dealerNameEnglish': dealerNameEnglish,
      'dealerNameUrdu': dealerNameUrdu,
      'dealerPhone': dealerPhone,
      'dealerLocationEnglish': dealerLocationEnglish,
      'dealerLocationUrdu': dealerLocationUrdu,
      'imageUrl': list.isNotEmpty ? list.first : imageUrl,
      'imageUrls': list,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory AgriProductModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    final catStr = (map['category'] as String? ?? 'seeds').toLowerCase();
    AgriProductCategory cat = AgriProductCategory.seeds;
    if (catStr.contains('fert')) {
      cat = AgriProductCategory.fertilizers;
    } else if (catStr.contains('spray')) {
      cat = AgriProductCategory.sprays;
    }

    final List<String> imgs = [];
    if (map['imageUrls'] is List) {
      imgs.addAll((map['imageUrls'] as List).map((e) => e.toString()));
    } else if (map['imageUrl'] != null && map['imageUrl'].toString().isNotEmpty) {
      imgs.add(map['imageUrl'].toString());
    }

    final primaryImg = imgs.isNotEmpty ? imgs.first : (map['imageUrl']?.toString() ?? '');

    return AgriProductModel(
      id: docId ?? map['id']?.toString() ?? 'prod-${DateTime.now().millisecondsSinceEpoch}',
      nameEnglish: map['nameEnglish']?.toString() ?? '',
      nameUrdu: map['nameUrdu']?.toString() ?? map['nameEnglish']?.toString() ?? '',
      category: cat,
      companyEnglish: map['companyEnglish']?.toString() ?? '',
      companyUrdu: map['companyUrdu']?.toString() ?? map['companyEnglish']?.toString() ?? '',
      packSizeEnglish: map['packSizeEnglish']?.toString() ?? '',
      packSizeUrdu: map['packSizeUrdu']?.toString() ?? map['packSizeEnglish']?.toString() ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (map['originalPrice'] as num?)?.toDouble() ?? 0.0,
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      reviewsCount: (map['reviewsCount'] as num?)?.toInt() ?? 0,
      inStock: map['inStock'] as bool? ?? true,
      descriptionEnglish: map['descriptionEnglish']?.toString() ?? '',
      descriptionUrdu: map['descriptionUrdu']?.toString() ?? '',
      dosageEnglish: map['dosageEnglish']?.toString() ?? '',
      dosageUrdu: map['dosageUrdu']?.toString() ?? '',
      targetEnglish: map['targetEnglish']?.toString() ?? '',
      targetUrdu: map['targetUrdu']?.toString() ?? '',
      dealerNameEnglish: map['dealerNameEnglish']?.toString() ?? '',
      dealerNameUrdu: map['dealerNameUrdu']?.toString() ?? '',
      dealerPhone: map['dealerPhone']?.toString() ?? '',
      dealerLocationEnglish: map['dealerLocationEnglish']?.toString() ?? '',
      dealerLocationUrdu: map['dealerLocationUrdu']?.toString() ?? '',
      imageUrl: primaryImg,
      imageUrls: imgs,
    );
  }

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
