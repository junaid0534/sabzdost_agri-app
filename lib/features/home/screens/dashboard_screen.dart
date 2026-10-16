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
import '../../mandi/models/mandi_rate_item.dart';
import '../../mandi/screens/mandi_rates_screen.dart';
import '../../mandi/services/mandi_api_service.dart';
import '../../weather/models/weather_models.dart';
import '../../weather/screens/agri_weather_screen.dart';
import '../../weather/services/weather_service.dart';
import '../../store/models/agri_product_model.dart';
import '../../store/screens/agri_store_screen.dart';

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
  List<MandiRateItem> _topMandiRates = [];
  String? _nearbyMandiCity;
  String? _nearbyMandiCityUrdu;
  bool _isFetchingMandi = false;

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
        _nearbyMandiCity = report.city.nameEnglish;
        _nearbyMandiCityUrdu = report.city.nameUrdu;
      });
      _fetchDashboardMandiRates(city: report.city.nameEnglish);
    }
  }

  Future<void> _fetchDashboardMandiRates({String? city}) async {
    if (_isFetchingMandi) return;
    _isFetchingMandi = true;
    try {
      final targetCity = (city != null && city.isNotEmpty)
          ? city
          : (_nearbyMandiCity ??
              (WeatherService.currentCity.nameEnglish.isNotEmpty
                  ? WeatherService.currentCity.nameEnglish
                  : "Punjab"));
      final rates = await MandiApiService.fetchRates(city: targetCity);
      if (mounted && rates.isNotEmpty) {
        setState(() {
          _topMandiRates = rates.take(4).toList();
          _nearbyMandiCity = targetCity;
          if (_liveWeather != null && _liveWeather!.city.nameEnglish == targetCity) {
            _nearbyMandiCityUrdu = _liveWeather!.city.nameUrdu;
          } else {
            _nearbyMandiCityUrdu = WeatherService.currentCity.nameUrdu;
          }
        });
      }
    } catch (_) {
    } finally {
      _isFetchingMandi = false;
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
      padding: const EdgeInsets.only(left: 18, right: 18, bottom: 16, top: 4),
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
          horizontal: isSelected ? 16 : 10,
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
              size: 22,
              color: isSelected ? Colors.white : AppColors.textLight,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
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
                        fontSize: 12,
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

            // 3. 4-MENU QUICK NAVIGATION (Crop Khata, AI Doctor, Mandi, Machinery)
            _buildFourMenuGrid(),
            SizedBox(height: isLandscape ? 14 : 20),

            // 4. AI CROP DOCTOR SCAN BANNER
            _buildAiDoctorCard(),
            SizedBox(height: isLandscape ? 14 : 20),

            // 5. LIVE MANDI PRICE HIGHLIGHTS (Real-time Mandi Rates)
            _buildLiveMandiSection(),
            SizedBox(height: isLandscape ? 14 : 20),

            // 6. FARM LEDGER & AGRI ADVISORY SPOTLIGHT
            _buildAgriAdvisoryAndKhataSection(),
            const SizedBox(height: 16),
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
              _isUrdu ? "7 اہم مینیو" : "7 Shortcuts",
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

        // ROW 2: 3 AGRI STORE INPUTS (بیج، کھاد، سپرے)
        Row(
          children: [
            // 5. بیج (Seeds)
            Expanded(
              child: _buildSingleRowActionItem(
                title: _isUrdu ? "بیج (Seeds)" : "Seeds",
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
                title: _isUrdu ? "کھاد (Fertilizer)" : "Fertilizers",
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

            // 7. سپرے و زہریں (Sprays & Pesticides)
            Expanded(
              child: _buildSingleRowActionItem(
                title: _isUrdu ? "سپرے (Sprays)" : "Sprays",
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

  // --- LIVE MANDI COMMODITY HIGHLIGHTS ---
  Widget _buildLiveMandiSection() {
    final defaultCityUrdu = _nearbyMandiCityUrdu ?? _liveWeather?.city.nameUrdu ?? "ملتان";
    final defaultCityEnglish = _nearbyMandiCity ?? _liveWeather?.city.nameEnglish ?? "Multan";

    final defaultGandum = MandiRateItem(
      id: "wheat_def",
      cropEnglish: "Wheat",
      cropUrdu: "گندم",
      categoryEnglish: "Grains",
      categoryUrdu: "غلہ",
      category: CropCategory.grains,
      mandiCityEnglish: defaultCityEnglish,
      mandiCityUrdu: defaultCityUrdu,
      minRate: 4150,
      maxRate: 4350,
      avgRate: 4250,
      changeAmount: 100,
      changePercentage: 2.4,
      isUp: true,
      unitUrdu: "۴۰ کلو",
      unitEnglish: "40 kg",
      icon: Icons.grain_rounded,
    );

    final defaultCotton = MandiRateItem(
      id: "cotton_def",
      cropEnglish: "Cotton",
      cropUrdu: "کپاس",
      categoryEnglish: "Cash Crops",
      categoryUrdu: "نقد آور",
      category: CropCategory.cashCrops,
      mandiCityEnglish: defaultCityEnglish,
      mandiCityUrdu: defaultCityUrdu,
      minRate: 8600,
      maxRate: 9100,
      avgRate: 8850,
      changeAmount: 50,
      changePercentage: 0.6,
      isUp: true,
      unitUrdu: "۴۰ کلو",
      unitEnglish: "40 kg",
      icon: Icons.cloud_rounded,
    );

    final defaultRice = MandiRateItem(
      id: "rice_def",
      cropEnglish: "Rice",
      cropUrdu: "چاول",
      categoryEnglish: "Grains",
      categoryUrdu: "غلہ",
      category: CropCategory.grains,
      mandiCityEnglish: defaultCityEnglish,
      mandiCityUrdu: defaultCityUrdu,
      minRate: 9500,
      maxRate: 10200,
      avgRate: 9850,
      changeAmount: 150,
      changePercentage: 1.5,
      isUp: true,
      unitUrdu: "۴۰ کلو",
      unitEnglish: "40 kg",
      icon: Icons.rice_bowl_rounded,
    );

    final defaultUrea = MandiRateItem(
      id: "urea_def",
      cropEnglish: "Urea",
      cropUrdu: "یوریا",
      categoryEnglish: "Fertilizers",
      categoryUrdu: "کھادیں",
      category: CropCategory.fertilizers,
      mandiCityEnglish: defaultCityEnglish,
      mandiCityUrdu: defaultCityUrdu,
      minRate: 4400,
      maxRate: 4400,
      avgRate: 4400,
      changeAmount: 0,
      changePercentage: 0,
      isUp: true,
      unitUrdu: "بوری",
      unitEnglish: "Bag",
      icon: Icons.science_rounded,
    );

    final items = _topMandiRates.isNotEmpty
        ? _topMandiRates
        : [defaultGandum, defaultCotton, defaultRice, defaultUrea];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E7D32),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  _isUrdu
                      ? "قریبی منڈی ریٹس ($defaultCityUrdu)"
                      : "Nearby Mandi ($defaultCityEnglish)",
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
                const SizedBox(width: 4),
                const Icon(
                  Icons.near_me_rounded,
                  size: 13,
                  color: Color(0xFF2E7D32),
                ),
              ],
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _selectedBottomNav = 3; // Go to Mandi tab
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    Text(
                      _isUrdu ? "تمام" : "View All",
                      style: _isUrdu
                          ? AppTheme.urdu(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryMedium,
                            )
                          : AppTheme.english(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryMedium,
                            ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      _isUrdu ? Icons.arrow_back_ios_rounded : Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: AppColors.primaryMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 1 Row in Landscape, 2x2 Grid in Portrait
        if (MediaQuery.of(context).orientation == Orientation.landscape)
          Row(
            children: [
              Expanded(child: _buildMandiMiniCard(items[0])),
              const SizedBox(width: 8),
              Expanded(child: _buildMandiMiniCard(items[1])),
              const SizedBox(width: 8),
              Expanded(child: _buildMandiMiniCard(items[2])),
              const SizedBox(width: 8),
              Expanded(child: _buildMandiMiniCard(items[3])),
            ],
          )
        else ...[
          Row(
            children: [
              Expanded(child: _buildMandiMiniCard(items[0])),
              const SizedBox(width: 8),
              Expanded(child: _buildMandiMiniCard(items[1])),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildMandiMiniCard(items[2])),
              const SizedBox(width: 8),
              Expanded(child: _buildMandiMiniCard(items[3])),
            ],
          ),
        ],
      ],
    );
  }

  String _getCleanCropName(MandiRateItem item) {
    if (_isUrdu) {
      if (item.cropUrdu.contains("گندم")) return "گندم";
      if (item.cropUrdu.contains("کپاس") || item.cropUrdu.contains("پھٹی")) return "کپاس";
      if (item.cropUrdu.contains("چاول") || item.cropUrdu.contains("باسمتی")) return "چاول";
      if (item.cropUrdu.contains("یوریا")) return "یوریا";
      if (item.cropUrdu.contains("مکئی")) return "مکئی";
      if (item.cropUrdu.contains("کماد") || item.cropUrdu.contains("گنا")) return "کماد";
      if (item.cropUrdu.contains("آلو")) return "آلو";
      if (item.cropUrdu.contains("پیاز")) return "پیاز";
      if (item.cropUrdu.contains("ٹماٹر")) return "ٹماٹر";
      return item.cropUrdu.split('(')[0].trim();
    } else {
      if (item.cropEnglish.toLowerCase().contains("wheat")) return "Wheat";
      if (item.cropEnglish.toLowerCase().contains("cotton")) return "Cotton";
      if (item.cropEnglish.toLowerCase().contains("rice")) return "Rice";
      if (item.cropEnglish.toLowerCase().contains("urea")) return "Urea";
      if (item.cropEnglish.toLowerCase().contains("maize") || item.cropEnglish.toLowerCase().contains("corn")) return "Maize";
      if (item.cropEnglish.toLowerCase().contains("sugarcane")) return "Sugarcane";
      if (item.cropEnglish.toLowerCase().contains("potato")) return "Potato";
      if (item.cropEnglish.toLowerCase().contains("onion")) return "Onion";
      if (item.cropEnglish.toLowerCase().contains("tomato")) return "Tomato";
      return item.cropEnglish.split('(')[0].trim();
    }
  }

  Widget _buildMandiMiniCard(MandiRateItem item) {
    final cleanCrop = _getCleanCropName(item);
    final cityName = _isUrdu
        ? (_nearbyMandiCityUrdu ?? item.mandiCityUrdu)
        : (_nearbyMandiCity ?? item.mandiCityEnglish);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedBottomNav = 3; // Go to Mandi tab
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.7)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    cleanCrop,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _isUrdu
                        ? AppTheme.urdu(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          )
                        : AppTheme.english(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: item.changePercentage > 0
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    item.changePercentage > 0
                        ? "+${item.changePercentage.toStringAsFixed(1)}%"
                        : (_isUrdu ? "مستحکم" : "Stable"),
                    style: TextStyle(
                      fontSize: 7.5,
                      fontWeight: FontWeight.w700,
                      color: item.changePercentage > 0
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFE65100),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Rs. ${item.avgRate.round()}",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryDark,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isUrdu ? (item.unitUrdu.contains("بوری") ? "بوری" : "۴۰ کلو") : (item.unitEnglish.contains("Bag") ? "Bag" : "40 kg"),
                  style: const TextStyle(
                    fontSize: 8.5,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    cityName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 8.5,
                      color: AppColors.primaryMedium,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- FARM LEDGER & AGRI ADVISORY SPOTLIGHT ---
  Widget _buildAgriAdvisoryAndKhataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Farm Ledger Offline Snapshot Card
        InkWell(
          onTap: () {
            setState(() {
              _selectedBottomNav = 2; // Khata Tab
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.7)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppColors.primaryDark,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _isUrdu ? "کسان کھیت کھاتہ" : "Smart Farm Ledger",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _isUrdu
                                  ? AppTheme.urdu(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textDark,
                                    )
                                  : AppTheme.english(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textDark,
                                    ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceAlt,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Text(
                              _isUrdu ? "آف لائن" : "Offline",
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _isUrdu
                            ? "کھاد، بیج، اسپرے اور ڈیزل کے اخراجات بغیر انٹرنیٹ درج کریں"
                            : "Record fertilizers, seeds & diesel expenses offline",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _isUrdu
                            ? AppTheme.urdu(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              )
                            : AppTheme.english(
                                fontSize: 10.5,
                                color: AppColors.textMuted,
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _isUrdu ? Icons.arrow_back_ios_rounded : Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: AppColors.textLight,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 2. Seasonal Agri Advisory Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F8F3),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD4E7DA)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primaryMedium.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: Color(0xFF257538),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isUrdu ? "موسمی زرعی رہنمائی" : "Seasonal Crop Advisory",
                      style: _isUrdu
                          ? AppTheme.urdu(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1B4332),
                            )
                          : AppTheme.english(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1B4332),
                            ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isUrdu
                          ? "گندم و ربیع سیزن میں نائٹروجنی کھاد کا متوازن استعمال اور دیمک سے بچاؤ کے لیے سفارش کردہ وقت پر اسپرے کریں۔"
                          : "Balanced nitrogen application and timely protective spray against termites ensures optimum yield this season.",
                      style: _isUrdu
                          ? AppTheme.urdu(
                              fontSize: 10.5,
                              color: const Color(0xFF2D6A4F),
                              height: 1.5,
                            )
                          : AppTheme.english(
                              fontSize: 11,
                              color: const Color(0xFF2D6A4F),
                              height: 1.3,
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
