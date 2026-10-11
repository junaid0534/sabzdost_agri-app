import 'package:flutter/material.dart';

enum PartyTransactionType {
  cropSold,       // آپ نے فصل بیچی (You sold crop to dealer -> You are owed money / Credit)
  itemPurchased,  // آپ نے کھاد، ڈیزل یا اسپرے لی (You bought items -> Deducted from credit or added to debt)
  cashReceived,   // نقد وصولی (Dealer gave you cash -> Reduces what dealer owes you)
  cashPaid,       // نقد ادائیگی (You paid cash to dealer -> Reduces your debt to dealer)
}

extension PartyTransactionTypeExt on PartyTransactionType {
  String get urduTitle {
    switch (this) {
      case PartyTransactionType.cropSold:
        return "فصل فروخت کی (+)";
      case PartyTransactionType.itemPurchased:
        return "اشیاء خریداری (کھاد/ڈیزل/اسپرے) (-)";
      case PartyTransactionType.cashReceived:
        return "نقد کیش وصول کیا (-)";
      case PartyTransactionType.cashPaid:
        return "نقد کیش ادا کیا (+)";
    }
  }

  String get englishTitle {
    switch (this) {
      case PartyTransactionType.cropSold:
        return "Crop Sold to Dealer";
      case PartyTransactionType.itemPurchased:
        return "Bought (Fertilizer/Diesel/Spray)";
      case PartyTransactionType.cashReceived:
        return "Cash Received from Dealer";
      case PartyTransactionType.cashPaid:
        return "Cash Paid to Dealer";
    }
  }

  IconData get icon {
    switch (this) {
      case PartyTransactionType.cropSold:
        return Icons.grass_rounded;
      case PartyTransactionType.itemPurchased:
        return Icons.shopping_cart_rounded;
      case PartyTransactionType.cashReceived:
        return Icons.arrow_downward_rounded;
      case PartyTransactionType.cashPaid:
        return Icons.arrow_upward_rounded;
    }
  }

  // True if this adds to what dealer owes you (Credit)
  bool get isPositiveForFarmer =>
      this == PartyTransactionType.cropSold || this == PartyTransactionType.cashPaid;
}

class PartyTransaction {
  final String id;
  final String partyId;
  final String title;
  final String titleUrdu;
  final double amount;
  final PartyTransactionType type;
  final DateTime date;
  final String note;

  const PartyTransaction({
    required this.id,
    required this.partyId,
    required this.title,
    required this.titleUrdu,
    required this.amount,
    required this.type,
    required this.date,
    this.note = "",
  });
}

class PartyLedger {
  final String id;
  final String name;             // e.g. حاجی اصغر ایگری ڈیلر و آڑھتی
  final String nameEnglish;      // e.g. Haji Asghar Agri Dealer
  final String phone;            // 0300-1234567
  final String location;         // غلہ منڈی ساہیوال
  final String locationEnglish;  // e.g. Grain Market, Sahiwal
  final List<PartyTransaction> transactions;

  const PartyLedger({
    required this.id,
    required this.name,
    this.nameEnglish = "",
    required this.phone,
    required this.location,
    this.locationEnglish = "",
    required this.transactions,
  });

  String displayName(bool isUrdu) => isUrdu ? name : (nameEnglish.isNotEmpty ? nameEnglish : name);
  String displayLocation(bool isUrdu) => isUrdu ? location : (locationEnglish.isNotEmpty ? locationEnglish : location);

  // Net Balance:
  // Positive (> 0): آپ نے ڈیلر سے لینے ہیں (Dealer owes Farmer)
  // Negative (< 0): آپ نے ڈیلر کو دینے ہیں (Farmer owes Dealer)
  // Zero (= 0): حساب برابر / کلئیر
  double get netBalance {
    double balance = 0.0;
    for (final t in transactions) {
      if (t.type.isPositiveForFarmer) {
        balance += t.amount;
      } else {
        balance -= t.amount;
      }
    }
    return balance;
  }

  bool get farmerOwesDealer => netBalance < -0.5;
  bool get dealerOwesFarmer => netBalance > 0.5;
  bool get isSettled => netBalance.abs() <= 0.5;

  PartyLedger copyWith({
    String? id,
    String? name,
    String? nameEnglish,
    String? phone,
    String? location,
    String? locationEnglish,
    List<PartyTransaction>? transactions,
  }) {
    return PartyLedger(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEnglish: nameEnglish ?? this.nameEnglish,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      locationEnglish: locationEnglish ?? this.locationEnglish,
      transactions: transactions ?? this.transactions,
    );
  }
}
