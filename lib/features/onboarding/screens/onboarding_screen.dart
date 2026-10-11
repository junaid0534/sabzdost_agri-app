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
      tagUrdu: "فصل ڈاکٹر",
      titleEnglish: "AI Crop Diagnosis",
      titleUrdu: "فصل کی بیماری کی فوری تشخیص",
      subtitleEnglish: "Instant plant diagnosis & spray remedies from camera.",
      subtitleUrdu: "پتے کی تصویر لے کر بیماری کی تشخیص اور مستند اسپرے علاج جانیں۔",
      badgeTextEnglish: "AI Vision",
      badgeTextUrdu: "اے آئی ویژن",
      icon: Icons.psychology_rounded,
      badgeColor: AppColors.accentLime,
    ),
    OnboardingItem(
      tagEnglish: "Mandi Rates",
      tagUrdu: "منڈی ریٹس",
      titleEnglish: "Daily Mandi Rates",
      titleUrdu: "روزانہ تازہ ترین منڈی ریٹس",
      subtitleEnglish: "Live verified market prices across Punjab & Sindh mandis.",
      subtitleUrdu: "پنجاب اور سندھ کی منڈیوں کے مصدقہ لائیو ریٹس دیکھیں اور بہتر منافع کمائیں۔",
      badgeTextEnglish: "Live Rates",
      badgeTextUrdu: "لائیو ریٹس",
      icon: Icons.storefront_rounded,
      badgeColor: AppColors.accentGold,
    ),
    OnboardingItem(
      tagEnglish: "Farm Ledger",
      tagUrdu: "کھیت کھاتہ",
      titleEnglish: "Offline Farm Ledger",
      titleUrdu: "کھیت کا مکمل حساب، 100% آف لائن",
      subtitleEnglish: "Track expenses, labor & harvest profits without internet.",
      subtitleUrdu: "کھاد، بیج، ڈیزل اور مزدوری کا خرچہ محفوظ رکھیں بغیر انٹرنیٹ کے۔",
      badgeTextEnglish: "Offline Safe",
      badgeTextUrdu: "محفوظ کھاتہ",
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
                            fontSize: 17,
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
                          "Skip (چھوڑیں)",
                          style: AppTheme.urdu(
                            fontSize: 12,
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

                // PageView Slides (Clean, responsive, zero overlap)
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
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
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
                                    "${slide.tagUrdu} • ${slide.tagEnglish}",
                                    style: AppTheme.urdu(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Clean, Bold Urdu Headline
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                slide.titleUrdu,
                                textAlign: TextAlign.center,
                                style: AppTheme.urdu(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                  height: 1.35,
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Concise 1-2 line Subtitle
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                slide.subtitleUrdu,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.urdu(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textMuted,
                                  height: 1.5,
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
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      isLast ? "شروع کریں " : "آگے بڑھیں ",
                                      style: AppTheme.urdu(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      isLast ? "(Get Started)" : "(Next)",
                                      style: AppTheme.english(
                                        color: AppColors.accentLime,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
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
