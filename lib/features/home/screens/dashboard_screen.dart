import 'package:flutter/material.dart';
import '../../../core/localization/language_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../doctor/screens/crop_doctor_screen.dart';
import '../../ledger/screens/farm_ledger_screen.dart';
import '../../machinery/screens/machinery_category_screen.dart';
import '../../mandi/models/mandi_rate_item.dart';
import '../../mandi/screens/mandi_rates_screen.dart';
import '../../mandi/services/mandi_api_service.dart';
import '../../weather/models/weather_models.dart';
import '../../weather/screens/agri_weather_screen.dart';
import '../../weather/services/weather_service.dart';

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

  @override
  void initState() {
    super.initState();
    _selectedBottomNav = widget.initialIndex;
    _fetchDashboardWeather();
    _fetchDashboardMandiRates();
  }

  Future<void> _fetchDashboardWeather() async {
    final report = await WeatherService.fetchWeather();
    if (mounted) {
      setState(() {
        _liveWeather = report;
      });
    }
  }

  Future<void> _fetchDashboardMandiRates() async {
    try {
      final rates = await MandiApiService.fetchRates(city: "All Major Cities");
      if (mounted && rates.isNotEmpty) {
        setState(() {
          _topMandiRates = rates.take(4).toList();
        });
      }
    } catch (_) {}
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
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 18, right: 18, top: 12, bottom: 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TOP HEADER (Avatar, Welcome, Language Toggle & Bell)
            _buildTopHeader(),
            const SizedBox(height: 16),

            // 2. HERO VISUAL BANNER (Compact Modern Climate Card)
            _buildHeroVisualBanner(),
            const SizedBox(height: 18),

            // 3. 4-MENU QUICK NAVIGATION (Crop Khata, AI Doctor, Mandi, Machinery)
            _buildFourMenuGrid(),
            const SizedBox(height: 20),

            // 4. AI CROP DOCTOR SCAN BANNER
            _buildAiDoctorCard(),
            const SizedBox(height: 22),

            // 5. LIVE MANDI PRICE HIGHLIGHTS (Real-time Mandi Rates)
            _buildLiveMandiSection(),
            const SizedBox(height: 22),

            // 6. FARM LEDGER & AGRI ADVISORY SPOTLIGHT
            _buildAgriAdvisoryAndKhataSection(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // --- TOP HEADER ---
  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: SabzDost Brand Icon + Title & Tagline
        Expanded(
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.greenGradient,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withValues(alpha: 0.16),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.eco_rounded,
                    color: AppColors.accentLime,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 11),
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
                          fontSize: 18,
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
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryDark,
                                letterSpacing: -0.4,
                              ),
                            ),
                            TextSpan(
                              text: "Dost",
                              style: AppTheme.english(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryLight,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                  size: 14,
                  color: AppColors.primaryMedium,
                ),
                const SizedBox(width: 5),
                Text(
                  _isUrdu ? "English" : "اردو",
                  style: TextStyle(
                    fontSize: 11,
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
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.textDark,
                size: 22,
              ),
              Positioned(
                top: 11,
                right: 12,
                child: Container(
                  width: 7,
                  height: 7,
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

  // --- HERO VISUAL BANNER (Ultra-Compact Modern Climate Card - Exact Mockup Style) ---
  Widget _buildHeroVisualBanner() {
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
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
                        // Location row (Matching reference: 📍 Napa Valley, CA)
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
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withValues(alpha: 0.95),
                                      )
                                    : AppTheme.english(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withValues(alpha: 0.95),
                                      ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),

                        // Big Temperature: e.g. 72°F / 28°C
                        Text(
                          "$temp°C",
                          style: const TextStyle(
                            fontSize: 32,
                            height: 1.15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),

                        // Weather Condition: e.g. Partly Cloudy / جزوی ابر آلود
                        Text(
                          condition,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _isUrdu
                              ? AppTheme.urdu(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.95),
                                )
                              : AppTheme.english(
                                  fontSize: 12.5,
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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
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
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

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
                              style: const TextStyle(
                                fontSize: 13,
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
              _isUrdu ? "4 اہم مینیو" : "4 Shortcuts",
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
        const SizedBox(height: 12),

        // 1 SINGLE ROW CONTAINING ALL 4 ITEMS
        Row(
          children: [
            // 1. فصل کھاتہ (Crop Khata)
            Expanded(
              child: _buildSingleRowActionItem(
                title: _isUrdu ? "فصل کھاتہ" : "Crop Khata",
                subtitle: _isUrdu ? "آف لائن" : "Offline",
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
                subtitle: _isUrdu ? "فوری اسکین" : "Vision AI",
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
                subtitle: _isUrdu ? "تازہ ترین" : "Live",
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

            // 4. زرعی مشینری (Machinery Rental Category Selection)
            Expanded(
              child: _buildSingleRowActionItem(
                title: _isUrdu ? "زرعی مشینری" : "Machinery",
                subtitle: _isUrdu ? "کرایہ" : "Rentals",
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
      ],
    );
  }

  // Modern vertical quick-action card tailored for 4-in-a-row layout
  Widget _buildSingleRowActionItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.7)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 7),
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
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: bgColor.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  color: iconColor,
                ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome, size: 12, color: AppColors.accentLime),
                          const SizedBox(width: 5),
                          Text(
                            _isUrdu ? "جدید اے آئی ویژن" : "Smart AI Vision Scan",
                            style: _isUrdu
                                ? AppTheme.urdu(
                                    color: AppColors.accentLime,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  )
                                : AppTheme.english(
                                    color: AppColors.accentLime,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
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
    final defaultGandum = MandiRateItem(
      id: "wheat_def",
      cropEnglish: "Wheat (Gandum)",
      cropUrdu: "گندم",
      categoryEnglish: "Grains",
      categoryUrdu: "غلہ",
      category: CropCategory.grains,
      mandiCityEnglish: "Lahore / Multan",
      mandiCityUrdu: "لاہور / ملتان",
      minRate: 4150,
      maxRate: 4350,
      avgRate: 4250,
      changeAmount: 100,
      changePercentage: 2.4,
      isUp: true,
      icon: Icons.grain_rounded,
    );

    final defaultCotton = MandiRateItem(
      id: "cotton_def",
      cropEnglish: "Cotton (Phutti)",
      cropUrdu: "کپاس (پھٹی)",
      categoryEnglish: "Cash Crops",
      categoryUrdu: "نقد آور",
      category: CropCategory.cashCrops,
      mandiCityEnglish: "Bahawalpur",
      mandiCityUrdu: "بہاولپور",
      minRate: 8600,
      maxRate: 9100,
      avgRate: 8850,
      changeAmount: 50,
      changePercentage: 0.6,
      isUp: true,
      icon: Icons.cloud_rounded,
    );

    final defaultRice = MandiRateItem(
      id: "rice_def",
      cropEnglish: "Basmati Rice",
      cropUrdu: "باسمتی چاول",
      categoryEnglish: "Grains",
      categoryUrdu: "غلہ",
      category: CropCategory.grains,
      mandiCityEnglish: "Gujranwala",
      mandiCityUrdu: "گوجرانوالہ",
      minRate: 9500,
      maxRate: 10200,
      avgRate: 9850,
      changeAmount: 150,
      changePercentage: 1.5,
      isUp: true,
      icon: Icons.rice_bowl_rounded,
    );

    final defaultUrea = MandiRateItem(
      id: "urea_def",
      cropEnglish: "Sona Urea",
      cropUrdu: "سونا یوریا",
      categoryEnglish: "Fertilizers",
      categoryUrdu: "کھادیں",
      category: CropCategory.fertilizers,
      mandiCityEnglish: "Govt. Rate",
      mandiCityUrdu: "سرکاری ریٹ",
      minRate: 4400,
      maxRate: 4400,
      avgRate: 4400,
      changeAmount: 0,
      changePercentage: 0,
      isUp: true,
      unitUrdu: "۴۰ کلو",
      unitEnglish: "40 kg",
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
                  _isUrdu ? "منڈی کی تازہ ترین قیمتیں" : "Live Mandi Rates",
                  style: _isUrdu
                      ? AppTheme.urdu(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        )
                      : AppTheme.english(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
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
                      _isUrdu ? "تمام منڈیاں" : "View All",
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
        const SizedBox(height: 12),

        // 2x2 Grid of Mandi Commodity Cards
        Row(
          children: [
            Expanded(child: _buildMandiMiniCard(items[0])),
            const SizedBox(width: 10),
            Expanded(child: _buildMandiMiniCard(items[1])),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildMandiMiniCard(items[2])),
            const SizedBox(width: 10),
            Expanded(child: _buildMandiMiniCard(items[3])),
          ],
        ),
      ],
    );
  }

  Widget _buildMandiMiniCard(MandiRateItem item) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedBottomNav = 3; // Go to Mandi tab
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.7)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
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
                    _isUrdu ? item.cropUrdu : item.cropEnglish,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _isUrdu
                        ? AppTheme.urdu(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          )
                        : AppTheme.english(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: item.changePercentage > 0
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.changePercentage > 0
                        ? "+${item.changePercentage.toStringAsFixed(1)}%"
                        : (_isUrdu ? "مستحکم" : "Stable"),
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: item.changePercentage > 0
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFE65100),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "Rs. ${item.avgRate.round()}",
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryDark,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isUrdu ? item.unitUrdu : item.unitEnglish,
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Flexible(
                  child: Text(
                    _isUrdu ? item.mandiCityUrdu : item.mandiCityEnglish,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9.5,
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
