import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/screens/login_screen.dart';
import '../models/onboarding_item.dart';
import '../widgets/onboarding_card.dart';
import '../widgets/page_indicator.dart';
import '../../../core/widgets/responsive_layout.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingItem> _slides = const [
    OnboardingItem(
      tagEnglish: "AI Crop Doctor",
      tagUrdu: "AI Crop Doctor",
      titleEnglish: "Instant Crop Disease Diagnosis",
      titleUrdu: "Instant Crop Disease Diagnosis",
      subtitleEnglish:
          "Scan your crop with AI vision to detect diseases and get authentic remedies instantly.",
      subtitleUrdu:
          "Scan your crop with AI vision to detect diseases and get authentic remedies instantly.",
      badgeTextEnglish: "AI Vision",
      badgeTextUrdu: "AI Vision",
      icon: Icons.psychology_rounded,
      badgeColor: AppColors.accentLime,
    ),
    OnboardingItem(
      tagEnglish: "Live Mandi Rates",
      tagUrdu: "Live Mandi Rates",
      titleEnglish: "Verified Daily Mandi Rates",
      titleUrdu: "Verified Daily Mandi Rates",
      subtitleEnglish:
          "Get real-time market rates across Punjab and Sindh to maximize your farm profit.",
      subtitleUrdu:
          "Get real-time market rates across Punjab and Sindh to maximize your farm profit.",
      badgeTextEnglish: "Live Rates",
      badgeTextUrdu: "Live Rates",
      icon: Icons.storefront_rounded,
      badgeColor: AppColors.accentGold,
    ),
    OnboardingItem(
      tagEnglish: "Offline Farm Ledger",
      tagUrdu: "Offline Farm Ledger",
      titleEnglish: "Smart Farm Accounting, 100% Offline",
      titleUrdu: "Smart Farm Accounting, 100% Offline",
      subtitleEnglish:
          "Easily track fertilizers, seeds, labor expenses, and net profit without internet.",
      subtitleUrdu:
          "Easily track fertilizers, seeds, labor expenses, and net profit without internet.",
      badgeTextEnglish: "Offline Safe",
      badgeTextUrdu: "Offline Safe",
      icon: Icons.menu_book_rounded,
      badgeColor: AppColors.primaryMedium,
    ),
  ];

  void _onNext() {
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
          return FadeTransition(
            opacity: curve,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.06, 0),
                end: Offset.zero,
              ).animate(curve),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLast = _currentIndex == _slides.length - 1;

    return ResponsiveLayout(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Top Bar: Logo & Skip Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.eco_rounded,
                            color: AppColors.accentLime,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "SabzDost",
                          style: AppTheme.english(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ],
                    ),
                    if (!isLast)
                      TextButton(
                        onPressed: _navigateToLogin,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textMuted,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        ),
                        child: Text(
                          "Skip",
                          style: AppTheme.english(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 36),
                  ],
                ),
                const SizedBox(height: 12),

                // PageView Slides (Clean English, zero overlap)
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            const SizedBox(height: 6),
                            // Visual Graphic Card (compact, elegant)
                            OnboardingVisualCard(index: index),

                            const SizedBox(height: 22),

                            // Category Tag Pill
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(slide.icon, size: 14, color: AppColors.primaryDark),
                                  const SizedBox(width: 6),
                                  Text(
                                    slide.tagEnglish,
                                    style: AppTheme.english(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Clean, Bold English Headline
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                slide.titleEnglish,
                                textAlign: TextAlign.center,
                                style: AppTheme.english(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                  height: 1.3,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Concise Subtitle
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                slide.subtitleEnglish,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.english(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textMuted,
                                  height: 1.45,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Section: Dots & Action Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0, top: 8),
                  child: Column(
                    children: [
                      // Animated Page Indicators
                      OnboardingPageIndicator(
                        count: _slides.length,
                        currentIndex: _currentIndex,
                      ),
                      const SizedBox(height: 16),

                      // Modern Action Button
                      InkWell(
                        onTap: _onNext,
                        borderRadius: BorderRadius.circular(40),
                        child: Container(
                          height: 56,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark,
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryDark.withValues(alpha: 0.25),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Left circular icon
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primaryMedium,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),

                                // Center Label
                                Text(
                                  isLast ? "Get Started" : "Next",
                                  style: AppTheme.english(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),

                                // Right Chevron
                                const Padding(
                                  padding: EdgeInsets.only(right: 12.0),
                                  child: Text(
                                    ">>>",
                                    style: TextStyle(
                                      color: AppColors.accentLime,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
}
