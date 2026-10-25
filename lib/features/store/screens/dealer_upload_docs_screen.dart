import 'package:flutter/material.dart';
import '../../../core/localization/language_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../auth/controllers/user_session_controller.dart';
import 'dealer_pending_verification_screen.dart';

class DealerUploadDocsScreen extends StatefulWidget {
  final bool? isUrdu;

  const DealerUploadDocsScreen({super.key, this.isUrdu});

  @override
  State<DealerUploadDocsScreen> createState() => _DealerUploadDocsScreenState();
}

class _DealerUploadDocsScreenState extends State<DealerUploadDocsScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _shopNameController = TextEditingController(
    text: UserSessionController.instance.businessOrFarmName.isNotEmpty
        ? UserSessionController.instance.businessOrFarmName
        : "Chaudhry Agri Seeds & Fertilizer",
  );
  final TextEditingController _licenseNoController = TextEditingController(text: "FSC-PB-2024-8849");
  final TextEditingController _addressController = TextEditingController(text: "Shop # 14, Ghalla Mandi, Multan");

  bool _isLicenseUploaded = false;
  bool _isShopPhotoUploaded = false;
  bool _isLoading = false;

  bool get _isUrdu => widget.isUrdu ?? LanguageController.instance.isUrdu;

  @override
  void dispose() {
    _shopNameController.dispose();
    _licenseNoController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    if (!_isLicenseUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isUrdu
                ? "براہ کرم زرعی لائسنس کی تصویر اپلوڈ کریں"
                : "Please upload your Agri Dealer License photo",
          ),
          backgroundColor: AppColors.alertSoftRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      // Navigate to the Under Review Screen with 15-second countdown timer
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => DealerPendingVerificationScreen(
            shopName: _shopNameController.text.trim(),
            licenseNumber: _licenseNoController.text.trim(),
            district: UserSessionController.instance.district,
            isUrdu: _isUrdu,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryDark, size: 18),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: Text(
            _isUrdu ? "زرعی لائسنس و دستاویزات" : "Upload Agri Documents",
            style: _isUrdu
                ? AppTheme.urdu(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primaryDark)
                : AppTheme.english(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step Indicator Badge
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        _isUrdu ? "مرحلہ ۲: ڈیلر ویری فکیشن" : "Step 2: Dealer Verification",
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Center(
                    child: Text(
                      _isUrdu ? "دکان و لائسنس کی تفصیلات درج کریں" : "Verify Your Agricultural Business",
                      style: _isUrdu
                          ? AppTheme.urdu(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primaryDark)
                          : AppTheme.english(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      _isUrdu
                          ? "محکمہ زراعت یا FSC&RD سے تصدیق شدہ لائسنس اپلوڈ کریں"
                          : "Upload official FSC&RD / Punjab Agri Dept Dealer License",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 1. Shop Name
                  _buildInputLabel(_isUrdu ? "دکان / ایجنسی کا نام" : "Shop / Agency Name"),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _shopNameController,
                    validator: (v) => v == null || v.trim().isEmpty ? "Please enter shop name" : null,
                    decoration: _inputDecoration("e.g. Chaudhry Agri Seeds & Fertilizer", Icons.storefront_rounded),
                  ),
                  const SizedBox(height: 14),

                  // 2. License Number
                  _buildInputLabel(_isUrdu ? "FSC&RD / زرعی ڈیلر لائسنس نمبر" : "Agri / FSC&RD License Number"),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _licenseNoController,
                    validator: (v) => v == null || v.trim().isEmpty ? "Please enter license number" : null,
                    decoration: _inputDecoration("e.g. FSC-PB-2024-8849", Icons.badge_outlined),
                  ),
                  const SizedBox(height: 14),

                  // 3. Shop Market Address
                  _buildInputLabel(_isUrdu ? "مارکیٹ و دکان کا پتہ" : "Shop / Market Address"),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _addressController,
                    validator: (v) => v == null || v.trim().isEmpty ? "Please enter market address" : null,
                    decoration: _inputDecoration("e.g. Grain Market, Multan", Icons.location_on_outlined),
                  ),
                  const SizedBox(height: 18),

                  // 4. Primary License Photo Upload Box (Mandatory)
                  _buildInputLabel(_isUrdu ? "زرعی لائسنس کی تصویر (لازمی)" : "Agri License Document / Photo (Required)"),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () {
                      setState(() => _isLicenseUploaded = !_isLicenseUploaded);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _isLicenseUploaded ? const Color(0xFFF0FDF4) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _isLicenseUploaded ? const Color(0xFF86EFAC) : AppColors.borderLight,
                          width: 1.4,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _isLicenseUploaded
                                  ? const Color(0xFFDCFCE7)
                                  : AppColors.primaryMedium.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _isLicenseUploaded ? Icons.verified_rounded : Icons.upload_file_rounded,
                              color: _isLicenseUploaded ? const Color(0xFF16A34A) : AppColors.primaryMedium,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isLicenseUploaded
                                      ? (_isUrdu ? "لائسنس منسلک ہو گیا ہے (FSC-License.jpg)" : "FSC-License-Certificate.jpg (Attached)")
                                      : (_isUrdu ? "لائسنس کی تصویر اپلوڈ کرنے کیلئے کلک کریں" : "Tap to upload license photo or scan"),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _isLicenseUploaded ? const Color(0xFF16A34A) : AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _isUrdu ? "پنجاب سیڈ یا فیڈرل سیڈ سرٹیفکیٹ" : "FSC&RD / Agriculture Department Valid Permit",
                                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            _isLicenseUploaded ? Icons.check_circle_rounded : Icons.camera_alt_outlined,
                            size: 20,
                            color: _isLicenseUploaded ? const Color(0xFF16A34A) : AppColors.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 5. Shop Front Photo (Optional)
                  _buildInputLabel(_isUrdu ? "دکان کا فرنٹ بورڈ (اختیاری)" : "Shop Front Signboard Photo (Optional)"),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () {
                      setState(() => _isShopPhotoUploaded = !_isShopPhotoUploaded);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isShopPhotoUploaded ? const Color(0xFFF0FDF4) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _isShopPhotoUploaded ? const Color(0xFF86EFAC) : AppColors.borderLight,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isShopPhotoUploaded ? Icons.image_rounded : Icons.add_a_photo_outlined,
                            size: 20,
                            color: _isShopPhotoUploaded ? const Color(0xFF16A34A) : AppColors.textMuted,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _isShopPhotoUploaded
                                  ? (_isUrdu ? "دکان کی تصویر منسلک ہے (ShopFront.jpg)" : "ShopFront.jpg (Attached)")
                                  : (_isUrdu ? "دکان کے بورڈ کی تصویر اپلوڈ کریں" : "Attach shop exterior / board photo"),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _isShopPhotoUploaded ? const Color(0xFF16A34A) : AppColors.textDark,
                              ),
                            ),
                          ),
                          Icon(
                            _isShopPhotoUploaded ? Icons.check_rounded : Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: _isShopPhotoUploaded ? const Color(0xFF16A34A) : AppColors.textLight,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 1,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _isUrdu ? "تصدیق کیلئے جمع کروائیں" : "Submit for Verification",
                                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_rounded, color: AppColors.accentLime, size: 16),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textDark),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: AppColors.textLight),
      prefixIcon: Icon(icon, color: AppColors.primaryMedium, size: 18),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.6),
      ),
    );
  }
}
