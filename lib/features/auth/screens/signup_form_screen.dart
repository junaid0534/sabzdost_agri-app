import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../models/app_role.dart';
import 'email_verification_screen.dart';
import 'login_screen.dart';

class SignupFormScreen extends StatefulWidget {
  final AppRole selectedRole;

  const SignupFormScreen({
    super.key,
    required this.selectedRole,
  });

  @override
  State<SignupFormScreen> createState() => _SignupFormScreenState();
}

class _SignupFormScreenState extends State<SignupFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _districtController = TextEditingController(text: "Multan");
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _licenseNoController = TextEditingController();

  bool _isLicenseUploaded = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  final List<String> _districts = [
    "Multan",
    "Khanewal",
    "Vehari",
    "Bahawalpur",
    "Rahim Yar Khan",
    "Lodhran",
    "Sahiwal",
    "Faisalabad",
    "Sargodha",
    "Gujranwala",
    "Sheikhupura",
    "Kasur",
    "Okara",
    "Jhang",
    "Muzaffargarh",
    "Hyderabad",
    "Sukkur",
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _districtController.dispose();
    _passwordController.dispose();
    _shopNameController.dispose();
    _licenseNoController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final shopName = _shopNameController.text.trim().isNotEmpty
          ? _shopNameController.text.trim()
          : (widget.selectedRole == AppRole.seedFertilizerDealer
              ? "Chaudhry Agri Seeds & Fertilizer"
              : "");

      await AuthService.instance.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        role: widget.selectedRole,
        district: _districtController.text.trim(),
        businessOrFarmName: shopName,
        licenseNo: _licenseNoController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account created! Verification link sent to your email."),
          backgroundColor: AppColors.primaryDark,
          duration: Duration(seconds: 3),
        ),
      );

      // Navigate to Email Verification Screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => EmailVerificationScreen(
            email: _emailController.text.trim(),
            selectedRole: widget.selectedRole,
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.alertSoftRed,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: "OK",
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  void _showDistrictPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Select District",
                    style: AppTheme.english(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  Text(
                    "(ضلع منتخب کریں)",
                    style: AppTheme.urdu(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.borderLight, height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _districts.length,
                itemBuilder: (context, index) {
                  final dist = _districts[index];
                  final isSelected = _districtController.text == dist;
                  return ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 22),
                    title: Text(
                      dist,
                      style: AppTheme.english(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.primaryDark : AppColors.textDark,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_rounded, color: AppColors.primaryMedium, size: 18)
                        : null,
                    onTap: () {
                      setState(() {
                        _districtController.text = dist;
                      });
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.primaryDark,
              size: 18,
            ),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: AppColors.accentLime,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "SabzDost",
                style: AppTheme.english(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: Text(
                "Login",
                style: AppTheme.english(
                  color: AppColors.primaryMedium,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 22.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // Selected Role Pill (Centered)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, size: 13, color: AppColors.primaryDark),
                          const SizedBox(width: 5),
                          Text(
                            "Role: ${widget.selectedRole.englishTitle}",
                            style: AppTheme.english(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Header Title (Centered)
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Create Account",
                          style: AppTheme.english(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "Fill in your details to get started",
                          style: AppTheme.english(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // 1. Full Name
                  _buildSimpleField(
                    label: "Full Name",
                    urduHint: "(پورا نام)",
                    controller: _nameController,
                    hint: "Muhammad Aslam",
                    icon: Icons.person_outline_rounded,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return "Please enter your name";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // 2. Mobile Number
                  _buildSimpleField(
                    label: "Mobile Number",
                    urduHint: "(موبائل نمبر)",
                    controller: _phoneController,
                    hint: "03001234567",
                    icon: Icons.phone_android_rounded,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                    ],
                    validator: (v) {
                      if (v == null || v.trim().length < 10) {
                        return "Enter valid 11-digit mobile number";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // 3. Email Address
                  _buildSimpleField(
                    label: "Email Address",
                    urduHint: "(ای میل)",
                    controller: _emailController,
                    hint: "user@example.com",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return "Please enter your email";
                      }
                      if (!v.contains('@') || !v.contains('.')) {
                        return "Please enter a valid email address";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // 4. District Field
                  _buildDistrictField(),
                  const SizedBox(height: 14),

                  // Dealer Specific Fields: Shop Name, License No, and License Photo
                  if (widget.selectedRole == AppRole.seedFertilizerDealer) ...[
                    _buildSimpleField(
                      label: "Shop / Agency Name",
                      urduHint: "(دکان یا ایجنسی کا نام)",
                      controller: _shopNameController,
                      hint: "e.g. Chaudhry Agri Seeds & Fertilizer",
                      icon: Icons.storefront_rounded,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Please enter your store or agency name";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    _buildSimpleField(
                      label: "Agri / FSC&RD License Number",
                      urduHint: "(زرعی ڈیلر لائسنس نمبر)",
                      controller: _licenseNoController,
                      hint: "e.g. FSC-PB-2024-8849",
                      icon: Icons.badge_outlined,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Please enter your official dealer license number";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // License Document / Photo Upload Box
                    _buildLicenseUploadBox(),
                    const SizedBox(height: 14),
                  ],

                  // 5. Password Field (Last field)
                  _buildPasswordField(),
                  const SizedBox(height: 28),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Create Account",
                                  style: AppTheme.english(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "(اکاؤنٹ بنائیں)",
                                  style: AppTheme.urdu(
                                    color: AppColors.accentLime,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: AppColors.accentLime,
                                  size: 16,
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleField({
    required String label,
    required String urduHint,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          children: [
            Text(
              label,
              style: AppTheme.english(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            Text(
              urduHint,
              style: AppTheme.urdu(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: AppTheme.english(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hint,
            hintStyle: AppTheme.english(
              fontSize: 12,
              color: AppColors.textLight,
            ),
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
          ),
        ),
      ],
    );
  }

  Widget _buildDistrictField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          children: [
            Text(
              "District / Area",
              style: AppTheme.english(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            Text(
              "(ضلع)",
              style: AppTheme.urdu(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: _showDistrictPicker,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, color: AppColors.primaryMedium, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _districtController.text,
                    style: AppTheme.english(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down_rounded, color: AppColors.textMuted, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          children: [
            Text(
              "Password",
              style: AppTheme.english(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            Text(
              "(پاس ورڈ)",
              style: AppTheme.urdu(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: AppTheme.english(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return "Please enter your password";
            if (v.length < 4) return "Password must be at least 4 characters";
            return null;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: "••••••••",
            hintStyle: AppTheme.english(
              fontSize: 12,
              color: AppColors.textLight,
            ),
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primaryMedium, size: 18),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 18,
                color: AppColors.textMuted,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
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
          ),
        ),
      ],
    );
  }

  Widget _buildLicenseUploadBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          children: [
            Text(
              "Agri Dealer License Document / Photo",
              style: AppTheme.english(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            Text(
              "(لائسنس کی تصویر اپلوڈ کریں)",
              style: AppTheme.urdu(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () {
            setState(() {
              _isLicenseUploaded = !_isLicenseUploaded;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isLicenseUploaded
                      ? "Agri License photo selected successfully!"
                      : "License photo removed",
                ),
                backgroundColor: AppColors.primaryDark,
                duration: const Duration(seconds: 1),
              ),
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: _isLicenseUploaded ? const Color(0xFFF0FDF4) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _isLicenseUploaded ? const Color(0xFF86EFAC) : AppColors.borderLight,
                style: BorderStyle.solid,
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _isLicenseUploaded
                        ? const Color(0xFFDCFCE7)
                        : AppColors.primaryMedium.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _isLicenseUploaded ? Icons.task_alt_rounded : Icons.upload_file_rounded,
                    color: _isLicenseUploaded ? const Color(0xFF16A34A) : AppColors.primaryMedium,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isLicenseUploaded
                            ? "FSC-License-Multan-2024.jpg (Attached)"
                            : "Tap to upload license photo or PDF",
                        style: AppTheme.english(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _isLicenseUploaded ? const Color(0xFF16A34A) : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isLicenseUploaded
                            ? "FSC&RD / Punjab Agri Department Certificate"
                            : "Supported: JPG, PNG, PDF up to 10MB",
                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _isLicenseUploaded ? Icons.edit_rounded : Icons.camera_alt_outlined,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

