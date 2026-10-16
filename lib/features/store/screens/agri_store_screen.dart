import 'package:flutter/material.dart';
import '../../../core/localization/language_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gemini_smart_search_bar.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../data/mock_agri_products.dart';
import '../models/agri_product_model.dart';

class AgriStoreScreen extends StatefulWidget {
  final AgriProductCategory initialCategory;
  final bool? isUrdu;

  const AgriStoreScreen({
    super.key,
    this.initialCategory = AgriProductCategory.all,
    this.isUrdu,
  });

  @override
  State<AgriStoreScreen> createState() => _AgriStoreScreenState();
}

class _AgriStoreScreenState extends State<AgriStoreScreen> {
  late AgriProductCategory _selectedCategory;
  String _searchQuery = "";
  bool get _isUrdu => widget.isUrdu ?? LanguageController.instance.isUrdu;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  List<AgriProductModel> get _filteredProducts {
    return MockAgriProducts.allProducts.where((p) {
      final matchesCategory = _selectedCategory == AgriProductCategory.all || p.category == _selectedCategory;
      if (!matchesCategory) return false;

      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase().trim();

      final inName = p.nameEnglish.toLowerCase().contains(q) || p.nameUrdu.contains(q);
      final inCompany = p.companyEnglish.toLowerCase().contains(q) || p.companyUrdu.contains(q);
      final inTarget = p.targetEnglish.toLowerCase().contains(q) || p.targetUrdu.contains(q);
      final inLocation = p.dealerLocationEnglish.toLowerCase().contains(q) || p.dealerLocationUrdu.contains(q);

      return inName || inCompany || inTarget || inLocation;
    }).toList();
  }

  void _showProductDetails(AgriProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.borderLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Header Row: Category Badge & Stock
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(product.category).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _getCategoryColor(product.category).withValues(alpha: 0.25)),
                        ),
                        child: Text(
                          _isUrdu ? product.categoryNameUrdu : product.categoryNameEnglish,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: _getCategoryColor(product.category),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: product.inStock
                              ? AppColors.successGreen.withValues(alpha: 0.12)
                              : AppColors.alertSoftRed.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              product.inStock ? Icons.check_circle_rounded : Icons.cancel_rounded,
                              size: 13,
                              color: product.inStock ? AppColors.successGreen : AppColors.alertSoftRed,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.inStock
                                  ? (_isUrdu ? "اسٹاک دستیاب ہے" : "In Stock")
                                  : (_isUrdu ? "اسٹاک ختم" : "Out of Stock"),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: product.inStock ? AppColors.successGreen : AppColors.alertSoftRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Product Title
                  Text(
                    product.getName(_isUrdu),
                    style: _isUrdu
                        ? AppTheme.urdu(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primaryDark)
                        : AppTheme.english(fontSize: 16.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                  ),
                  const SizedBox(height: 3),

                  // Company & Pack Size
                  Row(
                    children: [
                      const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF2E7D32)),
                      const SizedBox(width: 4),
                      Text(
                        product.getCompany(_isUrdu),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.getPackSize(_isUrdu),
                          style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Price Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isUrdu ? "حتمی قیمت / ریٹ:" : "Official Price:",
                              style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                            ),
                            Row(
                              children: [
                                Text(
                                  "Rs. ${product.price.toInt()}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                                if (product.originalPrice > product.price) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    "Rs. ${product.originalPrice.toInt()}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textLight,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 18, color: Color(0xFFFFA000)),
                            const SizedBox(width: 3),
                            Text(
                              "${product.rating} (${product.reviewsCount})",
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Dosage / Target Usage Guide
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.medical_services_rounded, size: 15, color: Color(0xFF15803D)),
                            const SizedBox(width: 6),
                            Text(
                              _isUrdu ? "فی ایکڑ مقدار و استعمال کا طریقہ:" : "Recommended Dosage & Target:",
                              style: _isUrdu
                                  ? AppTheme.urdu(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF15803D))
                                  : AppTheme.english(fontSize: 11.5, fontWeight: FontWeight.w700, color: const Color(0xFF15803D)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.getDosage(_isUrdu),
                          style: _isUrdu
                              ? AppTheme.urdu(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textDark)
                              : AppTheme.english(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isUrdu ? "ہدف: ${product.getTarget(_isUrdu)}" : "Target: ${product.getTarget(_isUrdu)}",
                          style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    _isUrdu ? "تفصیل:" : "Description:",
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    product.getDescription(_isUrdu),
                    style: TextStyle(fontSize: 11.5, height: 1.4, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 14),

                  // Dealer Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primaryMedium.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.storefront_rounded, size: 20, color: AppColors.primaryMedium),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.getDealerName(_isUrdu),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_rounded, size: 12, color: AppColors.textMuted),
                                  const SizedBox(width: 2),
                                  Text(
                                    product.getDealerLocation(_isUrdu),
                                    style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Action Buttons: Call Dealer + Order
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _isUrdu
                                      ? "ڈیلر کو کال کی جا رہی ہے: ${product.dealerPhone}"
                                      : "Calling dealer: ${product.dealerPhone}",
                                ),
                                backgroundColor: AppColors.primaryDark,
                              ),
                            );
                          },
                          icon: const Icon(Icons.phone_rounded, size: 16),
                          label: Text(_isUrdu ? "ڈیلر کو کال" : "Call Dealer"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryDark,
                            side: const BorderSide(color: AppColors.primaryDark),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _isUrdu
                                      ? "${product.getName(_isUrdu)} کی بکنگ درج ہو گئی!"
                                      : "${product.getName(_isUrdu)} order submitted!",
                                ),
                                backgroundColor: AppColors.successGreen,
                              ),
                            );
                          },
                          icon: const Icon(Icons.shopping_bag_rounded, size: 16),
                          label: Text(_isUrdu ? "آرڈر بک کریں" : "Book Order"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryDark,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getCategoryColor(AgriProductCategory cat) {
    switch (cat) {
      case AgriProductCategory.seeds:
        return const Color(0xFF2E7D32);
      case AgriProductCategory.fertilizers:
        return const Color(0xFF00838F);
      case AgriProductCategory.sprays:
        return const Color(0xFFE65100);
      case AgriProductCategory.all:
        return AppColors.primaryDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final filtered = _filteredProducts;

    return ResponsiveLayout(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          toolbarHeight: isLandscape ? 40 : 48,
          backgroundColor: AppColors.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryDark, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            _isUrdu ? "زرعی مارکیٹ (بیج، کھاد، سپرے)" : "Agri Inputs Store",
            style: _isUrdu
                ? AppTheme.urdu(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark)
                : AppTheme.english(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
          ),
          actions: [
            InkWell(
              onTap: () {
                LanguageController.instance.toggleLanguage();
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Text(
                  _isUrdu ? "EN" : "اردو",
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // 1. Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
              child: GeminiSmartSearchBar(
                domainContext: "Pakistan agriculture certified seeds, urea, DAP, SOP fertilizer, Syngenta, Bayer sprays, pesticides, weeds",
                hintText: _isUrdu ? "بیج، کھاد، سپرے تلاش کریں..." : "Search seeds, urea, sprays...",
                onChanged: (val) {
                  setState(() => _searchQuery = val);
                },
                onSubmitted: (query, aiResult) {
                  setState(() {
                    _searchQuery = (aiResult != null && aiResult.correctedUrdu.isNotEmpty)
                        ? aiResult.correctedUrdu
                        : query;
                  });
                },
              ),
            ),

            // 2. 4 Filter Tabs: All, Seeds, Fertilizer, Sprays
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Row(
                children: [
                  _buildCategoryTab(AgriProductCategory.all, _isUrdu ? "سبھی" : "All", Icons.dashboard_rounded),
                  const SizedBox(width: 6),
                  _buildCategoryTab(AgriProductCategory.seeds, _isUrdu ? "بیج" : "Seeds", Icons.spa_rounded),
                  const SizedBox(width: 6),
                  _buildCategoryTab(AgriProductCategory.fertilizers, _isUrdu ? "کھاد" : "Fertilizers", Icons.science_rounded),
                  const SizedBox(width: 6),
                  _buildCategoryTab(AgriProductCategory.sprays, _isUrdu ? "سپرے" : "Sprays", Icons.sanitizer_rounded),
                ],
              ),
            ),

            // 3. Products Count & City info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isUrdu ? "${filtered.length} تصدیق شدہ مصنوعات" : "${filtered.length} Certified Products",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 12, color: AppColors.primaryMedium),
                      const SizedBox(width: 3),
                      Text(
                        _isUrdu ? "ملتان و قریبی ڈیلرز" : "Multan & Nearby Dealers",
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 4. Products Grid / List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 48, color: AppColors.textLight),
                          const SizedBox(height: 8),
                          Text(
                            _isUrdu ? "کوئی پروڈکٹ نہیں ملی" : "No products found",
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return _buildProductCard(filtered[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTab(AgriProductCategory cat, String title, IconData icon) {
    final isSelected = _selectedCategory == cat;
    final catColor = _getCategoryColor(cat);

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedCategory = cat),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected ? catColor : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? catColor : AppColors.borderLight,
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13, color: isSelected ? Colors.white : catColor),
              const SizedBox(width: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: _isUrdu
                      ? AppTheme.urdu(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                          color: isSelected ? Colors.white : AppColors.textDark,
                        )
                      : AppTheme.english(
                          fontSize: 10.5,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                          color: isSelected ? Colors.white : AppColors.textDark,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(AgriProductModel product) {
    final catColor = _getCategoryColor(product.category);

    return InkWell(
      onTap: () => _showProductDetails(product),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Icon Box with category-colored tint
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: catColor.withValues(alpha: 0.20)),
              ),
              child: Center(
                child: Icon(
                  product.category == AgriProductCategory.seeds
                      ? Icons.spa_rounded
                      : product.category == AgriProductCategory.fertilizers
                          ? Icons.science_rounded
                          : Icons.sanitizer_rounded,
                  color: catColor,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Center details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand & Pack Size Pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          product.getCompany(_isUrdu),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: catColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.getPackSize(_isUrdu),
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Product Title
                  Text(
                    product.getName(_isUrdu),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _isUrdu
                        ? AppTheme.urdu(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textDark)
                        : AppTheme.english(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 2),

                  // Target info
                  Text(
                    product.getTarget(_isUrdu),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 6),

                  // Price & Action Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Rs. ${product.price.toInt()}",
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          if (product.originalPrice > product.price) ...[
                            const SizedBox(width: 5),
                            Text(
                              "Rs. ${product.originalPrice.toInt()}",
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textLight,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () => _showProductDetails(product),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceAlt,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.info_outline_rounded, size: 12, color: AppColors.primaryMedium),
                                  const SizedBox(width: 3),
                                  Text(
                                    _isUrdu ? "تفصیل" : "Details",
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _isUrdu
                                        ? "ڈیلر کو کال: ${product.dealerPhone}"
                                        : "Call Dealer: ${product.dealerPhone}",
                                  ),
                                  backgroundColor: AppColors.primaryDark,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: catColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.phone_rounded, size: 12, color: Colors.white),
                                  const SizedBox(width: 3),
                                  Text(
                                    _isUrdu ? "ڈیلر" : "Call",
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
