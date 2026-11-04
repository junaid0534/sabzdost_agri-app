import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../models/agri_product_model.dart';
import '../services/product_firebase_service.dart';
import '../widgets/product_safe_image.dart';

/// Dedicated, clean-header Product Detail Screen for Dealers.
/// Allows viewing complete product specifications, description, and live stock toggle.
class DealerProductDetailScreen extends StatefulWidget {
  final AgriProductModel product;
  final bool? isUrdu;

  const DealerProductDetailScreen({
    super.key,
    required this.product,
    this.isUrdu,
  });

  @override
  State<DealerProductDetailScreen> createState() => _DealerProductDetailScreenState();
}

class _DealerProductDetailScreenState extends State<DealerProductDetailScreen> {
  late bool _isUrdu;
  late AgriProductModel _product;
  late bool _inStock;
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Strictly English for Dealer Section as requested
    _isUrdu = false;
    _product = widget.product;
    _inStock = widget.product.inStock;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleStock(bool newValue) {
    setState(() {
      _inStock = newValue;
      _product = _product.copyWith(inStock: newValue);
    });

    // Realtime update in Firebase Firestore
    ProductFirebaseService.instance.toggleStock(_product.id, newValue);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newValue
              ? (_isUrdu ? "${_product.getName(_isUrdu)} اب اسٹاک میں دستیاب ہے" : "${_product.nameEnglish} marked In Stock")
              : (_isUrdu ? "${_product.getName(_isUrdu)} اسٹاک ختم مارک کر دیا گیا" : "${_product.nameEnglish} marked Out of Stock"),
        ),
        duration: const Duration(milliseconds: 900),
        backgroundColor: newValue ? const Color(0xFF16A34A) : AppColors.alertSoftRed,
      ),
    );
  }

  Color get _categoryColor {
    switch (_product.category) {
      case AgriProductCategory.seeds:
        return const Color(0xFF16A34A);
      case AgriProductCategory.fertilizers:
        return const Color(0xFF0284C7);
      case AgriProductCategory.sprays:
        return const Color(0xFFEA580C);
      case AgriProductCategory.all:
        return AppColors.primaryDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context, _product);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildCleanAppBar(),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. PRODUCT IMAGE
              _buildProductImageSection(),

              const SizedBox(height: 10),

              // 2. PRODUCT TITLE, COMPANY & PRICE
              _buildTitleAndPriceSection(),

              const SizedBox(height: 10),

              // 3. DESCRIPTION (Directly below Image & Name as requested)
              _buildDescriptionSection(),

              const SizedBox(height: 10),

              // 4. LIVE STOCK STATUS & AVAILABILITY CARD
              _buildStockToggleCard(),

              const SizedBox(height: 10),

              // 5. PRODUCT SPECIFICATIONS (Pack size, Dosage, Target, Rating)
              _buildSpecGridSection(),

              const SizedBox(height: 10),

              // 6. DEALER & STORE DETAILS
              _buildStoreDetailsSection(),

              const SizedBox(height: 14),

              // 7. BOTTOM ACTION BUTTON
              _buildBottomActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 1. CLEAN APPBAR
  // -------------------------------------------------------------
  PreferredSizeWidget _buildCleanAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark, size: 20),
        onPressed: () => Navigator.pop(context, _product),
      ),
      title: Text(
        "Product Details",
        style: AppTheme.english(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
      ),
      centerTitle: true,
      actions: [
        // In-Stock mini animated badge
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(vertical: 13),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: _inStock ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _inStock ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
              width: 0.8,
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: _inStock ? const Color(0xFF16A34A) : AppColors.alertSoftRed,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  fontSize: 9.2,
                  fontWeight: FontWeight.w800,
                  color: _inStock ? const Color(0xFF15803D) : AppColors.alertSoftRed,
                ),
                child: Text(_inStock ? "In Stock" : "Out of Stock"),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
      ],
    );
  }

  // -------------------------------------------------------------
  // 2. PRODUCT IMAGE SECTION (1 to 5 Photos Carousel, No Crop)
  // -------------------------------------------------------------
  Widget _buildProductImageSection() {
    final images = _product.allImages.isNotEmpty ? _product.allImages : [_product.imageUrl];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Image Carousel (fit: BoxFit.contain, no cropping)
          ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: SizedBox(
              height: 210,
              width: double.infinity,
              child: PageView.builder(
                controller: _pageController,
                itemCount: images.length,
                onPageChanged: (idx) => setState(() => _currentImageIndex = idx),
                itemBuilder: (context, index) {
                  return Container(
                    color: const Color(0xFFF8FAFC),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ProductSafeImage(
                      imageUrl: images[index],
                      category: _product.category,
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
            ),
          ),

          // Category Badge (Top Left)
          Positioned(
            top: 9,
            left: 9,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 3),
              decoration: BoxDecoration(
                color: _categoryColor,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                _product.category == AgriProductCategory.seeds
                    ? (_isUrdu ? "بیج" : "Seeds")
                    : _product.category == AgriProductCategory.fertilizers
                        ? (_isUrdu ? "کھاد" : "Fertilizers")
                        : (_isUrdu ? "زرعی ادویات" : "Sprays"),
                style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
          ),

          // Image Counter Pill (Top Right, if multiple)
          if (images.length > 1)
            Positioned(
              top: 9,
              right: 9,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.collections_rounded, size: 10, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      "${_currentImageIndex + 1}/${images.length}",
                      style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

          // Official FSC&RD Tag (Bottom Left)
          Positioned(
            bottom: 9,
            left: 9,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified_rounded, size: 12, color: AppColors.accentLime),
                  const SizedBox(width: 4),
                  Text(
                    _isUrdu ? "حکومتی تصدیق شدہ" : "FSC&RD Certified",
                    style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // Dots Indicator (Bottom Right, if multiple)
          if (images.length > 1)
            Positioned(
              bottom: 9,
              right: 9,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(images.length, (idx) {
                  final isCurrent = idx == _currentImageIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(left: 3),
                    width: isCurrent ? 14 : 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isCurrent ? _categoryColor : Colors.black26,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 3. PRODUCT TITLE, COMPANY & PRICE
  // -------------------------------------------------------------
  Widget _buildTitleAndPriceSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Product Name & Company
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _product.getName(_isUrdu),
                      style: _isUrdu
                          ? AppTheme.urdu(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppColors.textDark)
                          : AppTheme.english(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.business_rounded, size: 12, color: _categoryColor),
                        const SizedBox(width: 4),
                        Text(
                          _product.getCompany(_isUrdu),
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _categoryColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Pack Size Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Text(
                  _product.getPackSize(_isUrdu),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Price Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isUrdu ? "سرکاری ریٹیل ریٹ:" : "Official Retail Price:",
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    "Rs. ${_product.price.toInt()}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
                  ),
                  if (_product.originalPrice > _product.price) ...[
                    const SizedBox(width: 5),
                    Text(
                      "Rs. ${_product.originalPrice.toInt()}",
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textLight,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 4. DESCRIPTION (Directly below Image & Name as requested)
  // -------------------------------------------------------------
  Widget _buildDescriptionSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_outlined, size: 14, color: AppColors.primaryDark),
              const SizedBox(width: 5),
              Text(
                _isUrdu ? "پروڈکٹ کی تفصیل و خصوصیات" : "Product Description",
                style: _isUrdu
                    ? AppTheme.urdu(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark)
                    : AppTheme.english(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              _product.getDescription(_isUrdu),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textDark,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 5. LIVE STOCK TOGGLE CARD
  // -------------------------------------------------------------
  Widget _buildStockToggleCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: _inStock ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _inStock ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _inStock ? const Color(0xFF16A34A) : AppColors.alertSoftRed,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: _inStock ? const Color(0xFF15803D) : AppColors.alertSoftRed,
                    ),
                    child: Text(
                      _inStock
                          ? (_isUrdu ? "اسٹاک دستیاب ہے (ایکٹو)" : "In Stock (Available)")
                          : (_isUrdu ? "اسٹاک ختم ہے (غیر فعال)" : "Out of Stock (Inactive)"),
                    ),
                  ),
                  Text(
                    _isUrdu ? "کسانوں کے لیے آن لائن ڈیمانڈ دستیاب ہے" : "Available for farmer orders & queries",
                    style: const TextStyle(fontSize: 9.2, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 22,
            width: 36,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Switch.adaptive(
                value: _inStock,
                activeThumbColor: const Color(0xFF16A34A),
                activeTrackColor: const Color(0xFFBBF7D0),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFCBD5E1),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: _toggleStock,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 6. SPECIFICATIONS GRID
  // -------------------------------------------------------------
  Widget _buildSpecGridSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isUrdu ? "زرعی ہدایات و پیمائش" : "Specifications & Agri Dosage",
            style: _isUrdu
                ? AppTheme.urdu(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark)
                : AppTheme.english(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
          ),
          const SizedBox(height: 6),
          _buildSpecRow(
            icon: Icons.inventory_2_outlined,
            label: _isUrdu ? "پیکنگ سائز" : "Pack Size",
            value: _product.getPackSize(_isUrdu),
          ),
          const Divider(height: 10),
          _buildSpecRow(
            icon: Icons.science_outlined,
            label: _isUrdu ? "تجویز کردہ مقدار" : "Dosage / Acre",
            value: _product.getDosage(_isUrdu),
          ),
          const Divider(height: 10),
          _buildSpecRow(
            icon: Icons.track_changes_outlined,
            label: _isUrdu ? "ہدف / فصل کا فائدہ" : "Target & Benefit",
            value: _product.getTarget(_isUrdu),
          ),
          const Divider(height: 10),
          _buildSpecRow(
            icon: Icons.star_outline_rounded,
            label: _isUrdu ? "کسان ریٹنگ" : "Farmer Rating",
            value: "⭐ ${_product.rating} (${_product.reviewsCount} reviews)",
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow({required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primaryDark),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // 7. STORE & SELLER DETAILS
  // -------------------------------------------------------------
  Widget _buildStoreDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isUrdu ? "سیلر شاپ کی معلومات" : "Seller & Shop Info",
            style: _isUrdu
                ? AppTheme.urdu(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark)
                : AppTheme.english(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
          ),
          const SizedBox(height: 6),
          _buildSpecRow(
            icon: Icons.storefront_outlined,
            label: _isUrdu ? "دکان کا نام" : "Shop Name",
            value: _product.getDealerName(_isUrdu),
          ),
          const Divider(height: 10),
          _buildSpecRow(
            icon: Icons.location_on_outlined,
            label: _isUrdu ? "ایڈریس" : "Market Location",
            value: _product.getDealerLocation(_isUrdu),
          ),
          const Divider(height: 10),
          _buildSpecRow(
            icon: Icons.phone_outlined,
            label: _isUrdu ? "رابطہ نمبر" : "Helpline Phone",
            value: _product.dealerPhone,
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 8. BOTTOM ACTION BUTTONS
  // -------------------------------------------------------------
  Widget _buildBottomActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context, _product),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 9.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              side: const BorderSide(color: AppColors.borderLight),
            ),
            child: Text(
              _isUrdu ? "کیٹلاگ پر جائیں" : "Back to Catalog",
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () => _toggleStock(!_inStock),
            icon: Icon(
              _inStock ? Icons.remove_circle_outline_rounded : Icons.check_circle_outline_rounded,
              size: 15,
              color: Colors.white,
            ),
            label: Text(
              _inStock
                  ? (_isUrdu ? "اسٹاک ختم مارک کریں" : "Mark Out of Stock")
                  : (_isUrdu ? "اسٹاک میں شامل کریں" : "Mark In Stock"),
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _inStock ? AppColors.alertSoftRed : const Color(0xFF16A34A),
              padding: const EdgeInsets.symmetric(vertical: 9.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }
}
