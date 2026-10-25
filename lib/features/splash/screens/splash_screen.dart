import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../auth/controllers/user_session_controller.dart';
import '../../auth/models/app_role.dart';
import '../../home/screens/dashboard_screen.dart';
import '../../machinery/screens/machinery_provider_dashboard_screen.dart';
import '../../onboarding/screens/onboarding_screen.dart';
import '../../store/screens/dealer_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Smoothly transition to onboarding once content is ready (2 seconds)
    _navigationTimer = Timer(const Duration(milliseconds: 2200), _goToNext);
  }

  Future<void> _goToNext() async {
    if (!mounted) return;

    final isLoggedIn = await AuthService.instance.tryAutoLogin();

    if (!mounted) return;

    if (isLoggedIn) {
      final role = UserSessionController.instance.activeRole;
      final targetScreen = role == AppRole.seedFertilizerDealer
          ? const DealerDashboardScreen()
          : role == AppRole.machineryProvider
              ? const MachineryProviderDashboardScreen()
              : const DashboardScreen();

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const OnboardingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: GestureDetector(
          onTap: _goToNext, // Tap anywhere to skip instantly
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              // Subtle background decoration glow circles
              Positioned(
                top: -60,
                right: -60,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryLight.withValues(alpha: 0.12),
                  ),
                ),
              ),
              Positioned(
                bottom: -80,
                left: -80,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentLime.withValues(alpha: 0.14),
                  ),
                ),
              ),

              // Center Content: Animated Icon, Title & Tagline
              Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Modern App Icon Container with double ring glow
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          gradient: AppColors.greenGradient,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryDark.withValues(alpha: 0.35),
                              blurRadius: 28,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                            child: const Icon(
                              Icons.eco_rounded,
                              size: 44,
                              color: AppColors.accentLime,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // App Name
                      Text(
                        "SabzDost",
                        style: AppTheme.english(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryDark,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Tagline (Clean English + Urdu Badge)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Smart Agriculture Assistant",
                            style: AppTheme.english(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryMedium,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "سبز دوست",
                              style: AppTheme.urdu(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accentLime,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Section: Sleek Loading Indicator & Footer
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryDark.withValues(alpha: 0.75),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        "Powered by AI & Live Mandi Engine",
                        style: AppTheme.english(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
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
