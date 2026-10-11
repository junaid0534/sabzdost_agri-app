import 'package:flutter/material.dart';
import '../../../core/localization/language_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../doctor/screens/crop_doctor_screen.dart';
import '../../ledger/screens/farm_ledger_screen.dart';
import '../../machinery/screens/machinery_category_screen.dart';
import '../../mandi/screens/mandi_rates_screen.dart';
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
            const SizedBox(height: 18),

            // 2. HERO VISUAL BANNER (With Integrated 3 Metrics: Soil, Weather, Air)
            _buildHeroVisualBanner(),
            const SizedBox(height: 18),

            // 3. 4-MENU QUICK NAVIGATION (Arhti Khata, Crop Khata, Doctor, Mandi)
            _buildFourMenuGrid(),
            const SizedBox(height: 22),

            // 4. AI CROP DOCTOR SCAN BANNER
            _buildAiDoctorCard(),
            const SizedBox(height: 24),

            // 5. CHOOSE YOUR FARM / ACTIVE CROPS (Photographic Cards)
            _buildFarmCardsSection(),
            const SizedBox(height: 24),

            // 6. INSTANT ACTIONS (Large Rounded White Cards)
            _buildInstantActionsSection(),
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
        // Left: Avatar + Greeting
        Expanded(
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryMedium.withValues(alpha: 0.15),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200&auto=format&fit=crop",
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.person_rounded,
                      color: AppColors.primaryDark,
                      size: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isUrdu ? "خوش آمدید" : "Welcome Back",
                      style: _isUrdu
                          ? AppTheme.urdu(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            )
                          : AppTheme.english(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isUrdu ? "چوہدری اکرم" : "Chaudhry Akram",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _isUrdu
                          ? AppTheme.urdu(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            )
                          : AppTheme.english(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                              letterSpacing: -0.3,
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

  // --- HERO VISUAL BANNER (Simple, Clean & Professional with 3 Embedded Metrics) ---
  Widget _buildHeroVisualBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF143D27), // Deep Forest Emerald
            Color(0xFF1B5E36), // Rich Olive Green
            Color(0xFF0F301F), // Dark Emerald
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF143D27).withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle decorative ambient background curves
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            left: 60,
            bottom: -50,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentLime.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Main Banner Content
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AgriWeatherScreen(isUrdu: _isUrdu),
                  ),
                ).then((_) => _fetchDashboardWeather());
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Header Row: Status badge & farm subtitle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AppColors.accentLime,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "${_liveWeather?.city.nameUrdu ?? 'ملتان'} • ${_isUrdu ? 'لائیو زرعی موسم' : 'Live Agri Weather'}",
                              style: _isUrdu
                                  ? AppTheme.urdu(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withValues(alpha: 0.85),
                                    )
                                  : AppTheme.english(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withValues(alpha: 0.85),
                                    ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _liveWeather?.current.icon ?? Icons.wb_sunny_rounded,
                                size: 12,
                                color: AppColors.accentGold,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${_liveWeather?.current.temperature.round() ?? 28}°C • ${_isUrdu ? (_liveWeather?.current.conditionUrdu ?? 'صاف') : (_liveWeather?.current.conditionEnglish ?? 'Clear')}",
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 3 Integrated Clean Metrics (Temperature, Spray Advisory, Wind Speed)
                    Row(
                      children: [
                        Expanded(
                          child: _buildSimpleMetricPill(
                            title: _isUrdu ? "درجہ حرارت" : "Temp",
                            value: "${_liveWeather?.current.temperature.round() ?? 28}°C",
                            icon: _liveWeather?.current.icon ?? Icons.wb_sunny_rounded,
                            accentColor: const Color(0xFFFFCA28),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildSimpleMetricPill(
                            title: _isUrdu ? "اسپرے موسم" : "Spray",
                            value: _liveWeather == null
                                ? (_isUrdu ? "بہترین" : "Ideal")
                                : _liveWeather!.sprayAdvisory.status == SprayStatus.optimal
                                    ? (_isUrdu ? "بہترین" : "Ideal")
                                    : _liveWeather!.sprayAdvisory.status == SprayStatus.caution
                                        ? (_isUrdu ? "احتیاط" : "Caution")
                                        : (_isUrdu ? "روک دیں" : "Avoid"),
                            icon: Icons.sanitizer_rounded,
                            accentColor: _liveWeather?.sprayAdvisory.statusColor ?? const Color(0xFF66BB6A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildSimpleMetricPill(
                            title: _isUrdu ? "ہوا کی رفتار" : "Wind",
                            value: "${_liveWeather?.current.windSpeed.round() ?? 8} km/h",
                            icon: Icons.air_rounded,
                            accentColor: const Color(0xFF4DD0E1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Clean, modern frosted pill for the Hero Banner
  Widget _buildSimpleMetricPill({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: accentColor), // Baray, wazeh icons
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _isUrdu
                ? AppTheme.urdu(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.80),
                    fontWeight: FontWeight.w600,
                  )
                : AppTheme.english(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.80),
                    fontWeight: FontWeight.w600,
                  ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _isUrdu
                ? AppTheme.urdu(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  )
                : AppTheme.english(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
          ),
        ],
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
                icon: Icons.grass_rounded,
                iconColor: const Color(0xFF2E7D32),
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

            // 4. زرعی مشینری (Machinery Rental Category Selection)
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
      ],
    );
  }

  // Modern vertical quick-action card tailored for 4-in-a-row layout
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
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.6)),
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
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 8),
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
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: AppColors.greenGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.22),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome, size: 12, color: AppColors.accentLime),
                        const SizedBox(width: 4),
                        Text(
                          _isUrdu ? "فصل کا فوری اسکین" : "Instant AI Vision Scan",
                          style: _isUrdu
                              ? AppTheme.urdu(
                                  color: AppColors.accentLime,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                )
                              : AppTheme.english(
                                  color: AppColors.accentLime,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isUrdu ? "فصل کی بیماری پہچانیں" : "Scan Crop Disease",
                    style: _isUrdu
                        ? AppTheme.urdu(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          )
                        : AppTheme.english(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isUrdu
                        ? "پتے کی تصویر کھینچیں اور مستند علاج حاصل کریں"
                        : "Snap leaf photo for diagnosis & certified remedy",
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
                            color: Colors.white.withValues(alpha: 0.80),
                            fontWeight: FontWeight.w500,
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: AppColors.primaryDark,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- CHOOSE YOUR FARM / ACTIVE CROPS SECTION ---
  Widget _buildFarmCardsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _isUrdu ? "آپ کے فارم اور فصلیں" : "Choose Your Farm",
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
            Text(
              _isUrdu ? "سب دیکھیں" : "Details",
              style: _isUrdu
                  ? AppTheme.urdu(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryMedium,
                    )
                  : AppTheme.english(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryMedium,
                    ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Horizontal photographic cards carousel
        SizedBox(
          height: 234,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildPhotographicFarmCard(
                imageUrl:
                    "https://images.unsplash.com/photo-1592417817098-8f3d69109853?q=80&w=600&auto=format&fit=crop",
                badgeText: "1300 pts",
                title: _isUrdu ? "سبز وادی فارم" : "Green Valley Farm",
                subtitle: _isUrdu ? "ڈیری و سبزیاں • 12 ایکڑ" : "Dairy & Vegetables",
                progressValue: 0.85,
              ),
              const SizedBox(width: 14),
              _buildPhotographicFarmCard(
                imageUrl:
                    "https://images.unsplash.com/photo-1500937386664-56d1dfef3854?q=80&w=600&auto=format&fit=crop",
                badgeText: "1200 pts",
                title: _isUrdu ? "سنہری گندم فارم" : "Sunrise Fields",
                subtitle: _isUrdu ? "گندم و اناج • 8 ایکڑ" : "Grains & Harvest",
                progressValue: 0.70,
              ),
              const SizedBox(width: 14),
              _buildPhotographicFarmCard(
                imageUrl:
                    "https://images.unsplash.com/photo-1625246333195-78d9c38ad449?q=80&w=600&auto=format&fit=crop",
                badgeText: "1400 pts",
                title: _isUrdu ? "دریائی کپاس فارم" : "Riverbed Crops",
                subtitle: _isUrdu ? "کپاس و مکئی • 15 ایکڑ" : "Cotton & Maize",
                progressValue: 0.92,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotographicFarmCard({
    required String imageUrl,
    required String badgeText,
    required String title,
    required String subtitle,
    required double progressValue,
  }) {
    return Container(
      width: 168,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image Container with Floating Badge
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.surfaceAlt,
                      child: const Center(
                        child: Icon(Icons.grass_rounded, color: AppColors.primaryMedium),
                      ),
                    ),
                  ),

                  // Floating Points Badge
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.90),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Card Body (Title, Subtitle, Progress dots)
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
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
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _isUrdu
                              ? AppTheme.urdu(
                                  fontSize: 9.5,
                                  color: AppColors.textMuted,
                                )
                              : AppTheme.english(
                                  fontSize: 10,
                                  color: AppColors.textMuted,
                                ),
                        ),
                      ],
                    ),

                    // Modern Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        backgroundColor: AppColors.surfaceAlt,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primaryMedium),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- INSTANT ACTIONS SECTION ---
  Widget _buildInstantActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _isUrdu ? "فوری سہولیات" : "Instant Actions",
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
            Text(
              _isUrdu ? "تمام سروسز" : "Details",
              style: _isUrdu
                  ? AppTheme.urdu(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryMedium,
                    )
                  : AppTheme.english(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryMedium,
                    ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Action 1: Farm Ledger (Offline)
        _buildActionTile(
          icon: Icons.menu_book_rounded,
          iconBgColor: const Color(0xFFEDE7F6),
          iconColor: const Color(0xFF5E35B1),
          title: _isUrdu ? "کھیت کھاتہ (آف لائن)" : "Farm Ledger (Offline)",
          subtitle: _isUrdu ? "روزانہ کا خرچہ اور منافع بغیر انٹرنیٹ" : "Record fertilizer, fuel & revenue",
          tagText: _isUrdu ? "آف لائن" : "Offline",
          onTap: () {
            setState(() {
              _selectedBottomNav = 2; // Khata Tab
            });
          },
        ),
        const SizedBox(height: 10),

        // Action 2: Live Mandi Rates
        _buildActionTile(
          icon: Icons.storefront_rounded,
          iconBgColor: const Color(0xFFFFF8E1),
          iconColor: AppColors.accentGold,
          title: _isUrdu ? "لائیو منڈی ریٹس" : "Live Mandi Rates",
          subtitle: _isUrdu ? "سرکاری و شفاف مارکیٹ کے تازہ ریٹ" : "Govt. verified Punjab & Sindh mandis",
          tagText: _isUrdu ? "تازہ ترین" : "Live Rates",
          onTap: () {
            setState(() {
              _selectedBottomNav = 3; // Mandi Tab
            });
          },
        ),
        const SizedBox(height: 10),

        // Action 3: Machinery Rental
        _buildActionTile(
          icon: Icons.agriculture_rounded,
          iconBgColor: const Color(0xFFE8F5E9),
          iconColor: AppColors.primaryDark,
          title: _isUrdu ? "زرعی مشینری کرایہ" : "Smart Machinery Rental",
          subtitle: _isUrdu ? "قریبی لیزر لیولر، ٹریکٹر اور ہارویسٹر" : "Laser levelers, tractors & harvesters",
          tagText: _isUrdu ? "کرایہ" : "Rent",
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MachineryCategoryScreen(isUrdu: _isUrdu),
              ),
            );
          },
        ),
        const SizedBox(height: 10),

        // Action 4: Live Agri Weather & Spray Advisory
        _buildActionTile(
          icon: Icons.wb_sunny_rounded,
          iconBgColor: const Color(0xFFFFF3E0),
          iconColor: const Color(0xFFE65100),
          title: _isUrdu ? "موسم اور اسپرے ایڈوائزری" : "Agri Weather & Spray Guide",
          subtitle: _isUrdu ? "لائیو موسم، بارش کا امکان اور اسپرے رہنمائی" : "Real-time weather & 7-day spray suitability",
          tagText: _isUrdu ? "لائیو" : "Live",
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AgriWeatherScreen(isUrdu: _isUrdu),
              ),
            ).then((_) => _fetchDashboardWeather());
          },
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String tagText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
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
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Text(
                          tagText,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
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
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textLight, size: 12),
          ],
        ),
      ),
    );
  }
}
