import 'package:flutter/material.dart';

enum LedgerEntryType {
  expense, // خرچ (Buying / Costs)
  income,  // آمدن (Sales / Revenue)
}

enum PaymentStatus {
  paid,     // مکمل نقد ادا شدہ / وصول شدہ (Full payment)
  partial,  // جزوی وصولی / کچھ نقد کچھ ادھار بقایا (Partial with remaining balance)
  unpaid,   // مکمل ادھار / بقایا (Full Credit / Pending)
}

enum LedgerCategory {
  // --- EXPENSE CATEGORIES (اخراجات / خریداری) ---
  fertilizer, // کھاد (DAP, Urea, Potash)
  seed,       // بیج (Seeds)
  spray,      // اسپرے / زرعی ادویات (Pesticides)
  diesel,     // ڈیزل و ایندھن (Fuel for tubewell/tractor)
  labor,      // مزدور و لیبر (Wages)
  water,      // نہری پانی / آبپاشی (Water / Abiyana)
  machinery,  // ٹریکٹر و مشینری کرایہ (Machinery rent / maintenance)
  feed,       // جانوروں کا چارہ و ونڈا (Cattle feed)
  equipment,  // اوزار و زرعی آلات (Tools & Equipment)
  expenseOther, // متفرق اخراجات (Other Expenses)

  // --- INCOME CATEGORIES (آمدن / فروخت) ---
  cropSale,   // فصل / اناج کی فروخت (Grain & Crop sale)
  vegetableSale, // سبزیاں و پھل فروخت (Vegetables & Fruits)
  fodderSale, // توڑی و چارہ فروخت (Straw / Fodder sale)
  milkSale,   // دودھ و ڈیری فروخت (Milk & Dairy)
  livestockSale, // مویشی فروخت (Cattle / Livestock sale)
  landRent,   // ٹھیکہ / زمین کا کرایہ (Land lease income)
  subsidy,    // حکومتی سبسڈی / امداد (Govt subsidy / Grant)
  incomeOther, // متفرق آمدن (Other Income)
}

extension LedgerCategoryExt on LedgerCategory {
  bool get isIncome {
    switch (this) {
      case LedgerCategory.cropSale:
      case LedgerCategory.vegetableSale:
      case LedgerCategory.fodderSale:
      case LedgerCategory.milkSale:
      case LedgerCategory.livestockSale:
      case LedgerCategory.landRent:
      case LedgerCategory.subsidy:
      case LedgerCategory.incomeOther:
        return true;
      default:
        return false;
    }
  }

  String get urduTitle {
    switch (this) {
      // Expenses:
      case LedgerCategory.fertilizer:
        return "کھاد خریداری";
      case LedgerCategory.seed:
        return "بیج خریداری";
      case LedgerCategory.spray:
        return "اسپرے و زرعی ادویات";
      case LedgerCategory.diesel:
        return "ڈیزل و ایندھن";
      case LedgerCategory.labor:
        return "مزدوری و لیبر";
      case LedgerCategory.water:
        return "پانی و آبیانہ";
      case LedgerCategory.machinery:
        return "ٹریکٹر و مشینری کرایہ";
      case LedgerCategory.feed:
        return "چارہ و ونڈا خریداری";
      case LedgerCategory.equipment:
        return "اوزار و آلات";
      case LedgerCategory.expenseOther:
        return "دیگر اخراجات";

      // Income:
      case LedgerCategory.cropSale:
        return "فصل / اناج فروخت";
      case LedgerCategory.vegetableSale:
        return "سبزیاں و پھل فروخت";
      case LedgerCategory.fodderSale:
        return "توڑی و چارہ فروخت";
      case LedgerCategory.milkSale:
        return "دودھ و ڈیری فروخت";
      case LedgerCategory.livestockSale:
        return "مویشی / جانور فروخت";
      case LedgerCategory.landRent:
        return "زمین کا ٹھیکہ / کرایہ";
      case LedgerCategory.subsidy:
        return "حکومتی سبسڈی / امداد";
      case LedgerCategory.incomeOther:
        return "دیگر آمدن";
    }
  }

  String get englishTitle {
    switch (this) {
      // Expenses:
      case LedgerCategory.fertilizer:
        return "Fertilizer";
      case LedgerCategory.seed:
        return "Seeds Purchase";
      case LedgerCategory.spray:
        return "Pesticides / Spray";
      case LedgerCategory.diesel:
        return "Diesel & Fuel";
      case LedgerCategory.labor:
        return "Labor Wages";
      case LedgerCategory.water:
        return "Irrigation / Canal Water";
      case LedgerCategory.machinery:
        return "Tractor & Machinery Rent";
      case LedgerCategory.feed:
        return "Feed / Fodder Purchase";
      case LedgerCategory.equipment:
        return "Tools & Equipment";
      case LedgerCategory.expenseOther:
        return "Misc Expense";

      // Income:
      case LedgerCategory.cropSale:
        return "Crop Harvest Sale";
      case LedgerCategory.vegetableSale:
        return "Vegetables & Fruits Sale";
      case LedgerCategory.fodderSale:
        return "Straw / Fodder Sale";
      case LedgerCategory.milkSale:
        return "Milk & Dairy Sale";
      case LedgerCategory.livestockSale:
        return "Cattle / Livestock Sale";
      case LedgerCategory.landRent:
        return "Land Lease / Rent";
      case LedgerCategory.subsidy:
        return "Govt. Subsidy / Relief";
      case LedgerCategory.incomeOther:
        return "Other Income";
    }
  }

  IconData get icon {
    switch (this) {
      // Expenses
      case LedgerCategory.fertilizer:
        return Icons.inventory_2_rounded;
      case LedgerCategory.seed:
        return Icons.spa_rounded;
      case LedgerCategory.spray:
        return Icons.sanitizer_rounded;
      case LedgerCategory.diesel:
        return Icons.local_gas_station_rounded;
      case LedgerCategory.labor:
        return Icons.people_alt_rounded;
      case LedgerCategory.water:
        return Icons.water_drop_rounded;
      case LedgerCategory.machinery:
        return Icons.agriculture_rounded;
      case LedgerCategory.feed:
        return Icons.grass_rounded;
      case LedgerCategory.equipment:
        return Icons.handyman_rounded;
      case LedgerCategory.expenseOther:
        return Icons.receipt_long_rounded;

      // Income
      case LedgerCategory.cropSale:
        return Icons.monetization_on_rounded;
      case LedgerCategory.vegetableSale:
        return Icons.shopping_basket_rounded;
      case LedgerCategory.fodderSale:
        return Icons.grain_rounded;
      case LedgerCategory.milkSale:
        return Icons.water_damage_rounded;
      case LedgerCategory.livestockSale:
        return Icons.pets_rounded;
      case LedgerCategory.landRent:
        return Icons.real_estate_agent_rounded;
      case LedgerCategory.subsidy:
        return Icons.account_balance_rounded;
      case LedgerCategory.incomeOther:
        return Icons.savings_rounded;
    }
  }

  Color get color {
    switch (this) {
      // Expense colors
      case LedgerCategory.fertilizer:
        return const Color(0xFF2E7D32);
      case LedgerCategory.seed:
        return const Color(0xFF00897B);
      case LedgerCategory.spray:
        return const Color(0xFFE65100);
      case LedgerCategory.diesel:
        return const Color(0xFFD84315);
      case LedgerCategory.labor:
        return const Color(0xFF1565C0);
      case LedgerCategory.water:
        return const Color(0xFF0288D1);
      case LedgerCategory.machinery:
        return const Color(0xFF5D4037);
      case LedgerCategory.feed:
        return const Color(0xFF689F38);
      case LedgerCategory.equipment:
        return const Color(0xFF455A64);
      case LedgerCategory.expenseOther:
        return const Color(0xFF757575);

      // Income colors
      case LedgerCategory.cropSale:
        return const Color(0xFF1B5E20);
      case LedgerCategory.vegetableSale:
        return const Color(0xFF388E3C);
      case LedgerCategory.fodderSale:
        return const Color(0xFFF57F17);
      case LedgerCategory.milkSale:
        return const Color(0xFF00ACC1);
      case LedgerCategory.livestockSale:
        return const Color(0xFF795548);
      case LedgerCategory.landRent:
        return const Color(0xFF43A047);
      case LedgerCategory.subsidy:
        return const Color(0xFF0D47A1);
      case LedgerCategory.incomeOther:
        return const Color(0xFF2E7D32);
    }
  }

  static List<LedgerCategory> get expenseCategories => [
        LedgerCategory.fertilizer,
        LedgerCategory.seed,
        LedgerCategory.spray,
        LedgerCategory.diesel,
        LedgerCategory.labor,
        LedgerCategory.water,
        LedgerCategory.machinery,
        LedgerCategory.feed,
        LedgerCategory.equipment,
        LedgerCategory.expenseOther,
      ];

  static List<LedgerCategory> get incomeCategories => [
        LedgerCategory.cropSale,
        LedgerCategory.vegetableSale,
        LedgerCategory.fodderSale,
        LedgerCategory.milkSale,
        LedgerCategory.livestockSale,
        LedgerCategory.landRent,
        LedgerCategory.subsidy,
        LedgerCategory.incomeOther,
      ];
}

class LedgerEntry {
  final String id;
  final String title;
  final String titleUrdu;
  final double totalAmount;     // کُل رقم (Total Sale or Bill)
  final double paidAmount;      // وصول شدہ / ادا شدہ رقم (Received or Paid Cash)
  final LedgerEntryType type;
  final LedgerCategory category;
  final String cropName;        // e.g. گندم، کپاس، چاول
  final DateTime date;          // اندراج یا تاریخ
  final String note;            // تفصیل یا نوٹ
  final String partyName;       // آڑھتی / خریدار / ڈیلر کا نام
  final List<PaymentHistoryItem> paymentHistory; // اگر بعد میں بقایا وصول کیا جائے

  const LedgerEntry({
    required this.id,
    required this.title,
    required this.titleUrdu,
    required this.totalAmount,
    required this.paidAmount,
    required this.type,
    required this.category,
    required this.cropName,
    required this.date,
    this.note = "",
    this.partyName = "",
    this.paymentHistory = const [],
  });

  bool get isIncome => type == LedgerEntryType.income;

  // بقایا رقم (Remaining Balance)
  double get remainingBalance {
    final balance = totalAmount - paidAmount;
    return balance > 0 ? balance : 0.0;
  }

  bool get hasRemainingBalance => remainingBalance > 0.5;

  PaymentStatus get status {
    if (paidAmount <= 0) return PaymentStatus.unpaid;
    if (remainingBalance <= 0.5) return PaymentStatus.paid;
    return PaymentStatus.partial;
  }

  LedgerEntry copyWith({
    String? id,
    String? title,
    String? titleUrdu,
    double? totalAmount,
    double? paidAmount,
    LedgerEntryType? type,
    LedgerCategory? category,
    String? cropName,
    DateTime? date,
    String? note,
    String? partyName,
    List<PaymentHistoryItem>? paymentHistory,
  }) {
    return LedgerEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      titleUrdu: titleUrdu ?? this.titleUrdu,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      type: type ?? this.type,
      category: category ?? this.category,
      cropName: cropName ?? this.cropName,
      date: date ?? this.date,
      note: note ?? this.note,
      partyName: partyName ?? this.partyName,
      paymentHistory: paymentHistory ?? this.paymentHistory,
    );
  }
}

class PaymentHistoryItem {
  final double amount;
  final DateTime date;
  final String note;

  const PaymentHistoryItem({
    required this.amount,
    required this.date,
    this.note = "",
  });
}
