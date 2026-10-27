import 'package:flutter/material.dart';
import '../../../core/localization/language_controller.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../auth/controllers/user_session_controller.dart';
import '../../auth/screens/login_screen.dart';
import '../../machinery/screens/machinery_provider_dashboard_screen.dart';
import '../../store/screens/dealer_dashboard_screen.dart';
import '../../weather/services/weather_service.dart';

class FarmerSettingsScreen extends StatefulWidget {
  final bool? isUrdu;

  const FarmerSettingsScreen({super.key, this.isUrdu});

  @override
  State<FarmerSettingsScreen> createState() => _FarmerSettingsScreenState();
}

class _FarmerSettingsScreenState extends State<FarmerSettingsScreen> {
  bool _isLoggingOut = false;
  bool _isRefreshingLocation = false;

  bool get _isUrdu => widget.isUrdu ?? LanguageController.instance.isUrdu;

  String get _currentEmail {
    final sessionEmail = UserSessionController.instance.email;
    if (sessionEmail.isNotEmpty) return sessionEmail;
    try {
      return AuthService.instance.currentUser?.email ?? "";
    } catch (_) {
      return "";
    }
  }

  Future<void> _handleRealtimeLogout() async {
    // Show confirmation dialog first
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: AppColors.surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.alertSoftRed.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.logout_rounded,
                      color: AppColors.alertSoftRed,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isUrdu ? "لاگ آؤٹ کی تصدیق" : "Confirm Logout",
                  textAlign: TextAlign.center,
                  style: _isUrdu
                      ? AppTheme.urdu(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        )
                      : AppTheme.english(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                ),
                const SizedBox(height: 10),
                Text(
                  _isUrdu
                      ? "کیا آپ واقعی سبز دوست سے لاگ آؤٹ کرنا چاہتے ہیں؟ آپ کا محفوظ شدہ ڈیٹا ضائع نہیں ہوگا۔"
                      : "Are you sure you want to log out of SabzDost? Your saved data will remain intact.",
                  textAlign: TextAlign.center,
                  style: _isUrdu
                      ? AppTheme.urdu(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          height: 1.5,
                        )
                      : AppTheme.english(
                          fontSize: 13,
                          color: AppColors.textMuted,
                          height: 1.4,
                        ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: AppColors.borderLight),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _isUrdu ? "منسوخ" : "Cancel",
                          style: _isUrdu
                              ? AppTheme.urdu(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted,
                                )
                              : AppTheme.english(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Confirm logout button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.alertSoftRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _isUrdu ? "ہاں، لاگ آؤٹ" : "Log Out",
                          style: _isUrdu
                              ? AppTheme.urdu(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                )
                              : AppTheme.english(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldLogout != true) return;

    if (!mounted) return;
    setState(() => _isLoggingOut = true);

    try {
      // 1. Firebase Auth Realtime Logout + Clear Session
      await AuthService.instance.signOut();

      if (!mounted) return;

      // 2. Navigate immediately to LoginScreen, clearing all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );

      // 3. Show feedback snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isUrdu
                ? "آپ کامیابی سے لاگ آؤٹ ہو چکے ہیں"
                : "You have been logged out successfully",
            style: _isUrdu ? AppTheme.urdu(fontSize: 12, color: Colors.white) : null,
          ),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoggingOut = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Logout error: $e"),
            backgroundColor: AppColors.alertSoftRed,
          ),
        );
      }
    }
  }

  Future<void> _refreshGpsLocation() async {
    setState(() => _isRefreshingLocation = true);
    try {
      await WeatherService.autoDetectLiveLocation();
      if (mounted) {
        setState(() => _isRefreshingLocation = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isUrdu
                  ? "مقام کامیابی سے اپ ڈیٹ ہو گیا: ${WeatherService.currentCity.nameUrdu}"
                  : "Location updated: ${WeatherService.currentCity.nameEnglish}",
              style: _isUrdu ? AppTheme.urdu(fontSize: 12, color: Colors.white) : null,
            ),
            backgroundColor: AppColors.primaryMedium,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _isRefreshingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: ListenableBuilder(
            listenable: Listenable.merge([
              LanguageController.instance,
              UserSessionController.instance,
            ]),
            builder: (context, _) {
              final userSession = UserSessionController.instance;
              final displayName = userSession.displayName(_isUrdu);
              final phone = userSession.userPhone.isNotEmpty
                  ? userSession.userPhone
                  : (_isUrdu ? "فون نمبر درج نہیں" : "No phone added");
              final district = userSession.displayDistrict(_isUrdu);
              final email = _currentEmail;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  left: 18,
                  right: 18,
                  top: 14,
                  bottom: 100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Bar
                    _buildHeaderBar(),
                    const SizedBox(height: 16),

                    // User Profile Card
                    _buildUserProfileCard(
                      name: displayName,
                      phone: phone,
                      district: district,
                      email: email,
                    ),
                    const SizedBox(height: 18),

                    // Section 1: App Preferences (Language, City)
                    _buildSectionTitle(
                      _isUrdu ? "ایپ ترتیبات" : "App Preferences",
                      Icons.tune_rounded,
                    ),
                    const SizedBox(height: 10),
                    _buildLanguageSwitchTile(),
                    const SizedBox(height: 10),
                    _buildLocationTile(),
                    const SizedBox(height: 20),

                    // Section 2: Explore Other Portals (Machinery & Dealer)
                    _buildSectionTitle(
                      _isUrdu ? "دیگر زرعی پورٹلز" : "Other Portals",
                      Icons.apps_rounded,
                    ),
                    const SizedBox(height: 10),
                    _buildPortalTile(
                      title: _isUrdu ? "مشینری رینٹل پورٹل" : "Machinery Provider Portal",
                      subtitle: _isUrdu
                          ? "ہارویسٹر، لیزر، ٹریکٹر کرائے پر دیں"
                          : "Rent out farm machines & track bookings",
                      icon: Icons.agriculture_rounded,
                      color: const Color(0xFF1E88E5),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MachineryProviderDashboardScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildPortalTile(
                      title: _isUrdu ? "کھاد و بیج ڈیلر پورٹل" : "Dealer & Store Portal",
                      subtitle: _isUrdu
                          ? "کھاد، بیج و ادویات کے آرڈرز سنبھالیں"
                          : "Sell seeds, fertilizers & manage stock",
                      icon: Icons.storefront_rounded,
                      color: const Color(0xFFE65100),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DealerDashboardScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Section 3: Support & Information
                    _buildSectionTitle(
                      _isUrdu ? "مدد اور معلومات" : "Help & Support",
                      Icons.help_outline_rounded,
                    ),
                    const SizedBox(height: 10),
                    _buildSupportTile(),
                    const SizedBox(height: 22),

                    // Section 4: Realtime Logout Section
                    _buildLogoutCard(),
                    const SizedBox(height: 14),

                    // App Version Footer
                    Center(
                      child: Text(
                        "SabzDost v1.0.0 • Agri AI Platform Pakistan",
                        style: AppTheme.english(
                          fontSize: 11,
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // --- HEADER BAR ---
  Widget _buildHeaderBar() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: AppColors.greenGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.16),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.settings_suggest_rounded,
              color: AppColors.accentLime,
              size: 24,
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
                _isUrdu ? "سیٹنگز اور اکاؤنٹ" : "Settings & Profile",
                style: _isUrdu
                    ? AppTheme.urdu(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      )
                    : AppTheme.english(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
              ),
              const SizedBox(height: 2),
              Text(
                _isUrdu
                    ? "کسان پروفائل اور ایپ کی ترتیبات"
                    : "Farmer profile, preferences & session",
                style: _isUrdu
                    ? AppTheme.urdu(
                        fontSize: 10.5,
                        color: AppColors.textMuted,
                      )
                    : AppTheme.english(
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- USER PROFILE CARD ---
  Widget _buildUserProfileCard({
    required String name,
    required String phone,
    required String district,
    required String email,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: AppColors.freshLeafGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryMedium.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _isUrdu
                                ? AppTheme.urdu(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textDark,
                                  )
                                : AppTheme.english(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textDark,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Verified badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified_rounded,
                                size: 12,
                                color: AppColors.primaryMedium,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                _isUrdu ? "تصدیق شدہ" : "Verified",
                                style: _isUrdu
                                    ? AppTheme.urdu(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryMedium,
                                      )
                                    : AppTheme.english(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryMedium,
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phone,
                      style: AppTheme.english(
                        fontSize: 12.5,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.english(
                          fontSize: 11,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 12),
          // Role & District Pills
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.grass_rounded,
                        size: 16,
                        color: AppColors.primaryMedium,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _isUrdu ? "کسان / زمیندار" : "Role: Farmer",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _isUrdu
                              ? AppTheme.urdu(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark,
                                )
                              : AppTheme.english(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: AppColors.accentGold,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          district,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _isUrdu
                              ? AppTheme.urdu(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark,
                                )
                              : AppTheme.english(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- SECTION TITLE ---
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryMedium),
        const SizedBox(width: 6),
        Text(
          title,
          style: _isUrdu
              ? AppTheme.urdu(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                )
              : AppTheme.english(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
        ),
      ],
    );
  }

  // --- LANGUAGE SWITCH TILE ---
  Widget _buildLanguageSwitchTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primaryMedium.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.translate_rounded,
              color: AppColors.primaryMedium,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isUrdu ? "ایپ کی زبان" : "App Language",
                  style: _isUrdu
                      ? AppTheme.urdu(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        )
                      : AppTheme.english(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                ),
                Text(
                  _isUrdu ? "اردو (نستعلیق)" : "English",
                  style: _isUrdu
                      ? AppTheme.urdu(fontSize: 11, color: AppColors.textMuted)
                      : AppTheme.english(fontSize: 11.5, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          // Language Switch Pill
          InkWell(
            onTap: () {
              LanguageController.instance.toggleLanguage();
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sync_rounded, color: Colors.white, size: 14),
                  const SizedBox(width: 5),
                  Text(
                    _isUrdu ? "English" : "اردو",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- LOCATION TILE ---
  Widget _buildLocationTile() {
    final currentCity = WeatherService.currentCity;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.my_location_rounded,
              color: AppColors.accentGold,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isUrdu ? "موجودہ زرعی ضلع" : "Current Agri District",
                  style: _isUrdu
                      ? AppTheme.urdu(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        )
                      : AppTheme.english(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                ),
                Text(
                  _isUrdu
                      ? "${currentCity.nameUrdu} (لائیو GPS)"
                      : "${currentCity.nameEnglish} (Live GPS)",
                  style: _isUrdu
                      ? AppTheme.urdu(fontSize: 11, color: AppColors.textMuted)
                      : AppTheme.english(fontSize: 11.5, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _isRefreshingLocation ? null : _refreshGpsLocation,
            icon: _isRefreshingLocation
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryMedium,
                    ),
                  )
                : const Icon(
                    Icons.refresh_rounded,
                    color: AppColors.primaryMedium,
                  ),
            tooltip: _isUrdu ? "مقام ریفریش کریں" : "Refresh Location",
          ),
        ],
      ),
    );
  }

  // --- PORTAL TILE ---
  Widget _buildPortalTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.7)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: _isUrdu
                        ? AppTheme.urdu(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          )
                        : AppTheme.english(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _isUrdu
                        ? AppTheme.urdu(fontSize: 10.5, color: AppColors.textMuted)
                        : AppTheme.english(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }

  // --- SUPPORT TILE ---
  Widget _buildSupportTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: AppColors.primaryLight,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isUrdu ? "سرکاری زرعی ہیلپ لائن" : "Govt Agri Helpline",
                  style: _isUrdu
                      ? AppTheme.urdu(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        )
                      : AppTheme.english(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                ),
                Text(
                  "0800-15000 / 0800-29000",
                  style: AppTheme.english(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _isUrdu ? "مفت رابطہ" : "Toll Free",
              style: _isUrdu
                  ? AppTheme.urdu(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryMedium,
                    )
                  : AppTheme.english(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryMedium,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // --- REALTIME LOGOUT CARD ---
  Widget _buildLogoutCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.alertSoftRed.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.alertSoftRed.withValues(alpha: 0.25),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoggingOut ? null : _handleRealtimeLogout,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.alertSoftRed.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: _isLoggingOut
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.alertSoftRed,
                            ),
                          )
                        : const Icon(
                            Icons.logout_rounded,
                            color: AppColors.alertSoftRed,
                            size: 22,
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isUrdu ? "اکاؤنٹ سے لاگ آؤٹ کریں" : "Log Out from Account",
                        style: _isUrdu
                            ? AppTheme.urdu(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.alertSoftRed,
                              )
                            : AppTheme.english(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.alertSoftRed,
                              ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isUrdu
                          ? "ریئل ٹائم لاگ آؤٹ اور سیشن ختم کریں"
                          : "Sign out and return to login screen",
                        style: _isUrdu
                            ? AppTheme.urdu(
                                fontSize: 10.5,
                                color: AppColors.textMuted,
                              )
                            : AppTheme.english(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.alertSoftRed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
