import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../auth/controllers/user_session_controller.dart';
import '../models/agri_product_model.dart';
import '../services/product_firebase_service.dart';
import '../widgets/product_safe_image.dart';

class DealerAddProductScreen extends StatefulWidget {
  final bool? isUrdu;

  const DealerAddProductScreen({super.key, this.isUrdu});

  @override
  State<DealerAddProductScreen> createState() => _DealerAddProductScreenState();
}

class _DealerAddProductScreenState extends State<DealerAddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  // Strictly English for Dealer Section as requested
  bool get _isUrdu => false;

  AgriProductCategory _selectedCategory = AgriProductCategory.seeds;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _originalPriceController = TextEditingController();
  final TextEditingController _packSizeController = TextEditingController(text: "50 kg Bag");
  final TextEditingController _stockCountController = TextEditingController(text: "50");
  final TextEditingController _dosageController = TextEditingController(text: "50 kg per acre");
  final TextEditingController _targetController = TextEditingController(text: "High Yield & Crop Protection");
  final TextEditingController _descriptionController = TextEditingController();

  bool _inStock = true;
  String _selectedImageSample = "https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?q=80&w=400&auto=format&fit=crop";
  String _selectedTag = "Blue Tag (Certified)";

  // Multi-image state: supports 1 to 5 images from Camera & Gallery
  final List<String> _productImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  final List<String> _commonCompanies = [
    "Punjab Seed Corporation",
    "Engro Fertilizers Ltd",
    "Fauji Fertilizer Company (FFC)",
    "Fatima Fertilizer Group",
    "Corteva Agriscience (Pioneer)",
    "Four Brothers Agri Services",
    "Guard Agricultural Research",
    "Syngenta Pakistan",
    "Bayer CropScience",
    "FMC United Ag",
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _packSizeController.dispose();
    _stockCountController.dispose();
    _dosageController.dispose();
    _targetController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(AgriProductCategory cat) {
    setState(() {
      _selectedCategory = cat;
      if (cat == AgriProductCategory.seeds) {
        _selectedImageSample = "https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?q=80&w=400&auto=format&fit=crop";
        _packSizeController.text = "50 kg Bag";
        _dosageController.text = "50 kg per acre";
      } else if (cat == AgriProductCategory.fertilizers) {
        _selectedImageSample = "https://images.unsplash.com/photo-1585314062340-f1a5a7c9328d?q=80&w=400&auto=format&fit=crop";
        _packSizeController.text = "50 kg Bag";
        _dosageController.text = "1 to 2 bags per acre";
      } else {
        _selectedImageSample = "https://images.unsplash.com/photo-1587293852726-70cdb56c2866?q=80&w=400&auto=format&fit=crop";
        _packSizeController.text = "1 Litre Bottle";
        _dosageController.text = "250 ml in 100L water / acre";
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_productImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Maximum 5 images allowed per product."),
          backgroundColor: Color(0xFFD97706),
        ),
      );
      return;
    }

    try {
      if (source == ImageSource.gallery) {
        final remaining = 5 - _productImages.length;
        final pickedList = await _picker.pickMultiImage(
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 70,
          limit: remaining,
        );
        if (pickedList.isNotEmpty) {
          for (final file in pickedList.take(remaining)) {
            final bytes = await file.readAsBytes();
            final base64String = "data:image/jpeg;base64,${base64Encode(bytes)}";
            _productImages.add(base64String);
          }
          if (mounted) setState(() {});
        }
      } else {
        final picked = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 70,
        );
        if (picked != null) {
          final bytes = await picked.readAsBytes();
          final base64String = "data:image/jpeg;base64,${base64Encode(bytes)}";
          if (mounted) {
            setState(() {
              _productImages.add(base64String);
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Image pick error: $e");
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Upload Product Photos (1 to 5)",
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                  ),
                  Text(
                    "${_productImages.length}/5",
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF16A34A)),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              const Text(
                "Take a photo with camera or choose high-res packaging from gallery.",
                style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickImage(ImageSource.camera);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.camera_alt_rounded, size: 22, color: Color(0xFF15803D)),
                            SizedBox(height: 4),
                            Text(
                              "Camera",
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF15803D)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickImage(ImageSource.gallery);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF7DD3FC)),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.photo_library_rounded, size: 22, color: Color(0xFF0284C7)),
                            SizedBox(height: 4),
                            Text(
                              "Gallery",
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0284C7)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSaveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final price = double.tryParse(_priceController.text.trim()) ?? 5000;
      final origPrice = double.tryParse(_originalPriceController.text.trim()) ?? (price + 400);

      final images = _productImages.isNotEmpty ? _productImages : [_selectedImageSample];

      final newProduct = AgriProductModel(
        id: "prod-${DateTime.now().millisecondsSinceEpoch}",
        nameEnglish: _nameController.text.trim(),
        nameUrdu: _nameController.text.trim(),
        category: _selectedCategory,
        companyEnglish: _companyController.text.trim().isNotEmpty
            ? _companyController.text.trim()
            : "Authorized Agri Brand",
        companyUrdu: _companyController.text.trim().isNotEmpty
            ? _companyController.text.trim()
            : "اتھارائزڈ زرعی برانڈ",
        packSizeEnglish: _packSizeController.text.trim(),
        packSizeUrdu: _packSizeController.text.trim(),
        price: price,
        originalPrice: origPrice,
        rating: 5.0,
        reviewsCount: 1,
        inStock: _inStock,
        descriptionEnglish: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : "Government approved certified agricultural input with high quality standard.",
        descriptionUrdu: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : "حکومت سے تصدیق شدہ زرعی پروڈکٹ، بہترین پیداواری معیار۔",
        dosageEnglish: _dosageController.text.trim(),
        dosageUrdu: _dosageController.text.trim(),
        targetEnglish: _targetController.text.trim(),
        targetUrdu: _targetController.text.trim(),
        dealerNameEnglish: UserSessionController.instance.businessOrFarmName.isNotEmpty
            ? UserSessionController.instance.businessOrFarmName
            : "Chaudhry Agri Store",
        dealerNameUrdu: "چوہدری ایگرو سینٹر",
        dealerPhone: UserSessionController.instance.userPhone.isNotEmpty
            ? UserSessionController.instance.userPhone
            : "0300-8472910",
        dealerLocationEnglish: "Grain Market, Multan",
        dealerLocationUrdu: "غلہ منڈی، ملتان",
        imageUrl: images.first,
        imageUrls: images,
      );

      // Save to Firebase Firestore 'products' table in Realtime!
      await ProductFirebaseService.instance.saveProduct(newProduct);

      if (mounted) {
        Navigator.pop(context, newProduct);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isUrdu
                  ? "${newProduct.getName(_isUrdu)} کامیابی سے فائر بیس میں شامل ہو گیا!"
                  : "${newProduct.nameEnglish} saved in Realtime to Firebase!",
            ),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error saving product: $e"),
            backgroundColor: AppColors.alertSoftRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildCleanHeaderAppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Category Selection Cards
                  Text(
                    _isUrdu ? "پروڈکٹ کیٹیگری منتخب کریں:" : "Select Product Category:",
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      _buildCategoryCard(
                        category: AgriProductCategory.seeds,
                        title: _isUrdu ? "بیج (Seeds)" : "Seeds",
                        icon: Icons.spa_rounded,
                        color: const Color(0xFF16A34A),
                      ),
                      const SizedBox(width: 7),
                      _buildCategoryCard(
                        category: AgriProductCategory.fertilizers,
                        title: _isUrdu ? "کھاد (Fertilizer)" : "Fertilizers",
                        icon: Icons.science_rounded,
                        color: const Color(0xFF0284C7),
                      ),
                      const SizedBox(width: 7),
                      _buildCategoryCard(
                        category: AgriProductCategory.sprays,
                        title: _isUrdu ? "سپرے (Spray)" : "Sprays",
                        icon: Icons.sanitizer_rounded,
                        color: const Color(0xFFEA580C),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 2. Product Photo Upload Box
                  _buildPhotoUploadSection(),
                  const SizedBox(height: 12),

                  // 3. Product Basic Details Section
                  _buildSectionHeader(_isUrdu ? "پروڈکٹ کی بنیادی معلومات" : "Basic Information"),
                  const SizedBox(height: 8),

                  // Product Title
                  _buildInputField(
                    label: _isUrdu ? "پروڈکٹ و ورائٹی کا نام" : "Product & Variety Name",
                    hint: _isUrdu ? "مثلاً اکبر-۱۹ تصدیق شدہ گندم" : "e.g. Akbar-19 Certified Wheat",
                    icon: Icons.label_outline_rounded,
                    controller: _nameController,
                    validator: (v) => v == null || v.trim().isEmpty ? "Please enter product name" : null,
                  ),
                  const SizedBox(height: 10),

                  // Company Selection / Input
                  _buildCompanyField(),
                  const SizedBox(height: 10),

                  // Price & Original Price Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          label: _isUrdu ? "حتمی قیمت (Rs.)" : "Final Price (Rs.)",
                          hint: "5200",
                          icon: Icons.payments_outlined,
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || v.trim().isEmpty ? "Enter price" : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInputField(
                          label: _isUrdu ? "اصل قیمت (Cut Price)" : "Original Rate (Rs.)",
                          hint: "5600",
                          icon: Icons.price_change_outlined,
                          controller: _originalPriceController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Pack Size & Initial Stock Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          label: _isUrdu ? "پیک سائز" : "Pack Size",
                          hint: "50 kg Bag",
                          icon: Icons.inventory_2_outlined,
                          controller: _packSizeController,
                          validator: (v) => v == null || v.trim().isEmpty ? "Enter pack size" : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInputField(
                          label: _isUrdu ? "دستیاب بیگز (اسٹاک)" : "Available Stock Count",
                          hint: "50 Bags",
                          icon: Icons.numbers_rounded,
                          controller: _stockCountController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 4. Agronomy Guidance Details
                  _buildSectionHeader(_isUrdu ? "زرعی سفارشات و استعمال" : "Agronomy & Usage Recommendations"),
                  const SizedBox(height: 8),

                  // Per Acre Dosage
                  _buildInputField(
                    label: _isUrdu ? "فی ایکڑ مقدار (Dosage)" : "Per Acre Recommended Dosage",
                    hint: "50 kg per acre",
                    icon: Icons.medical_services_outlined,
                    controller: _dosageController,
                  ),
                  const SizedBox(height: 10),

                  // Target Benefits
                  _buildInputField(
                    label: _isUrdu ? "ہدف و خاصیت (Target Benefits)" : "Key Target / Trait",
                    hint: "Rust Resistant / High Yield",
                    icon: Icons.verified_outlined,
                    controller: _targetController,
                  ),
                  const SizedBox(height: 10),

                  // Official Tag Selection (Seeds only)
                  if (_selectedCategory == AgriProductCategory.seeds) ...[
                    _buildTagSelector(),
                    const SizedBox(height: 10),
                  ],

                  // Description
                  _buildInputField(
                    label: _isUrdu ? "اضافی تفصیل (Description)" : "Additional Description",
                    hint: _isUrdu ? "پروڈکٹ کے بارے میں کسانوں کیلئے ہدایات..." : "Enter key details for farmers...",
                    icon: Icons.notes_rounded,
                    controller: _descriptionController,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),

                  // 5. In-Stock Availability Switch
                  _buildStockToggleCard(),
                  const SizedBox(height: 18),

                  // 6. Save & Publish Button (Comfortable, well-proportioned)
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _handleSaveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
                        elevation: 1.5,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      icon: _isSaving
                          ? const SizedBox(
                              width: 17,
                              height: 17,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.check_circle_rounded, color: AppColors.accentLime, size: 19),
                      label: Text(
                        _isSaving
                            ? (_isUrdu ? "محفوظ ہو رہا ہے..." : "Saving to Cloud...")
                            : (_isUrdu ? "پروڈکٹ دکان میں شامل کریں" : "Save & Publish to Store"),
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Colors.white),
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

  // -------------------------------------------------------------
  // CLEAN HEADER APPBAR
  // -------------------------------------------------------------
  PreferredSizeWidget _buildCleanHeaderAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 50,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryDark, size: 21),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: Text(
        "Add New Product",
        style: AppTheme.english(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
    );
  }

  Widget _buildCategoryCard({
    required AgriProductCategory category,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedCategory == category;
    return Expanded(
      child: InkWell(
        onTap: () => _onCategoryChanged(category),
        borderRadius: BorderRadius.circular(11),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: isSelected ? color : AppColors.borderLight,
              width: 1.3,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: isSelected ? Colors.white : color),
              const SizedBox(height: 4),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoUploadSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.photo_library_outlined, size: 15, color: AppColors.primaryMedium),
                  const SizedBox(width: 5),
                  Text(
                    _isUrdu ? "پروڈکٹ کی تصاویر (1 تا 5)" : "Product Photos (1 to 5)",
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textDark),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _productImages.isNotEmpty ? const Color(0xFFDCFCE7) : AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _productImages.isNotEmpty ? const Color(0xFF86EFAC) : AppColors.borderLight,
                  ),
                ),
                child: Text(
                  "${_productImages.length}/5",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: _productImages.isNotEmpty ? const Color(0xFF15803D) : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _isUrdu
                ? "کیمرہ یا گیلری سے پیکنگ کی واضح تصاویر لگائیں۔ پہلی تصویر کارڈ پر نظر آئے گی۔"
                : "Add up to 5 clear photos (front, back, label). 1st photo is cover.",
            style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),

          // Horizontal image row / add buttons
          SizedBox(
            height: 74,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                // Render already added images
                ...List.generate(_productImages.length, (index) {
                  final img = _productImages[index];
                  final isPrimary = index == 0;
                  return Container(
                    width: 68,
                    margin: const EdgeInsets.only(right: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: isPrimary ? AppColors.primaryMedium : AppColors.borderLight,
                        width: isPrimary ? 1.4 : 1.0,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(3.5),
                              child: ProductSafeImage(
                                imageUrl: img,
                                category: _selectedCategory,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        // Primary badge
                        if (isPrimary)
                          Positioned(
                            bottom: 2,
                            left: 2,
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.primaryDark.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                "Cover",
                                style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            ),
                          ),
                        // Delete button
                        Positioned(
                          top: 2,
                          right: 2,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _productImages.removeAt(index);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close_rounded, size: 11, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Add button if less than 5
                if (_productImages.length < 5)
                  InkWell(
                    onTap: _showImageSourcePicker,
                    borderRadius: BorderRadius.circular(9),
                    child: Container(
                      width: 68,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: AppColors.primaryMedium.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_a_photo_outlined, size: 20, color: AppColors.primaryDark),
                          const SizedBox(height: 3),
                          Text(
                            _isUrdu ? "+ تصویر" : "+ Add",
                            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputField(
          label: _isUrdu ? "کمپنی / برانڈ" : "Company / Manufacturer",
          hint: "e.g. Punjab Seed Corporation / Engro",
          icon: Icons.business_rounded,
          controller: _companyController,
          validator: (v) => v == null || v.trim().isEmpty ? "Please enter company" : null,
        ),
        const SizedBox(height: 5),
        // Quick Company suggestions pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _commonCompanies.map((comp) {
              return Padding(
                padding: const EdgeInsets.only(right: 5),
                child: ActionChip(
                  label: Text(comp, style: const TextStyle(fontSize: 10)),
                  backgroundColor: AppColors.surfaceAlt,
                  side: BorderSide(color: AppColors.borderLight.withValues(alpha: 0.6)),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    setState(() => _companyController.text = comp);
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTagSelector() {
    final tags = [
      "Blue Tag (Certified)",
      "Green Tag (Foundation)",
      "White Tag (Breeder)",
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isUrdu ? "FSC&RD سرٹیفیکیشن ٹیگ" : "FSC&RD Certification Tag:",
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textDark),
        ),
        const SizedBox(height: 4),
        Row(
          children: tags.map((t) {
            final isSel = _selectedTag == t;
            return Expanded(
              child: InkWell(
                onTap: () => setState(() => _selectedTag = t),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFF16A34A).withValues(alpha: 0.12) : Colors.white,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: isSel ? const Color(0xFF16A34A) : AppColors.borderLight),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    t.split(' ').first,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isSel ? const Color(0xFF16A34A) : AppColors.textDark,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStockToggleCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                _inStock ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: _inStock ? const Color(0xFF16A34A) : AppColors.alertSoftRed,
                size: 19,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _inStock
                        ? (_isUrdu ? "اسٹاک دستیاب ہے (In Stock)" : "Currently In Stock")
                        : (_isUrdu ? "اسٹاک ختم ہے (Out of Stock)" : "Currently Out of Stock"),
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textDark),
                  ),
                  Text(
                    _isUrdu ? "کسانوں کو دکان میں دکھائی دے گا" : "Visible to nearby farmers",
                    style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: _inStock,
              onChanged: (val) => setState(() => _inStock = val),
              activeThumbColor: const Color(0xFF16A34A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textDark),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 11, color: AppColors.textLight),
            prefixIcon: Icon(icon, size: 17, color: AppColors.primaryMedium),
            prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9.5),
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}
