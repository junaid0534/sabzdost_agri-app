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
      tagUrdu: "اے آئی فصل ڈاکٹر",
      titleEnglish: "Shaping the Future of\nSmart Agriculture",
      titleUrdu: "جدید زراعت اور فصل کا فوری علاج",
      subtitleEnglish:
          "Advanced AI diagnosis and authentic treatments right from your camera.",
      subtitleUrdu:
          "فصل اور پتے کی تصویر لے کر بیماری کی فوری تشخیص اور مستند اسپرے علاج حاصل کریں۔",
      badgeTextEnglish: "AI Vision • Free Scan",
      badgeTextUrdu: "مفت اے آئی اسکین",
      icon: Icons.psychology_rounded,
      badgeColor: AppColors.accentLime,
    ),
    OnboardingItem(
      tagEnglish: "Mandi Rates",
      tagUrdu: "لائیو منڈی ریٹس",
      titleEnglish: "Daily Verified\nLive Mandi Rates",
      titleUrdu: "پنجاب اور سندھ کی تمام منڈیوں کے ریٹ",
      subtitleEnglish:
          "Real-time transparent crop prices across Punjab & Sindh mandis.",
      subtitleUrdu:
          "غلہ اور سبزی منڈی کے تازہ ترین ریٹس روزانہ دیکھیں اور آڑھتی کے بغیر بہتر منافع کمائیں۔",
      badgeTextEnglish: "Live Rates • No Middleman",
      badgeTextUrdu: "شفاف اور براہ راست",
      icon: Icons.storefront_rounded,
      badgeColor: AppColors.accentGold,
    ),
    OnboardingItem(
      tagEnglish: "Offline Farm Ledger",
      tagUrdu: "آف لائن کھیت کھاتہ",
      titleEnglish: "Complete Farm Accounting\n100% Offline",
      titleUrdu: "مکمل حساب کتاب انٹرنیٹ کے بغیر",
      subtitleEnglish:
          "Log fertilizers, seeds, diesel, labor and harvest profits without internet.",
      subtitleUrdu:
          "کھاد، بیج، ڈیزل اور مزدوری کا خرچہ محفوظ رکھیں اور فصل کے آخر پر خالص منافع جانیں۔",
      badgeTextEnglish: "Offline SQLite • Safe Data",
      badgeTextUrdu: "محفوظ اور آف لائن ڈیٹا",
      icon: Icons.menu_book_rounded,
      badgeColor: AppColors.primaryMedium,
    ),
  ];

  void _onNext() {
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
          return FadeTransition(
            opacity: curve,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.08, 0),
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
    final currentSlide = _slides[_currentIndex];
    final bool isLast = _currentIndex == _slides.length - 1;

    return ResponsiveLayout(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 12),
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
                          letterSpacing: -0.5,
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
              const SizedBox(height: 14),

              // PageView Slides
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
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Visual Graphic Card
                          OnboardingVisualCard(index: index),
                          const Spacer(),

                          // Slide Tag Badge with English & Urdu
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  currentSlide.tagEnglish,
                                  style: AppTheme.english(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "• ${currentSlide.tagUrdu}",
                                  style: AppTheme.urdu(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // English Title
                          Text(
                            currentSlide.titleEnglish,
                            style: AppTheme.english(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                              height: 1.25,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Urdu Title Translation (Modern Urdu Font)
                          Text(
                            currentSlide.titleUrdu,
                            style: AppTheme.urdu(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryMedium,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Subtitle in Urdu & English
                          Text(
                            currentSlide.subtitleUrdu,
                            style: AppTheme.urdu(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMuted,
                              height: 1.6,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Section: Dots & Modern Action Button
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0, top: 10),
                child: Column(
                  children: [
                    // Animated Page Indicators
                    OnboardingPageIndicator(
                      count: _slides.length,
                      currentIndex: _currentIndex,
                    ),
                    const SizedBox(height: 20),

                    // Modern "Get Started / شروع کریں >>>" button
                    InkWell(
                      onTap: _onNext,
                      borderRadius: BorderRadius.circular(40),
                      child: Container(
                        height: 60,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryDark.withValues(alpha: 0.28),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
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
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryMedium,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),

                              // Center Label (English + Urdu script) - Responsive FittedBox
                              Expanded(
                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          isLast ? "Get Started " : "Next ",
                                          style: AppTheme.english(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          isLast ? "(شروع کریں)" : "(آگے بڑھیں)",
                                          style: AppTheme.urdu(
                                            color: AppColors.accentLime,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Right Triple Chevron
                              const Padding(
                                padding: EdgeInsets.only(right: 14.0),
                                child: Text(
                                  ">>>",
                                  style: TextStyle(
                                    color: AppColors.accentLime,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.5,
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
