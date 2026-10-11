import 'package:flutter/material.dart';
import '../../../core/localization/language_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../models/ledger_entry.dart';
import '../widgets/add_ledger_entry_sheet.dart';
import 'crop_khata_detail_screen.dart';

class FarmLedgerScreen extends StatefulWidget {
  final bool? isUrdu;
  final bool showTopModeSwitcher;

  const FarmLedgerScreen({
    super.key,
    this.isUrdu,
    this.showTopModeSwitcher = false,
  });

  @override
  State<FarmLedgerScreen> createState() => _FarmLedgerScreenState();
}

class _FarmLedgerScreenState extends State<FarmLedgerScreen> {
  bool get _isUrdu => widget.isUrdu ?? LanguageController.instance.isUrdu;

  final List<Map<String, dynamic>> _cropTypes = [
    {
      "name": "Wheat",
      "urduName": "گندم",
      "tag": "ربیع فصل",
      "icon": Icons.grass_rounded,
      "color": Color(0xFFE5A93C),
      "filterKey": "گندم",
    },
    {
      "name": "Cotton",
      "urduName": "کپاس",
      "tag": "خریف فصل (سلور)",
      "icon": Icons.cloud_rounded,
      "color": Color(0xFF00897B),
      "filterKey": "کپاس",
    },
    {
      "name": "Rice",
      "urduName": "دھان / چاول",
      "tag": "خریف فصل (مونجی)",
      "icon": Icons.water_drop_rounded,
      "color": Color(0xFF2E7D32),
      "filterKey": "دھان",
    },
    {
      "name": "Maize",
      "urduName": "مکئی",
      "tag": "بہاریہ و خریف",
      "icon": Icons.eco_rounded,
      "color": Color(0xFFEF6C00),
      "filterKey": "مکئی",
    },
    {
      "name": "Sugarcane",
      "urduName": "کماد / گنا",
      "tag": "سالانہ نقد آور",
      "icon": Icons.forest_rounded,
      "color": Color(0xFF388E3C),
      "filterKey": "گنا",
    },
    {
      "name": "Vegetables",
      "urduName": "باغ و سبزیاں",
      "tag": "موسمی پیداوار",
      "icon": Icons.local_florist_rounded,
      "color": Color(0xFF0288D1),
      "filterKey": "سبزیاں",
    },
  ];

  final List<LedgerEntry> _entries = [
    LedgerEntry(
      id: "1",
      title: "گندم فصل فروخت (غلہ منڈی)",
      titleUrdu: "گندم فصل فروخت",
      totalAmount: 60000,
      paidAmount: 30000,
      type: LedgerEntryType.income,
      category: LedgerCategory.cropSale,
      cropName: "گندم (Wheat)",
      date: DateTime.now().subtract(const Duration(hours: 3)),
      note: "نصف رقم وصول ہوئی، 30 ہزار باقی",
    ),
    LedgerEntry(
      id: "2",
      title: "یوریا سونا کھاد 3 بوری",
      titleUrdu: "یوریا سونا کھاد 3 بوری",
      totalAmount: 14400,
      paidAmount: 14400,
      type: LedgerEntryType.expense,
      category: LedgerCategory.fertilizer,
      cropName: "گندم (Wheat)",
      date: DateTime.now().subtract(const Duration(days: 1)),
      note: "مکمل نقد ادا",
    ),
    LedgerEntry(
      id: "3",
      title: "کپاس پھٹی فروخت (15 من)",
      titleUrdu: "کپاس پھٹی فروخت",
      totalAmount: 127500,
      paidAmount: 100000,
      type: LedgerEntryType.income,
      category: LedgerCategory.cropSale,
      cropName: "کپاس (Cotton)",
      date: DateTime.now().subtract(const Duration(days: 3)),
      note: "27,500 بقایا بیلنس",
    ),
    LedgerEntry(
      id: "4",
      title: "ٹیوب ویل ڈیزل 50 لیٹر",
      titleUrdu: "ٹیوب ویل ڈیزل 50L",
      totalAmount: 13750,
      paidAmount: 13750,
      type: LedgerEntryType.expense,
      category: LedgerCategory.diesel,
      cropName: "کپاس (Cotton)",
      date: DateTime.now().subtract(const Duration(days: 4)),
      note: "پہلا پانی لگایا",
    ),
    LedgerEntry(
      id: "5",
      title: "کیڑے مار اسپرے",
      titleUrdu: "کیڑے مار اسپرے",
      totalAmount: 7800,
      paidAmount: 4000,
      type: LedgerEntryType.expense,
      category: LedgerCategory.spray,
      cropName: "کپاس (Cotton)",
      date: DateTime.now().subtract(const Duration(days: 5)),
      note: "3800 روپے ادھار بقایا",
    ),
    LedgerEntry(
      id: "6",
      title: "دھان / چاول بیج",
      titleUrdu: "دھان / چاول بیج",
      totalAmount: 9500,
      paidAmount: 9500,
      type: LedgerEntryType.expense,
      category: LedgerCategory.seed,
      cropName: "دھان / چاول (Rice)",
      date: DateTime.now().subtract(const Duration(days: 8)),
      note: "2 تھیلے بیج",
    ),
  ];

  void _openAddEntrySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddLedgerEntrySheet(
        isUrdu: _isUrdu,
        onAddEntry: (newEntry) {
          setState(() {
            _entries.insert(0, newEntry);
          });
        },
      ),
    );
  }

  void _openCropDetail(Map<String, dynamic> crop) {
    final filterKey = crop["filterKey"] as String;
    final cropEntries = _entries.where((e) => e.cropName.contains(filterKey)).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CropKhataDetailScreen(
          cropName: crop["name"],
          cropUrduName: crop["urduName"],
          icon: crop["icon"],
          themeColor: crop["color"],
          entries: cropEntries,
          isUrdu: _isUrdu,
          onAddEntry: (entry) {
            setState(() {
              _entries.insert(0, entry);
            });
          },
          onSettle: (item, collected, note) {
            setState(() {
              final idx = _entries.indexWhere((e) => e.id == item.id);
              if (idx != -1) {
                final curr = _entries[idx];
                final newHistory = List<PaymentHistoryItem>.from(curr.paymentHistory)
                  ..add(PaymentHistoryItem(amount: collected, date: DateTime.now(), note: note));
                _entries[idx] = curr.copyWith(
                  paidAmount: curr.paidAmount + collected,
                  paymentHistory: newHistory,
                );
              }
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isUrdu = _isUrdu;

    return ResponsiveLayout(
      child: Scaffold(
        backgroundColor: AppColors.background,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 74.0),
          child: SizedBox(
            height: 40,
            child: FloatingActionButton.extended(
              onPressed: _openAddEntrySheet,
              backgroundColor: AppColors.primaryDark,
              elevation: 2,
              icon: const Icon(Icons.add_rounded, color: AppColors.accentLime, size: 16),
              label: Text(
                isUrdu ? "نیا اندراج (+)" : "Add Entry (+)",
                style: isUrdu
                    ? AppTheme.urdu(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )
                    : AppTheme.english(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
              ),
            ),
          ),
        ),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Compact Header AppBar with Back Arrow and Centered Title
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.surface,
              elevation: 0,
              expandedHeight: 52,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark, size: 22),
                onPressed: () => Navigator.maybePop(context),
              ),
              title: Text(
                isUrdu ? "فصل وار کھاتہ" : "Crop-wise Khata",
                style: isUrdu
                    ? AppTheme.urdu(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      )
                    : AppTheme.english(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.download_rounded, size: 19, color: AppColors.primaryDark),
                  tooltip: isUrdu ? "رپورٹ" : "Report",
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isUrdu ? "کھاتہ رپورٹ محفوظ کر لی گئی ہے" : "Ledger report export ready",
                          style: const TextStyle(fontSize: 11),
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 4),
              ],
            ),

            // فصل وار کھاتہ (Crop-wise Grid & Analytics)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                child: _buildCropSectionHeader(isUrdu),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.15, // Compact square-ish ratio
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final crop = _cropTypes[index];
                    return _buildCropGridCard(crop, isUrdu);
                  },
                  childCount: _cropTypes.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- CROP SECTION HEADER ---
  Widget _buildCropSectionHeader(bool isUrdu) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isUrdu ? "فصل منتخب کریں" : "Select Crop",
          style: isUrdu
              ? AppTheme.urdu(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textDark)
              : AppTheme.english(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textDark),
        ),
        Text(
          "${_cropTypes.length} فصلیں",
          style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // --- CROP GRID CARD (COMPACT) ---
  Widget _buildCropGridCard(Map<String, dynamic> crop, bool isUrdu) {
    final String filterKey = crop["filterKey"];
    final Color color = crop["color"];
    final IconData icon = crop["icon"];
    final String urduName = crop["urduName"];
    final String tag = crop["tag"];

    final cropEntries = _entries.where((e) => e.cropName.contains(filterKey)).toList();
    final double income = cropEntries
        .where((e) => e.type == LedgerEntryType.income)
        .fold(0.0, (sum, e) => sum + e.paidAmount);
    final double expense = cropEntries
        .where((e) => e.type == LedgerEntryType.expense)
        .fold(0.0, (sum, e) => sum + e.paidAmount);
    final double net = income - expense;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 4,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openCropDetail(crop),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(9.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: color, size: 16),
                    ),
                    Text(
                      tag,
                      style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      urduName,
                      style: isUrdu
                          ? AppTheme.urdu(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textDark)
                          : const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    Text(
                      crop["name"],
                      style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: cropEntries.isEmpty
                        ? AppColors.surfaceVariant
                        : (net >= 0
                            ? AppColors.successGreen.withValues(alpha: 0.08)
                            : AppColors.alertSoftRed.withValues(alpha: 0.08)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        cropEntries.isEmpty
                            ? (isUrdu ? "کوئی ریکارڈ نہیں" : "No entries")
                            : (net >= 0 ? (isUrdu ? "+منافع" : "+Profit") : (isUrdu ? "-خرچہ" : "-Expense")),
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          color: cropEntries.isEmpty
                              ? AppColors.textMuted
                              : (net >= 0 ? AppColors.successGreen : AppColors.alertSoftRed),
                        ),
                      ),
                      if (cropEntries.isNotEmpty)
                        Text(
                          "Rs. ${_formatAmount(net.abs())}",
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: net >= 0 ? AppColors.successGreen : AppColors.alertSoftRed,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return "${(amount / 100000).toStringAsFixed(1)}L";
    }
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
