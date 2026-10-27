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
      "tagEnglish": "Rabi Season",
      "icon": Icons.grass_rounded,
      "color": Color(0xFFE5A93C),
      "filterKey": "گندم",
    },
    {
      "name": "Cotton",
      "urduName": "کپاس",
      "tag": "خریف فصل (سلور)",
      "tagEnglish": "Kharif Season",
      "icon": Icons.cloud_rounded,
      "color": Color(0xFF00897B),
      "filterKey": "کپاس",
    },
    {
      "name": "Rice",
      "urduName": "دھان / چاول",
      "tag": "خریف فصل (مونجی)",
      "tagEnglish": "Paddy Season",
      "icon": Icons.water_drop_rounded,
      "color": Color(0xFF2E7D32),
      "filterKey": "دھان",
    },
    {
      "name": "Maize",
      "urduName": "مکئی",
      "tag": "بہاریہ و خریف",
      "tagEnglish": "Spring & Autumn",
      "icon": Icons.eco_rounded,
      "color": Color(0xFFEF6C00),
      "filterKey": "مکئی",
    },
    {
      "name": "Sugarcane",
      "urduName": "کماد / گنا",
      "tag": "سالانہ نقد آور",
      "tagEnglish": "Cash Crop",
      "icon": Icons.forest_rounded,
      "color": Color(0xFF388E3C),
      "filterKey": "گنا",
    },
    {
      "name": "Vegetables",
      "urduName": "باغ و سبزیاں",
      "tag": "موسمی پیداوار",
      "tagEnglish": "Orchard & Veg",
      "icon": Icons.local_florist_rounded,
      "color": Color(0xFF0288D1),
      "filterKey": "سبزیاں",
    },
  ];

  final List<LedgerEntry> _entries = [
    LedgerEntry(
      id: "1",
      title: "Wheat Grain Harvest Sale",
      titleUrdu: "گندم فصل فروخت (غلہ منڈی)",
      totalAmount: 60000,
      paidAmount: 30000,
      type: LedgerEntryType.income,
      category: LedgerCategory.cropSale,
      cropName: "Wheat",
      date: DateTime.now().subtract(const Duration(hours: 3)),
      note: "نصف رقم وصول ہوئی، 30 ہزار باقی",
    ),
    LedgerEntry(
      id: "2",
      title: "Sona Urea Fertilizer (3 Bags)",
      titleUrdu: "یوریا سونا کھاد ۳ بوری",
      totalAmount: 14400,
      paidAmount: 14400,
      type: LedgerEntryType.expense,
      category: LedgerCategory.fertilizer,
      cropName: "Wheat",
      date: DateTime.now().subtract(const Duration(days: 1)),
      note: "مکمل نقد ادا",
    ),
    LedgerEntry(
      id: "3",
      title: "Raw Cotton Phutti Sale (15 Maund)",
      titleUrdu: "کپاس پھٹی فروخت (۱۵ من)",
      totalAmount: 127500,
      paidAmount: 100000,
      type: LedgerEntryType.income,
      category: LedgerCategory.cropSale,
      cropName: "Cotton",
      date: DateTime.now().subtract(const Duration(days: 3)),
      note: "27,500 بقایا بیلنس",
    ),
    LedgerEntry(
      id: "4",
      title: "Tubewell Diesel Fuel (50L)",
      titleUrdu: "ٹیوب ویل ڈیزل ۵۰ لیٹر",
      totalAmount: 13750,
      paidAmount: 13750,
      type: LedgerEntryType.expense,
      category: LedgerCategory.diesel,
      cropName: "Cotton",
      date: DateTime.now().subtract(const Duration(days: 4)),
      note: "پہلا پانی لگایا",
    ),
    LedgerEntry(
      id: "5",
      title: "Pesticide Insect Spray",
      titleUrdu: "کیڑے مار اسپرے",
      totalAmount: 7800,
      paidAmount: 4000,
      type: LedgerEntryType.expense,
      category: LedgerCategory.spray,
      cropName: "Cotton",
      date: DateTime.now().subtract(const Duration(days: 5)),
      note: "3800 روپے ادھار بقایا",
    ),
    LedgerEntry(
      id: "6",
      title: "Rice / Paddy Certified Seeds",
      titleUrdu: "دھان / چاول بیج",
      totalAmount: 9500,
      paidAmount: 9500,
      type: LedgerEntryType.expense,
      category: LedgerCategory.seed,
      cropName: "Rice",
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
    final englishName = crop["name"] as String;
    final cropEntries = _entries.where((e) =>
      e.cropName.contains(filterKey) ||
      e.cropName.toLowerCase().contains(englishName.toLowerCase()) ||
      e.title.toLowerCase().contains(englishName.toLowerCase()) ||
      e.titleUrdu.contains(filterKey)
    ).toList();

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
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final double headerHeight = isLandscape ? 40 : 46;

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
              pinned: !isLandscape,
              floating: isLandscape,
              snap: isLandscape,
              toolbarHeight: headerHeight,
              backgroundColor: AppColors.surface,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              leading: Navigator.canPop(context)
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark, size: 20),
                      onPressed: () => Navigator.maybePop(context),
                    )
                  : null,
              automaticallyImplyLeading: false,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                  color: AppColors.borderLight.withValues(alpha: 0.7),
                  height: 1,
                ),
              ),
              title: Text(
                isUrdu ? "فصل وار کھاتہ" : "Crop-wise Ledger",
                style: isUrdu
                    ? AppTheme.urdu(
                        fontSize: isLandscape ? 14 : 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      )
                    : AppTheme.english(
                        fontSize: isLandscape ? 14 : 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.download_rounded, size: 18, color: AppColors.primaryDark),
                  tooltip: isUrdu ? "رپورٹ محفوظ کریں" : "Export Report",
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isUrdu ? "کھاتہ رپورٹ محفوظ کر لی گئی ہے" : "Ledger report exported successfully",
                          style: isUrdu ? AppTheme.urdu(fontSize: 11, color: Colors.white) : null,
                        ),
                        backgroundColor: AppColors.primaryDark,
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
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.86,
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
              ? AppTheme.urdu(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textDark)
              : AppTheme.english(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark),
        ),
        Text(
          isUrdu ? "${_cropTypes.length} فصلیں" : "${_cropTypes.length} Crops",
          style: AppTheme.english(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // --- CROP GRID CARD (3 IN 1 ROW - CLEAN, PROPER ICON & ADAPTIVE LANGUAGE) ---
  Widget _buildCropGridCard(Map<String, dynamic> crop, bool isUrdu) {
    final Color color = crop["color"] as Color;
    final IconData icon = crop["icon"] as IconData;
    final String urduName = crop["urduName"] as String;
    final String englishName = crop["name"] as String;
    final String tag = isUrdu ? (crop["tag"] as String) : (crop["tagEnglish"] as String);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLight.withValues(alpha: 0.85),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.035),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openCropDetail(crop),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Proper Crop Icon Container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withValues(alpha: 0.28),
                      width: 1.2,
                    ),
                  ),
                  child: Center(
                    child: Icon(icon, color: color, size: 24),
                  ),
                ),
                SizedBox(height: isUrdu ? 6 : 7),

                // 2. Primary Crop Name (Pure Urdu in Urdu mode, Pure English in English mode)
                Text(
                  isUrdu ? urduName : englishName,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: isUrdu
                      ? AppTheme.urdu(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                          height: 1.85,
                        )
                      : AppTheme.english(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                ),
                SizedBox(height: isUrdu ? 4 : 2),

                // 3. Subtitle (English crop name in Urdu mode; Category/Season in English mode)
                Text(
                  isUrdu ? englishName : tag,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.english(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
