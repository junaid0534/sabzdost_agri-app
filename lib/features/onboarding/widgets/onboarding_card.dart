import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class OnboardingVisualCard extends StatelessWidget {
  final int index;

  const OnboardingVisualCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    switch (index) {
      case 0:
        return _buildAiDoctorVisual(context);
      case 1:
        return _buildMandiRatesVisual(context);
      case 2:
      default:
        return _buildOfflineKhataVisual(context);
    }
  }

  // Slide 1: AI Plant Doctor Scanner Visual
  Widget _buildAiDoctorVisual(BuildContext context) {
    return Container(
      height: 335,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentLime.withValues(alpha: 0.18),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top status chips with English & Urdu (Responsive Row)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome, color: AppColors.accentGold, size: 13),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                "AI Scanner • اسکینر",
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.english(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.mic, size: 12, color: AppColors.primaryDark),
                          const SizedBox(width: 4),
                          Text(
                            "صوتی رہنمائی",
                            style: AppTheme.urdu(
                              color: AppColors.textDark,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Center Scanner Graphic with Radar Pulse
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.accentLime.withValues(alpha: 0.35),
                            width: 2,
                          ),
                        ),
                      ),
                      Container(
                        width: 98,
                        height: 98,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.background,
                          border: Border.all(
                            color: AppColors.primaryMedium.withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),
                      ),
                      Container(
                        width: 68,
                        height: 68,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.greenGradient,
                        ),
                        child: const Icon(
                          Icons.energy_savings_leaf_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.accentGold,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "98.4% Match • درست تشخیص",
                            style: AppTheme.english(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Detected Crop Diagnostic Card
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.alertSoftRed.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.coronavirus_outlined,
                          color: AppColors.alertSoftRed,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  "Cotton: Pink Bollworm ",
                                  style: AppTheme.english(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                Text(
                                  "(کپاس: گلابی سنڈی)",
                                  style: AppTheme.urdu(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.alertSoftRed,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "علاج: ایما مRelevant 200 ملی لیٹر فی ایکڑ اسپرے کریں",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.urdu(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Slide 2: Live Mandi Rates Visual
  Widget _buildMandiRatesVisual(BuildContext context) {
    return Container(
      height: 335,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.trending_up_rounded, color: AppColors.accentLime, size: 13),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            "Live Mandi • منڈی ریٹس",
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.english(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "روزانہ تازہ ترین ریٹ",
                  style: AppTheme.urdu(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildMandiRateItem(
              cropEnglish: "Wheat",
              cropUrdu: "گندم",
              mandi: "Multan (ملتان)",
              rate: "Rs. 3,950",
              unit: "/ 40kg",
              change: "+2.5%",
              isPositive: true,
            ),
            const SizedBox(height: 6),
            _buildMandiRateItem(
              cropEnglish: "Cotton",
              cropUrdu: "کپاس",
              mandi: "Bahawalpur (بہاولپور)",
              rate: "Rs. 8,400",
              unit: "/ 40kg",
              change: "+4.1%",
              isPositive: true,
            ),
            const SizedBox(height: 6),
            _buildMandiRateItem(
              cropEnglish: "Corn",
              cropUrdu: "مکئی",
              mandi: "Sahiwal (ساہیوال)",
              rate: "Rs. 2,550",
              unit: "/ 40kg",
              change: "-1.0%",
              isPositive: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMandiRateItem({
    required String cropEnglish,
    required String cropUrdu,
    required String mandi,
    required String rate,
    required String unit,
    required String change,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      cropEnglish,
                      style: AppTheme.english(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "($cropUrdu)",
                      style: AppTheme.urdu(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryMedium,
                      ),
                    ),
                  ],
                ),
                Text(
                  mandi,
                  style: AppTheme.english(
                    fontSize: 9,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: rate,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    TextSpan(
                      text: " $unit",
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isPositive
                      ? AppColors.successGreen.withValues(alpha: 0.12)
                      : AppColors.alertSoftRed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: isPositive ? AppColors.successGreen : AppColors.alertSoftRed,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Slide 3: 100% Offline Khata Visual
  Widget _buildOfflineKhataVisual(BuildContext context) {
    return Container(
      height: 335,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_off_rounded, color: AppColors.accentGold, size: 13),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            "Offline Khata • آف لائن",
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.english(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Text(
                    "محفوظ ڈیٹا 🔒",
                    style: AppTheme.urdu(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Khata Total Summary Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppColors.greenGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Net Season Profit",
                        style: AppTheme.english(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "خالص منافع",
                        style: AppTheme.urdu(
                          color: AppColors.accentLime,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "+ Rs. 245,000",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            _buildKhataEntryItem(
              titleEnglish: "DAP Fertilizer (2 Bags)",
              titleUrdu: "ڈی اے پی کھاد (۲ بوری)",
              amount: "- Rs. 24,000",
              isExpense: true,
            ),
            const SizedBox(height: 6),
            _buildKhataEntryItem(
              titleEnglish: "Wheat Harvest (40 Maund)",
              titleUrdu: "گندم کی فروخت (۴۰ من)",
              amount: "+ Rs. 158,000",
              isExpense: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKhataEntryItem({
    required String titleEnglish,
    required String titleUrdu,
    required String amount,
    required bool isExpense,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(
            isExpense ? Icons.arrow_outward_rounded : Icons.arrow_downward_rounded,
            color: isExpense ? AppColors.alertSoftRed : AppColors.successGreen,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titleEnglish,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.english(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  titleUrdu,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.urdu(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            amount,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isExpense ? AppColors.alertSoftRed : AppColors.successGreen,
            ),
          ),
        ],
      ),
    );
  }
}
