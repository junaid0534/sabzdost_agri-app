import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../auth/controllers/user_session_controller.dart';
import '../models/agri_product_model.dart';

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

  void _handleSaveProduct() {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceController.text.trim()) ?? 5000;
    final origPrice = double.tryParse(_originalPriceController.text.trim()) ?? (price + 400);

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
      imageUrl: _selectedImageSample,
    );

    Navigator.pop(context, newProduct);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isUrdu
              ? "${newProduct.getName(_isUrdu)} کامیابی سے دکان میں شامل ہو گیا!"
              : "${newProduct.nameEnglish} added to your inventory!",
        ),
        backgroundColor: AppColors.successGreen,
      ),
    );
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Category Selection Cards
                  Text(
                    _isUrdu ? "پروڈکٹ کیٹیگری منتخب کریں:" : "Select Product Category:",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildCategoryCard(
                        category: AgriProductCategory.seeds,
                        title: _isUrdu ? "بیج (Seeds)" : "Seeds",
                        icon: Icons.spa_rounded,
                        color: const Color(0xFF16A34A),
                      ),
                      const SizedBox(width: 8),
                      _buildCategoryCard(
                        category: AgriProductCategory.fertilizers,
                        title: _isUrdu ? "کھاد (Fertilizer)" : "Fertilizers",
                        icon: Icons.science_rounded,
                        color: const Color(0xFF0284C7),
                      ),
                      const SizedBox(width: 8),
                      _buildCategoryCard(
                        category: AgriProductCategory.sprays,
                        title: _isUrdu ? "سپرے (Spray)" : "Sprays",
                        icon: Icons.sanitizer_rounded,
                        color: const Color(0xFFEA580C),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 2. Product Photo Upload Box
                  _buildPhotoUploadSection(),
                  const SizedBox(height: 16),

                  // 3. Product Basic Details Section
                  _buildSectionHeader(_isUrdu ? "پروڈکٹ کی بنیادی معلومات" : "Basic Information"),
                  const SizedBox(height: 10),

                  // Product Title
                  _buildInputField(
                    label: _isUrdu ? "پروڈکٹ و ورائٹی کا نام" : "Product & Variety Name",
                    hint: _isUrdu ? "مثلاً اکبر-۱۹ تصدیق شدہ گندم" : "e.g. Akbar-19 Certified Wheat",
                    icon: Icons.label_outline_rounded,
                    controller: _nameController,
                    validator: (v) => v == null || v.trim().isEmpty ? "Please enter product name" : null,
                  ),
                  const SizedBox(height: 12),

                  // Company Selection / Input
                  _buildCompanyField(),
                  const SizedBox(height: 12),

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
                      const SizedBox(width: 10),
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
                  const SizedBox(height: 12),

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
                      const SizedBox(width: 10),
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
                  const SizedBox(height: 16),

                  // 4. Agronomy Guidance Details
                  _buildSectionHeader(_isUrdu ? "زرعی سفارشات و استعمال" : "Agronomy & Usage Recommendations"),
                  const SizedBox(height: 10),

                  // Per Acre Dosage
                  _buildInputField(
                    label: _isUrdu ? "فی ایکڑ مقدار (Dosage)" : "Per Acre Recommended Dosage",
                    hint: "50 kg per acre",
                    icon: Icons.medical_services_outlined,
                    controller: _dosageController,
                  ),
                  const SizedBox(height: 12),

                  // Target Benefits
                  _buildInputField(
                    label: _isUrdu ? "ہدف و خاصیت (Target Benefits)" : "Key Target / Trait",
                    hint: "Rust Resistant / High Yield",
                    icon: Icons.verified_outlined,
                    controller: _targetController,
                  ),
                  const SizedBox(height: 12),

                  // Official Tag Selection (Seeds only)
                  if (_selectedCategory == AgriProductCategory.seeds) ...[
                    _buildTagSelector(),
                    const SizedBox(height: 12),
                  ],

                  // Description
                  _buildInputField(
                    label: _isUrdu ? "اضافی تفصیل (Description)" : "Additional Description",
                    hint: _isUrdu ? "پروڈکٹ کے بارے میں کسانوں کیلئے ہدایات..." : "Enter key details for farmers...",
                    icon: Icons.notes_rounded,
                    controller: _descriptionController,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 14),

                  // 5. In-Stock Availability Switch
                  _buildStockToggleCard(),
                  const SizedBox(height: 24),

                  // 6. Large Save & Publish Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _handleSaveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.check_circle_rounded, color: AppColors.accentLime, size: 20),
                      label: Text(
                        _isUrdu ? "پروڈکٹ دکان میں شامل کریں" : "Save & Publish to Store",
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
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

  // -------------------------------------------------------------
  // CLEAN HEADER APPBAR
  // -------------------------------------------------------------
  PreferredSizeWidget _buildCleanHeaderAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryDark, size: 22),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: Text(
        "Add New Product",
        style: AppTheme.english(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
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
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : AppColors.borderLight,
              width: 1.4,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(icon, size: 22, color: isSelected ? Colors.white : color),
              const SizedBox(height: 5),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          // Image Preview
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 64,
              height: 64,
              child: Image.network(
                _selectedImageSample,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: AppColors.surfaceAlt,
                  child: const Icon(Icons.image_outlined, size: 24, color: AppColors.textMuted),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Upload Label & Button
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isUrdu ? "پروڈکٹ کی تصویر" : "Product Photo",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
                const SizedBox(height: 2),
                Text(
                  _isUrdu ? "کیٹلاگ تصویر منتخب ہے" : "Official high-res image attached",
                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_isUrdu ? "تصویر تبدیل کر دی گئی ہے" : "Photo updated from camera / gallery"),
                        backgroundColor: AppColors.primaryDark,
                        duration: const Duration(milliseconds: 800),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.camera_alt_rounded, size: 12, color: AppColors.primaryMedium),
                        const SizedBox(width: 4),
                        Text(
                          _isUrdu ? "تصویر تبدیل کریں" : "Change Photo",
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
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
        const SizedBox(height: 6),
        // Quick Company suggestions pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _commonCompanies.map((comp) {
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ActionChip(
                  label: Text(comp, style: const TextStyle(fontSize: 10)),
                  backgroundColor: AppColors.surfaceAlt,
                  side: BorderSide(color: AppColors.borderLight.withValues(alpha: 0.6)),
                  padding: EdgeInsets.zero,
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
                    borderRadius: BorderRadius.circular(8),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
                size: 20,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _inStock
                        ? (_isUrdu ? "اسٹاک دستیاب ہے (In Stock)" : "Currently In Stock")
                        : (_isUrdu ? "اسٹاک ختم ہے (Out of Stock)" : "Currently Out of Stock"),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textDark),
                  ),
                  Text(
                    _isUrdu ? "کسانوں کو دکان میں دکھائی دے گا" : "Visible to nearby farmers",
                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: _inStock,
            onChanged: (val) => setState(() => _inStock = val),
            activeThumbColor: const Color(0xFF16A34A),
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
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textDark),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 11.5, color: AppColors.textLight),
            prefixIcon: Icon(icon, size: 18, color: AppColors.primaryMedium),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
