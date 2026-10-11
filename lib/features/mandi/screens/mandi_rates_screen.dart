import 'package:flutter/material.dart';
import '../../../core/localization/language_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../models/mandi_rate_item.dart';
import '../services/mandi_api_service.dart';

class MandiRatesScreen extends StatefulWidget {
  final bool? isUrdu;

  const MandiRatesScreen({super.key, this.isUrdu});

  @override
  State<MandiRatesScreen> createState() => _MandiRatesScreenState();
}

class _MandiRatesScreenState extends State<MandiRatesScreen> {
  final List<String> _majorCities = [
    "All Major Cities",
    "Lahore",
    "Multan",
    "Faisalabad",
    "Gujranwala",
    "Rawalpindi",
    "Sahiwal",
    "Sargodha",
    "Bahawalpur",
    "Hyderabad",
  ];

  String _selectedCity = "All Major Cities";
  CropCategory _selectedCategory = CropCategory.all;
  bool _govtOnlyFilter = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  bool _isLoading = true;
  List<MandiRateItem> _ratesList = [];
  String _lastSyncedTime = "9:00 AM";

  @override
  void initState() {
    super.initState();
    _loadMandiRates();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMandiRates({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
    });

    final now = DateTime.now();
    final timeStr =
        "${now.hour > 12 ? now.hour - 12 : now.hour}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";

    final data = await MandiApiService.fetchRates(
      city: _selectedCity,
      category: _selectedCategory,
      govtOnly: _govtOnlyFilter,
      forceRefresh: forceRefresh,
    );

    if (mounted) {
      setState(() {
        _ratesList = data;
        _isLoading = false;
        _lastSyncedTime = timeStr;
      });
      if (forceRefresh) {
        final isLive = MandiApiService.lastFetchWasLive;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isLive
                  ? (_isUrdu
                      ? "تازہ ترین لائیو منڈی ریٹس (AI) اپڈیٹ ہو چکے ہیں"
                      : "Fresh live mandi rates updated via Gemini AI")
                  : (_isUrdu
                      ? "آف لائن سرکاری تصدیق شدہ ریٹس لوڈ ہو گئے ہیں"
                      : "Loaded certified official government rates"),
              style: _isUrdu
                  ? AppTheme.urdu(fontSize: 11, color: Colors.white)
                  : AppTheme.english(fontSize: 11, color: Colors.white),
            ),
            backgroundColor: isLive ? AppColors.primaryDark : AppColors.textMuted,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  List<MandiRateItem> get _filteredRates {
    return _ratesList.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
          item.cropEnglish.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.cropUrdu.contains(_searchQuery) ||
          item.mandiCityEnglish.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.mandiCityUrdu.contains(_searchQuery);

      return matchesSearch;
    }).toList();
  }

  bool get _isUrdu => widget.isUrdu ?? LanguageController.instance.isUrdu;

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredRates;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                _isUrdu ? "سرکاری و منڈی نرخ" : "Live Mandi Rates",
                style: _isUrdu
                    ? AppTheme.urdu(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      )
                    : AppTheme.english(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
              ),
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: MandiApiService.lastFetchWasLive
                        ? AppColors.successGreen
                        : AppColors.accentGold,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    MandiApiService.lastFetchWasLive
                        ? (_isUrdu
                            ? "لائیو منڈی ریٹس (AI) • اپڈیٹ $_lastSyncedTime"
                            : "Live Mandi Rates (AI) • Updated $_lastSyncedTime")
                        : (_isUrdu
                            ? "سرکاری مصدقہ ریٹس • اپڈیٹ $_lastSyncedTime"
                            : "Official Certified Rates • Updated $_lastSyncedTime"),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _isUrdu
                        ? AppTheme.urdu(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          )
                        : AppTheme.english(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _loadMandiRates(forceRefresh: true),
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryDark),
            tooltip: _isUrdu ? "ریٹ ریفریش کریں" : "Refresh Rates",
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryDark,
        backgroundColor: AppColors.surface,
        onRefresh: () => _loadMandiRates(forceRefresh: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Input & City Dropdown
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val.trim();
                          });
                        },
                        style: _isUrdu
                            ? AppTheme.urdu(fontSize: 12, color: AppColors.textDark)
                            : AppTheme.english(fontSize: 13, color: AppColors.textDark),
                        decoration: InputDecoration(
                          hintText: _isUrdu ? "فصل یا جنس تلاش کریں..." : "Search crop or commodity...",
                          hintStyle: _isUrdu
                              ? AppTheme.urdu(fontSize: 11, color: AppColors.textLight)
                              : AppTheme.english(fontSize: 11, color: AppColors.textLight),
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: AppColors.textMuted, size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // City Dropdown
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCity,
                        icon: const Icon(Icons.location_on_rounded,
                            size: 16, color: AppColors.primaryDark),
                        style: AppTheme.english(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark),
                        items: _majorCities.map((city) {
                          String label = city;
                          if (city == "All Major Cities") {
                            label = _isUrdu ? "تمام شہر" : "All Cities";
                          }
                          return DropdownMenuItem(
                            value: city,
                            child: Text(
                              label,
                              overflow: TextOverflow.ellipsis,
                              style: _isUrdu ? AppTheme.urdu(fontSize: 11) : AppTheme.english(fontSize: 11),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedCity = val;
                            });
                            _loadMandiRates();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Government Official Price Filter Switch Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _govtOnlyFilter
                      ? AppColors.primaryDark
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _govtOnlyFilter
                        ? AppColors.primaryDark
                        : AppColors.borderLight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_rounded,
                          color: _govtOnlyFilter
                              ? AppColors.accentGold
                              : AppColors.primaryDark,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isUrdu ? "سرکاری امدادی اور کنٹرول نرخ" : "Govt. Support & Controlled Rates",
                              style: _isUrdu
                                  ? AppTheme.urdu(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: _govtOnlyFilter
                                          ? Colors.white
                                          : AppColors.textDark,
                                    )
                                  : AppTheme.english(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: _govtOnlyFilter
                                          ? Colors.white
                                          : AppColors.textDark,
                                    ),
                            ),
                            Text(
                              _isUrdu ? "حکومتی نوٹیفائیڈ قیمتیں" : "Official Government Notified Benchmarks",
                              style: _isUrdu
                                  ? AppTheme.urdu(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w500,
                                      color: _govtOnlyFilter
                                          ? AppColors.accentLime
                                          : AppColors.textMuted,
                                    )
                                  : AppTheme.english(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: _govtOnlyFilter
                                          ? AppColors.accentLime
                                          : AppColors.textMuted,
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Switch(
                      value: _govtOnlyFilter,
                      activeThumbColor: AppColors.accentGold,
                      activeTrackColor: AppColors.primaryMedium,
                      onChanged: (val) {
                        setState(() {
                          _govtOnlyFilter = val;
                        });
                        _loadMandiRates();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Category Filter Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryPill(
                      labelEnglish: "All",
                      labelUrdu: "تمام",
                      category: CropCategory.all,
                    ),
                    const SizedBox(width: 8),
                    _buildCategoryPill(
                      labelEnglish: "Grains",
                      labelUrdu: "غلہ",
                      category: CropCategory.grains,
                    ),
                    const SizedBox(width: 8),
                    _buildCategoryPill(
                      labelEnglish: "Cash Crops",
                      labelUrdu: "نقد آور",
                      category: CropCategory.cashCrops,
                    ),
                    const SizedBox(width: 8),
                    _buildCategoryPill(
                      labelEnglish: "Fertilizers",
                      labelUrdu: "کھادیں",
                      category: CropCategory.fertilizers,
                    ),
                    const SizedBox(width: 8),
                    _buildCategoryPill(
                      labelEnglish: "Vegetables",
                      labelUrdu: "سبزیاں",
                      category: CropCategory.vegetables,
                    ),
                    const SizedBox(width: 8),
                    _buildCategoryPill(
                      labelEnglish: "Oilseeds",
                      labelUrdu: "تیل دار",
                      category: CropCategory.oilseeds,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Loading or Content
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(color: AppColors.primaryDark),
                  ),
                )
              else if (filteredList.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        const Icon(Icons.search_off_rounded,
                            size: 44, color: AppColors.textLight),
                        const SizedBox(height: 8),
                        Text(
                          _isUrdu ? "کوئی منڈی ریٹ نہیں ملا" : "No Mandi Rates Found",
                          style: _isUrdu
                              ? AppTheme.urdu(fontSize: 13, fontWeight: FontWeight.w700)
                              : AppTheme.english(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          _isUrdu ? "براہ کرم سرچ فلٹر بدل کر دوبارہ کوشش کریں" : "Try adjusting your search query or city filter",
                          style: _isUrdu
                              ? AppTheme.urdu(fontSize: 11, color: AppColors.textMuted)
                              : AppTheme.english(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  itemCount: filteredList.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = filteredList[index];
                    return _buildGovtMandiRateCard(item);
                  },
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPill({
    required String labelEnglish,
    required String labelUrdu,
    required CropCategory category,
  }) {
    final bool isSelected = _selectedCategory == category;
    final label = _isUrdu ? labelUrdu : labelEnglish;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
        _loadMandiRates();
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDark : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryDark : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: _isUrdu
              ? AppTheme.urdu(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.textDark,
                )
              : AppTheme.english(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.textDark,
                ),
        ),
      ),
    );
  }

  Widget _buildGovtMandiRateCard(MandiRateItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: item.isGovtNotified
            ? Border.all(color: AppColors.primaryMedium.withValues(alpha: 0.35), width: 1.2)
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Govt Notified Tag (if applicable)
          if (item.isGovtNotified) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_rounded,
                          color: AppColors.accentGold, size: 12),
                      const SizedBox(width: 5),
                      Text(
                        _isUrdu ? "سرکاری ریٹ" : "Govt. Official Rate",
                        style: _isUrdu
                            ? AppTheme.urdu(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              )
                            : AppTheme.english(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _isUrdu ? item.mandiCityUrdu : item.mandiCityEnglish,
                  style: _isUrdu
                      ? AppTheme.urdu(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryMedium,
                        )
                      : AppTheme.english(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryMedium,
                        ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],

          // Crop Name + City & Trend Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                ),
                child: Icon(item.icon, color: AppColors.primaryDark, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isUrdu ? item.cropUrdu : item.cropEnglish,
                      overflow: TextOverflow.ellipsis,
                      style: _isUrdu
                          ? AppTheme.urdu(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            )
                          : AppTheme.english(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 2),
                        Text(
                          _isUrdu ? item.mandiCityUrdu : item.mandiCityEnglish,
                          style: _isUrdu
                              ? AppTheme.urdu(
                                  fontSize: 10,
                                  color: AppColors.textMuted,
                                )
                              : AppTheme.english(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Up/Down Trend Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: item.changePercentage == 0
                      ? AppColors.surfaceAlt
                      : item.isUp
                          ? AppColors.successGreen.withValues(alpha: 0.12)
                          : AppColors.alertSoftRed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    if (item.changePercentage != 0)
                      Icon(
                        item.isUp
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        size: 13,
                        color: item.isUp
                            ? AppColors.successGreen
                            : AppColors.alertSoftRed,
                      ),
                    const SizedBox(width: 2),
                    Text(
                      item.changePercentage == 0
                          ? (_isUrdu ? "مستحکم" : "Stable")
                          : "${item.isUp ? '+' : ''}${item.changePercentage}%",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: item.changePercentage == 0
                            ? AppColors.textMuted
                            : item.isUp
                                ? AppColors.successGreen
                                : AppColors.alertSoftRed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Price Details Grid (Min, Avg / Govt Benchmark, Max)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPriceColumn(
                  title: _isUrdu ? "کم از کم" : "Min",
                  price: "Rs. ${item.minRate.toInt()}",
                  color: AppColors.textMuted,
                ),
                Container(width: 1, height: 28, color: AppColors.borderLight),
                _buildPriceColumn(
                  title: item.isGovtNotified
                      ? (_isUrdu ? "سرکاری ریٹ" : "Govt Rate")
                      : (_isUrdu ? "اوسط ریٹ" : "Average"),
                  price: "Rs. ${(item.isGovtNotified && item.govtRate > 0 ? item.govtRate : item.avgRate).toInt()}",
                  color: AppColors.primaryDark,
                  isBold: true,
                ),
                Container(width: 1, height: 28, color: AppColors.borderLight),
                _buildPriceColumn(
                  title: _isUrdu ? "زیادہ سے زیادہ" : "Max",
                  price: "Rs. ${item.maxRate.toInt()}",
                  color: AppColors.successGreen,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Notification authority note & unit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isUrdu ? item.govtNotificationRef : (item.isGovtNotified ? "Govt. Approved Rate" : "Local Market Rate"),
                style: _isUrdu
                    ? AppTheme.urdu(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryMedium,
                      )
                    : AppTheme.english(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryMedium,
                      ),
              ),
              Text(
                _isUrdu ? item.unitUrdu : item.unitEnglish,
                style: _isUrdu
                    ? AppTheme.urdu(fontSize: 9.5, color: AppColors.textLight)
                    : AppTheme.english(fontSize: 10, color: AppColors.textLight),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceColumn({
    required String title,
    required String price,
    required Color color,
    bool isBold = false,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: _isUrdu
              ? AppTheme.urdu(fontSize: 9, color: AppColors.textMuted)
              : AppTheme.english(fontSize: 9, color: AppColors.textMuted),
        ),
        const SizedBox(height: 4),
        Text(
          price,
          style: TextStyle(
            fontSize: isBold ? 14 : 12,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
