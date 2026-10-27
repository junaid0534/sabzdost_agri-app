import 'package:flutter/material.dart';
import '../../../core/localization/language_controller.dart';
import '../../../core/services/gemini_smart_input_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gemini_smart_search_bar.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../doctor/screens/crop_doctor_screen.dart';
import '../../ledger/screens/farm_ledger_screen.dart';
import '../../machinery/screens/machinery_category_screen.dart';
import '../../machinery/screens/machinery_dashboard_screen.dart';
import '../../mandi/screens/mandi_rates_screen.dart';
import '../../weather/models/weather_models.dart';
import '../../weather/screens/agri_weather_screen.dart';
import '../../weather/services/weather_service.dart';
import '../../store/models/agri_product_model.dart';
import '../../store/screens/agri_store_screen.dart';
import 'farmer_settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  final int initialIndex;
  const DashboardScreen({super.key, this.initialIndex = 0});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late int _selectedBottomNav;
  bool get _isUrdu => LanguageController.instance.isUrdu;
  AgriWeatherReport? _liveWeather;

  @override
  void initState() {
    super.initState();
    _selectedBottomNav = widget.initialIndex;
    _fetchDashboardWeather();
  }

  Future<void> _fetchDashboardWeather() async {
    final report = await WeatherService.fetchWeather();
    if (mounted) {
      setState(() {
        _liveWeather = report;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageController.instance,
      builder: (context, _) {
        return ResponsiveLayout(
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: IndexedStack(
              index: _selectedBottomNav,
              children: [
                _buildHomeView(),
                CropDoctorScreen(isUrdu: _isUrdu),
                FarmLedgerScreen(
                  isUrdu: _isUrdu,
                  showTopModeSwitcher: false,
                ),
                MandiRatesScreen(isUrdu: _isUrdu),
                FarmerSettingsScreen(isUrdu: _isUrdu),
              ],
            ),
            bottomNavigationBar: _buildFloatingBottomNav(),
          ),
        );
      },
    );
  }

  // --- FLOATING MODERN BOTTOM NAV (Matches Reference Mockup) ---
  Widget _buildFloatingBottomNav() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 16, top: 4),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(34),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              index: 0,
              icon: Icons.home_rounded,
              label: _isUrdu ? "ہوم" : "Home",
            ),
            _buildNavItem(
              index: 1,
              icon: Icons.psychology_rounded,
              label: _isUrdu ? "ڈاکٹر" : "Doctor",
            ),
            _buildNavItem(
              index: 2,
              icon: Icons.menu_book_rounded,
              label: _isUrdu ? "کھاتہ" : "Khata",
            ),
            _buildNavItem(
              index: 3,
              icon: Icons.trending_up_rounded,
              label: _isUrdu ? "منڈی" : "Mandi",
            ),
            _buildNavItem(
              index: 4,
              icon: Icons.settings_rounded,
              label: _isUrdu ? "سیٹنگز" : "Settings",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected = _selectedBottomNav == index;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedBottomNav = index;
        });
      },
      borderRadius: BorderRadius.circular(26),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 12 : 8,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDark : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isSelected ? 24 : 23,
              color: isSelected ? Colors.white : AppColors.textLight,
            ),
            if (isSelected) ...[
              const SizedBox(width: 5),
              Text(
                label,
                style: _isUrdu
                    ? AppTheme.urdu(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      )
                    : AppTheme.english(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- HOME VIEW ---
  Widget _buildHomeView() {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: isLandscape ? 8 : 12,
          bottom: 90,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TOP HEADER (Shrunk in landscape for maximum screen visibility)
            _buildTopHeader(),
            SizedBox(height: isLandscape ? 8 : 14),

            // 1.5 GEMINI SMART AGRI SEARCH BAR (Autocorrects Roman Urdu & Typos)
            _buildHomeGeminiSearchBar(),
            SizedBox(height: isLandscape ? 10 : 16),

            // 2. HERO VISUAL BANNER (Modern Climate Card)
            _buildHeroVisualBanner(),
            SizedBox(height: isLandscape ? 12 : 18),

            // 3. 4x2 QUICK NAVIGATION (8 Shortcuts: Khata, Doctor, Mandi, Machinery, Seeds, Fertilizer, Sprays, Settings)
            _buildFourMenuGrid(),
            SizedBox(height: isLandscape ? 14 : 20),

            // 4. AI CROP DOCTOR SCAN BANNER
            _buildAiDoctorCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _handleHomeSearch(String query, SmartCorrectionResult? aiResult) {
    if (query.trim().isEmpty) return;

    final q = query.toLowerCase().trim();
    final intent = aiResult?.detectedIntent.toLowerCase() ?? "";

    // Check intent or query keywords
    final isMachinery = intent.contains("machinery") ||
        intent.contains("tractor") ||
        q.contains("tractor") ||
        q.contains("taractor") ||
        q.contains("harvester") ||
        q.contains("laser") ||
        q.contains("kiraya") ||
        q.contains("drone") ||
        q.contains("thresher") ||
        q.contains("baler");

    final isStore = intent.contains("store") ||
        intent.contains("seed") ||
        intent.contains("fertilizer") ||
        q.contains("seed") ||
        q.contains("beej") ||
        q.contains("khad") ||
        q.contains("urea") ||
        q.contains("dap") ||
        q.contains("potash") ||
        q.contains("pesticide");

    final isDoctor = intent.contains("doctor") ||
        intent.contains("disease") ||
        q.contains("keera") ||
        q.contains("bimar") ||
        q.contains("patta") ||
        q.contains("fungus") ||
        q.contains("sundi");

    final isKhata = intent.contains("ledger") ||
        intent.contains("khata") ||
        q.contains("khata") ||
        q.contains("udhar") ||
        q.contains("wasooli") ||
        q.contains("hisab");

    if (isStore) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AgriStoreScreen(
            isUrdu: _isUrdu,
            initialCategory: (q.contains("seed") || q.contains("beej"))
                ? AgriProductCategory.seeds
                : (q.contains("khad") || q.contains("urea") || q.contains("dap"))
                    ? AgriProductCategory.fertilizers
                    : (q.contains("spray") || q.contains("pesticide"))
                        ? AgriProductCategory.sprays
                        : AgriProductCategory.all,
          ),
        ),
      );
    } else if (isMachinery) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MachineryDashboardScreen(
            isUrdu: _isUrdu,
            initialSearch: aiResult != null && aiResult.correctedUrdu.isNotEmpty
                ? aiResult.correctedUrdu
                : query,
          ),
        ),
      );
    } else if (isDoctor) {
      setState(() {
        _selectedBottomNav = 1; // Doctor Tab
      });
    } else if (isKhata) {
      setState(() {
        _selectedBottomNav = 2; // Khata Tab
      });
    } else {
      // Default to Mandi Rates Tab
      setState(() {
        _selectedBottomNav = 3; // Mandi Tab
      });
    }
  }

  // --- GEMINI SMART AGRI SEARCH BAR (Roman Urdu & Typo Autocorrect) ---
  Widget _buildHomeGeminiSearchBar() {
    return GeminiSmartSearchBar(
      domainContext:
          "Pakistan agriculture, mandi rates, machinery rental, tractor, harvester, laser leveler, crop diseases, fertilizers, spray",
      hintText: _isUrdu ? "فصل، مشین، منڈی تلاش..." : "Search crops, machines...",
      onSubmitted: _handleHomeSearch,
    );
  }

  // --- TOP HEADER (Adaptive & Shrinks in Landscape) ---
  Widget _buildTopHeader() {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final double iconBoxSize = isLandscape ? 36 : 44;
    final double innerIconSize = isLandscape ? 20 : 24;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: SabzDost Brand Icon + Title & Tagline
        Expanded(
          child: Row(
            children: [
              Container(
                width: iconBoxSize,
                height: iconBoxSize,
                decoration: BoxDecoration(
                  gradient: AppColors.greenGradient,
                  borderRadius: BorderRadius.circular(isLandscape ? 10 : 13),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withValues(alpha: 0.16),
                      blurRadius: isLandscape ? 6 : 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.eco_rounded,
                    color: AppColors.accentLime,
                    size: innerIconSize,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isUrdu)
                      Text(
                        "سبز دوست",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.urdu(
                          fontSize: isLandscape ? 15.5 : 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryDark,
                        ),
                      )
                    else
                      RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Sabz",
                              style: AppTheme.english(
                                fontSize: isLandscape ? 15.5 : 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryDark,
                                letterSpacing: -0.4,
                              ),
                            ),
                            TextSpan(
                              text: "Dost",
                              style: AppTheme.english(
                                fontSize: isLandscape ? 15.5 : 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryLight,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (!isLandscape) ...[
                      const SizedBox(height: 2),
                      Text(
                        _isUrdu ? "کسان کا ڈیجیٹل ساتھی" : "Smart Kisan Companion",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _isUrdu
                            ? AppTheme.urdu(
                                fontSize: 10.5,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                              )
                            : AppTheme.english(
                                fontSize: 10.5,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Language Switcher Toggle Pill [اردو | EN]
        InkWell(
          onTap: () {
            LanguageController.instance.toggleLanguage();
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isLandscape ? 8 : 10,
              vertical: isLandscape ? 4 : 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.translate_rounded,
                  size: isLandscape ? 12 : 14,
                  color: AppColors.primaryMedium,
                ),
                const SizedBox(width: 4),
                Text(
                  _isUrdu ? "English" : "اردو",
                  style: TextStyle(
                    fontSize: isLandscape ? 10 : 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Notification Bell Icon Button
        Container(
          width: isLandscape ? 36 : 44,
          height: isLandscape ? 36 : 44,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.06),
                blurRadius: isLandscape ? 6 : 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                color: AppColors.textDark,
                size: isLandscape ? 18 : 22,
              ),
              Positioned(
                top: isLandscape ? 8 : 11,
                right: isLandscape ? 9 : 12,
                child: Container(
                  width: isLandscape ? 6 : 7,
                  height: isLandscape ? 6 : 7,
                  decoration: const BoxDecoration(
                    color: AppColors.alertSoftRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- HERO VISUAL BANNER (Adaptive Climate Card) ---
  Widget _buildHeroVisualBanner() {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final cityName = _isUrdu
        ? (_liveWeather?.city.nameUrdu ?? 'ملتان')
        : (_liveWeather?.city.nameEnglish ?? 'Multan');
    final temp = _liveWeather?.current.temperature.round() ?? 28;
    final condition = _isUrdu
        ? (_liveWeather?.current.conditionUrdu ?? 'جزوی ابر آلود')
        : (_liveWeather?.current.conditionEnglish ?? 'Partly Cloudy');
    final humidity = _liveWeather?.current.humidity ?? 45;
    final windSpeed = _liveWeather?.current.windSpeed.round() ?? 12;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: AppColors.freshLeafGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryMedium.withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AgriWeatherScreen(isUrdu: _isUrdu),
              ),
            ).then((_) => _fetchDashboardWeather());
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isLandscape ? 18 : 20,
              vertical: isLandscape ? 12 : 18,
            ),
            child: Directionality(
              textDirection: _isUrdu ? TextDirection.rtl : TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --- LEFT: Location, Big Temp, Weather Condition ---
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Location row
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 13,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                cityName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _isUrdu
                                    ? AppTheme.urdu(
                                        fontSize: isLandscape ? 11.5 : 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withValues(alpha: 0.95),
                                      )
                                    : AppTheme.english(
                                        fontSize: isLandscape ? 11.5 : 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withValues(alpha: 0.95),
                                      ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),

                        // Big Temperature
                        Text(
                          "$temp°C",
                          style: TextStyle(
                            fontSize: isLandscape ? 28 : 36,
                            height: 1.15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),

                        // Weather Condition
                        Text(
                          condition,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _isUrdu
                              ? AppTheme.urdu(
                                  fontSize: isLandscape ? 11.5 : 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.95),
                                )
                              : AppTheme.english(
                                  fontSize: isLandscape ? 11.5 : 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.95),
                                ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 14),

                  // --- RIGHT: Compact Frosted Glass Metrics Box ---
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLandscape ? 12 : 16,
                      vertical: isLandscape ? 8 : 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.20),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1: Water drop + Humidity %
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.water_drop_outlined,
                              size: 15,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "$humidity%",
                              style: TextStyle(
                                fontSize: isLandscape ? 12 : 13.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isLandscape ? 4 : 7),

                        // Row 2: Wind + Wind speed km/h
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.air_rounded,
                              size: 15,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "$windSpeed km/h",
                              style: TextStyle(
                                fontSize: isLandscape ? 12 : 13.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- 4 QUICK ACTIONS IN 1 HORIZONTAL ROW ---
  // --- 4 QUICK ACTIONS IN 1 HORIZONTAL ROW (Square Cards, No Subtitles) ---
  Widget _buildFourMenuGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _isUrdu ? "فوری سہولیات" : "Quick Actions",
              style: _isUrdu
                  ? AppTheme.urdu(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    )
                  : AppTheme.english(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
            ),
            Text(
              _isUrdu ? "8 اہم مینیو" : "8 Shortcuts",
              style: _isUrdu
                  ? AppTheme.urdu(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryMedium,
                    )
                  : AppTheme.english(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryMedium,
                    ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // ROW 1: 4 FARMER TOOLS
        Row(
          children: [
            // 1. فصل کھاتہ (Crop Khata)
            Expanded(
              child: _buildSingleRowActionItem(
                title: _isUrdu ? "فصل کھاتہ" : "Crop Khata",
                icon: Icons.grass_rounded,
                iconColor: const Color(0xFF257538),
                bgColor: const Color(0xFFE8F5E9),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FarmLedgerScreen(
                        isUrdu: _isUrdu,
                        showTopModeSwitcher: false,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),

            // 2. زرعی ڈاکٹر (AI Crop Doctor)
            Expanded(
              child: _buildSingleRowActionItem(
                title: _isUrdu ? "فصل ڈاکٹر" : "AI Doctor",
                icon: Icons.camera_alt_rounded,
                iconColor: const Color(0xFF00838F),
                bgColor: const Color(0xFFE0F7FA),
                onTap: () {
                  setState(() {
                    _selectedBottomNav = 1; // Doctor Tab
                  });
                },
              ),
            ),
            const SizedBox(width: 8),

            // 3. منڈی ریٹس (Live Mandi Rates)
            Expanded(
              child: _buildSingleRowActionItem(
                title: _isUrdu ? "منڈی ریٹس" : "Mandi Rates",
                icon: Icons.trending_up_rounded,
                iconColor: const Color(0xFFC2185B),
                bgColor: const Color(0xFFFCE4EC),
                onTap: () {
                  setState(() {
                    _selectedBottomNav = 3; // Mandi Tab
                  });
                },
              ),
            ),
            const SizedBox(width: 8),

            // 4. زرعی مشینری (Machinery)
            Expanded(
              child: _buildSingleRowActionItem(
                title: _isUrdu ? "زرعی مشینری" : "Machinery",
                icon: Icons.agriculture_rounded,
                iconColor: const Color(0xFFE65100),
                bgColor: const Color(0xFFFFF3E0),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MachineryCategoryScreen(
                        isUrdu: _isUrdu,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // ROW 2: 4 AGRI STORE INPUTS & SETTINGS (بیج، کھاد، سپرے، سیٹنگز)
        Row(
          children: [
            // 5. بیج (Seeds)
            Expanded(
              child: _buildSingleRowActionItem(
                title: _isUrdu ? "بیج" : "Seeds",
                icon: Icons.spa_rounded,
                iconColor: const Color(0xFF2E7D32),
                bgColor: const Color(0xFFE8F5E9),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AgriStoreScreen(
                        isUrdu: _isUrdu,
                        initialCategory: AgriProductCategory.seeds,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),

            // 6. کھادیں (Fertilizers)
            Expanded(
              child: _buildSingleRowActionItem(
                title: _isUrdu ? "کھاد" : "Fertilizers",
                icon: Icons.science_rounded,
                iconColor: const Color(0xFF00838F),
                bgColor: const Color(0xFFE0F7FA),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AgriStoreScreen(
                        isUrdu: _isUrdu,
                        initialCategory: AgriProductCategory.fertilizers,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),

            // 7. سپرے و زہریں (Sprays)
            Expanded(
              child: _buildSingleRowActionItem(
                title: _isUrdu ? "سپرے" : "Sprays",
                icon: Icons.sanitizer_rounded,
                iconColor: const Color(0xFFE65100),
                bgColor: const Color(0xFFFFF3E0),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AgriStoreScreen(
                        isUrdu: _isUrdu,
                        initialCategory: AgriProductCategory.sprays,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),

            // 8. سیٹنگز (Settings)
            Expanded(
              child: _buildSingleRowActionItem(
                title: _isUrdu ? "سیٹنگز" : "Settings",
                icon: Icons.settings_rounded,
                iconColor: const Color(0xFF37474F),
                bgColor: const Color(0xFFECEFF1),
                onTap: () {
                  setState(() {
                    _selectedBottomNav = 4; // Settings Tab
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Modern Normal-Sized Quick-Action Card (Fixed compact height in both portrait & landscape)
  Widget _buildSingleRowActionItem({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 82,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.7)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 21),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: _isUrdu
                    ? AppTheme.urdu(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      )
                    : AppTheme.english(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
              ),
            ],
          ),
        ),
      );
  }

  // --- AI CROP DOCTOR SCAN BANNER ---
  Widget _buildAiDoctorCard() {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedBottomNav = 1; // Go to AI Doctor Tab
        });
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          gradient: AppColors.greenGradient,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.20),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Directionality(
          textDirection: _isUrdu ? TextDirection.rtl : TextDirection.ltr,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome, size: 12, color: Color(0xFF1B4332)),
                          const SizedBox(width: 5),
                          Text(
                            _isUrdu ? "جدید اے آئی ویژن" : "Smart AI Vision Scan",
                            style: _isUrdu
                                ? AppTheme.urdu(
                                    color: const Color(0xFF1B4332),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  )
                                : AppTheme.english(
                                    color: const Color(0xFF1B4332),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isUrdu ? "فصل کی بیماری کی فوری تشخیص" : "Scan Crop Leaf Disease",
                      style: _isUrdu
                          ? AppTheme.urdu(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            )
                          : AppTheme.english(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _isUrdu
                          ? "پتے کی تصویر لیں اور مستند اسپرے علاج پائیں"
                          : "Snap photo for instant diagnosis & certified spray guide",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _isUrdu
                          ? AppTheme.urdu(
                              fontSize: 10.5,
                              color: Colors.white.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w500,
                            )
                          : AppTheme.english(
                              fontSize: 10.5,
                              color: Colors.white.withValues(alpha: 0.82),
                              fontWeight: FontWeight.w500,
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Elevated camera shutter trigger button
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.primaryMedium,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
