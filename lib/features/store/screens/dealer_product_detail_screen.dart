import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../models/agri_product_model.dart';

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

  @override
  void initState() {
    super.initState();
    // Strictly English for Dealer Section as requested
    _isUrdu = false;
    _product = widget.product;
    _inStock = widget.product.inStock;
  }

  void _toggleStock(bool newValue) {
    setState(() {
      _inStock = newValue;
      _product = AgriProductModel(
        id: _product.id,
        nameEnglish: _product.nameEnglish,
        nameUrdu: _product.nameUrdu,
        category: _product.category,
        companyEnglish: _product.companyEnglish,
        companyUrdu: _product.companyUrdu,
        packSizeEnglish: _product.packSizeEnglish,
        packSizeUrdu: _product.packSizeUrdu,
        price: _product.price,
        originalPrice: _product.originalPrice,
        rating: _product.rating,
        reviewsCount: _product.reviewsCount,
        inStock: newValue,
        descriptionEnglish: _product.descriptionEnglish,
        descriptionUrdu: _product.descriptionUrdu,
        dosageEnglish: _product.dosageEnglish,
        dosageUrdu: _product.dosageUrdu,
        targetEnglish: _product.targetEnglish,
        targetUrdu: _product.targetUrdu,
        dealerNameEnglish: _product.dealerNameEnglish,
        dealerNameUrdu: _product.dealerNameUrdu,
        dealerPhone: _product.dealerPhone,
        dealerLocationEnglish: _product.dealerLocationEnglish,
        dealerLocationUrdu: _product.dealerLocationUrdu,
        imageUrl: _product.imageUrl,
      );
    });

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
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. PRODUCT IMAGE
              _buildProductImageSection(),

              const SizedBox(height: 12),

              // 2. PRODUCT TITLE, COMPANY & PRICE
              _buildTitleAndPriceSection(),

              const SizedBox(height: 12),

              // 3. DESCRIPTION (Directly below Image & Name as requested)
              _buildDescriptionSection(),

              const SizedBox(height: 12),

              // 4. LIVE STOCK STATUS & AVAILABILITY CARD
              _buildStockToggleCard(),

              const SizedBox(height: 12),

              // 5. PRODUCT SPECIFICATIONS (Pack size, Dosage, Target, Rating)
              _buildSpecGridSection(),

              const SizedBox(height: 12),

              // 6. DEALER & STORE DETAILS
              _buildStoreDetailsSection(),

              const SizedBox(height: 18),

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
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark, size: 21),
        onPressed: () => Navigator.pop(context, _product),
      ),
      title: Text(
        "Product Details",
        style: AppTheme.english(fontSize: 16.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
      ),
      centerTitle: true,
      actions: [
        // In-Stock mini badge
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: _inStock ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _inStock ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
              width: 0.8,
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _inStock ? const Color(0xFF16A34A) : AppColors.alertSoftRed,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                _inStock ? "In Stock" : "Out of Stock",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: _inStock ? const Color(0xFF15803D) : AppColors.alertSoftRed,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
      ],
    );
  }

  // -------------------------------------------------------------
  // 2. PRODUCT IMAGE SECTION
  // -------------------------------------------------------------
  Widget _buildProductImageSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: SizedBox(
              height: 220,
              width: double.infinity,
              child: Image.network(
                _product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: _categoryColor.withValues(alpha: 0.08),
                    child: Center(
                      child: Icon(
                        _product.category == AgriProductCategory.seeds ? Icons.spa_rounded : Icons.science_rounded,
                        color: _categoryColor,
                        size: 48,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Category Badge (Top Left)
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: _categoryColor,
                borderRadius: BorderRadius.circular(6),
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
                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
          ),

          // Official FSC&RD Tag (Bottom Left)
          Positioned(
            bottom: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified_rounded, size: 13, color: AppColors.accentLime),
                  const SizedBox(width: 4),
                  Text(
                    _isUrdu ? "حکومتی تصدیق شدہ" : "FSC&RD Certified",
                    style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ],
              ),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
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
                          ? AppTheme.urdu(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textDark)
                          : AppTheme.english(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.business_rounded, size: 13, color: _categoryColor),
                        const SizedBox(width: 4),
                        Text(
                          _product.getCompany(_isUrdu),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _categoryColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Pack Size Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Text(
                  _product.getPackSize(_isUrdu),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Price Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isUrdu ? "سرکاری ریٹیل ریٹ:" : "Official Retail Price:",
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    "Rs. ${_product.price.toInt()}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
                  ),
                  if (_product.originalPrice > _product.price) ...[
                    const SizedBox(width: 6),
                    Text(
                      "Rs. ${_product.originalPrice.toInt()}",
                      style: const TextStyle(
                        fontSize: 11.5,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_outlined, size: 15, color: AppColors.primaryDark),
              const SizedBox(width: 6),
              Text(
                _isUrdu ? "پروڈکٹ کی تفصیل و خصوصیات" : "Product Description",
                style: _isUrdu
                    ? AppTheme.urdu(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryDark)
                    : AppTheme.english(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _product.getDescription(_isUrdu),
              style: TextStyle(
                fontSize: _isUrdu ? 12.5 : 12.5,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _inStock ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _inStock ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _inStock ? const Color(0xFF16A34A) : AppColors.alertSoftRed,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _inStock
                        ? (_isUrdu ? "اسٹاک دستیاب ہے (ایکٹو)" : "In Stock (Available)")
                        : (_isUrdu ? "اسٹاک ختم ہے (غیر فعال)" : "Out of Stock (Inactive)"),
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: _inStock ? const Color(0xFF15803D) : AppColors.alertSoftRed,
                    ),
                  ),
                  Text(
                    _isUrdu ? "کسانوں کے لیے آن لائن ڈیمانڈ دستیاب ہے" : "Available for farmer orders & queries",
                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
          Switch.adaptive(
            value: _inStock,
            activeThumbColor: const Color(0xFF16A34A),
            activeTrackColor: const Color(0xFFBBF7D0),
            onChanged: _toggleStock,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isUrdu ? "زرعی ہدایات و پیمائش" : "Specifications & Agri Dosage",
            style: _isUrdu
                ? AppTheme.urdu(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryDark)
                : AppTheme.english(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
          ),
          const SizedBox(height: 8),
          _buildSpecRow(
            icon: Icons.inventory_2_outlined,
            label: _isUrdu ? "پیکنگ سائز" : "Pack Size",
            value: _product.getPackSize(_isUrdu),
          ),
          const Divider(height: 12),
          _buildSpecRow(
            icon: Icons.science_outlined,
            label: _isUrdu ? "تجویز کردہ مقدار" : "Dosage / Acre",
            value: _product.getDosage(_isUrdu),
          ),
          const Divider(height: 12),
          _buildSpecRow(
            icon: Icons.track_changes_outlined,
            label: _isUrdu ? "ہدف / فصل کا فائدہ" : "Target & Benefit",
            value: _product.getTarget(_isUrdu),
          ),
          const Divider(height: 12),
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
        Icon(icon, size: 15, color: AppColors.primaryDark),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textDark),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isUrdu ? "سیلر شاپ کی معلومات" : "Seller & Shop Info",
            style: _isUrdu
                ? AppTheme.urdu(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryDark)
                : AppTheme.english(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
          ),
          const SizedBox(height: 8),
          _buildSpecRow(
            icon: Icons.storefront_outlined,
            label: _isUrdu ? "دکان کا نام" : "Shop Name",
            value: _product.getDealerName(_isUrdu),
          ),
          const Divider(height: 12),
          _buildSpecRow(
            icon: Icons.location_on_outlined,
            label: _isUrdu ? "ایڈریس" : "Market Location",
            value: _product.getDealerLocation(_isUrdu),
          ),
          const Divider(height: 12),
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
              padding: const EdgeInsets.symmetric(vertical: 11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              side: const BorderSide(color: AppColors.borderLight),
            ),
            child: Text(
              _isUrdu ? "کیٹلاگ پر جائیں" : "Back to Catalog",
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () => _toggleStock(!_inStock),
            icon: Icon(
              _inStock ? Icons.remove_circle_outline_rounded : Icons.check_circle_outline_rounded,
              size: 16,
              color: Colors.white,
            ),
            label: Text(
              _inStock
                  ? (_isUrdu ? "اسٹاک ختم مارک کریں" : "Mark Out of Stock")
                  : (_isUrdu ? "اسٹاک میں شامل کریں" : "Mark In Stock"),
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _inStock ? AppColors.alertSoftRed : const Color(0xFF16A34A),
              padding: const EdgeInsets.symmetric(vertical: 11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}
