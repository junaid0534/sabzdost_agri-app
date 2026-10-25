import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/localization/language_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';
import 'dealer_dashboard_screen.dart';

class DealerPendingVerificationScreen extends StatefulWidget {
  final String shopName;
  final String licenseNumber;
  final String district;
  final bool? isUrdu;
  final int countdownSeconds;

  const DealerPendingVerificationScreen({
    super.key,
    required this.shopName,
    required this.licenseNumber,
    required this.district,
    this.isUrdu,
    this.countdownSeconds = 15,
  });

  @override
  State<DealerPendingVerificationScreen> createState() => _DealerPendingVerificationScreenState();
}

class _DealerPendingVerificationScreenState extends State<DealerPendingVerificationScreen> {
  late int _remainingSeconds;
  Timer? _timer;

  bool get _isUrdu => widget.isUrdu ?? LanguageController.instance.isUrdu;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.countdownSeconds;
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds <= 1) {
        timer.cancel();
        _navigateToDashboard();
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  void _navigateToDashboard() {
    _timer?.cancel();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const DealerDashboardScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_remainingSeconds / widget.countdownSeconds).clamp(0.0, 1.0);

    return ResponsiveLayout(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            _isUrdu ? "درخواست زیرِ تصدیق ہے" : "Application Under Review",
            style: _isUrdu
                ? AppTheme.urdu(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primaryDark)
                : AppTheme.english(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),

                // Live 15-Second Animated Circular Countdown Box
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 4,
                        backgroundColor: const Color(0xFFFEF3C7),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD97706)),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "$_remainingSeconds",
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFD97706),
                          ),
                        ),
                        Text(
                          _isUrdu ? "سیکنڈ" : "sec",
                          style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Status Heading
                Text(
                  _isUrdu ? "درخواست کی تصدیق جاری ہے" : "Verifying Dealer Credentials...",
                  textAlign: TextAlign.center,
                  style: _isUrdu
                      ? AppTheme.urdu(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primaryDark)
                      : AppTheme.english(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                ),
                const SizedBox(height: 6),

                Text(
                  _isUrdu
                      ? "محکمہ زراعت اور فیڈرل سیڈ سرٹیفیکیشن (FSC&RD) کے ریکارڈ سے تصدیق کی جا رہی ہے۔ $_remainingSeconds سیکنڈ بعد آپ کا اکاؤنٹ خودکار طور پر ایکٹو ہو جائے گا۔"
                      : "Verifying your license with FSC&RD database. Your account will automatically activate in $_remainingSeconds seconds.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted, height: 1.5),
                ),
                const SizedBox(height: 24),

                // Application Summary Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(_isUrdu ? "دکان کا نام:" : "Store Name:", widget.shopName),
                      const Divider(height: 14, color: AppColors.borderLight),
                      _buildDetailRow(_isUrdu ? "لائسنس نمبر:" : "License No:", widget.licenseNumber),
                      const Divider(height: 14, color: AppColors.borderLight),
                      _buildDetailRow(_isUrdu ? "ضلع / مارکیٹ:" : "District:", widget.district),
                      const Divider(height: 14, color: AppColors.borderLight),
                      _buildDetailRow(
                        _isUrdu ? "حالت:" : "Status:",
                        _isUrdu ? "زیرِ تصدیق (Reviewing)" : "Verification in Progress",
                        valueColor: const Color(0xFFD97706),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Instant Skip / Open Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _navigateToDashboard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      elevation: 1,
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.accentLime),
                    label: Text(
                      _isUrdu ? "ڈیش بورڈ پر جائیں (Skip Timer)" : "Proceed to Dashboard (Skip)",
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: valueColor ?? AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}
