import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../auth/controllers/user_session_controller.dart';
import '../models/agri_product_model.dart';
import 'dealer_add_product_screen.dart';
import 'dealer_orders_screen.dart';
import 'dealer_product_detail_screen.dart';

class DealerDashboardScreen extends StatefulWidget {
  final bool? isUrdu;

  const DealerDashboardScreen({super.key, this.isUrdu});

  @override
  State<DealerDashboardScreen> createState() => _DealerDashboardScreenState();
}

class _DealerDashboardScreenState extends State<DealerDashboardScreen> {
  // Entire Dealer Section is strictly in English as requested
  bool get _isUrdu => false;

  int _currentNavIndex = 0; // 0: Dashboard, 1: My Products, 2: Orders, 3: Khata
  String _searchQuery = "";
  bool _isShopOpen = true;
  String _selectedCategoryFilter = "all"; // all, seeds, fertilizers, instock

  // 6 Curated High Quality Agri Products with Pictures (Kept in state for My Products view)
  final List<AgriProductModel> _products = [
    const AgriProductModel(
      id: "prod-1",
      nameEnglish: "Akbar-19 Wheat",
      nameUrdu: "اکبر ۱۹ گندم بیج",
      category: AgriProductCategory.seeds,
      companyEnglish: "Punjab Seed Corp",
      companyUrdu: "پنجاب سیڈ",
      packSizeEnglish: "50 kg Bag",
      packSizeUrdu: "۵۰ کلو بوری",
      price: 5200,
      originalPrice: 5600,
      rating: 4.9,
      reviewsCount: 184,
      inStock: true,
      descriptionEnglish: "Certified wheat seed, 95% germination rate, rust-resistant.",
      descriptionUrdu: "پنجاب حکومت سے تصدیق شدہ گندم کا بیج، ۹۵ فیصد شرح اگاؤ۔",
      dosageEnglish: "50 kg per acre",
      dosageUrdu: "۵۰ کلو فی ایکڑ",
      targetEnglish: "Rust Resistant",
      targetUrdu: "زنگ سے محفوظ",
      dealerNameEnglish: "Chaudhry Agri Store",
      dealerNameUrdu: "چوہدری ایگرو سینٹر",
      dealerPhone: "0300-8472910",
      dealerLocationEnglish: "Grain Market, Multan",
      dealerLocationUrdu: "غلہ منڈی، ملتان",
      imageUrl: "https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?q=80&w=400&auto=format&fit=crop",
    ),
    const AgriProductModel(
      id: "prod-2",
      nameEnglish: "Pioneer 30Y87 Corn",
      nameUrdu: "پائنیر ۳۰Y۸۷ مکئی",
      category: AgriProductCategory.seeds,
      companyEnglish: "Corteva Agriscience",
      companyUrdu: "کورٹیوا",
      packSizeEnglish: "8 kg Bag",
      packSizeUrdu: "۸ کلو بیگ",
      price: 14500,
      originalPrice: 15200,
      rating: 5.0,
      reviewsCount: 220,
      inStock: true,
      descriptionEnglish: "Pakistan's top-selling silage and grain corn hybrid.",
      descriptionUrdu: "پاکستان میں سب سے زیادہ بکنے والی مکئی، بہترین سائیلج۔",
      dosageEnglish: "8 kg per acre",
      dosageUrdu: "۸ کلو فی ایکڑ",
      targetEnglish: "Silage & Grain",
      targetUrdu: "سائیلج و دانہ",
      dealerNameEnglish: "Chaudhry Agri Store",
      dealerNameUrdu: "چوہدری ایگرو سینٹر",
      dealerPhone: "0300-8472910",
      dealerLocationEnglish: "Grain Market, Multan",
      dealerLocationUrdu: "غلہ منڈی، ملتان",
      imageUrl: "https://images.unsplash.com/photo-1551754655-cd27e38d2076?q=80&w=400&auto=format&fit=crop",
    ),
    const AgriProductModel(
      id: "prod-3",
      nameEnglish: "FH-333 BT Cotton",
      nameUrdu: "کپاس FH-333",
      category: AgriProductCategory.seeds,
      companyEnglish: "Four Brothers Agri",
      companyUrdu: "فور برادرز",
      packSizeEnglish: "40 kg Pack",
      packSizeUrdu: "۴۰ کلو تھیلا",
      price: 8400,
      originalPrice: 8900,
      rating: 4.8,
      reviewsCount: 96,
      inStock: true,
      descriptionEnglish: "Triple-gene BT cotton seed with resistance to bollworms.",
      descriptionUrdu: "امریکن اور گلابی سنڈی کے خلاف زبردست قوت مدافعت۔",
      dosageEnglish: "8 to 10 kg per acre",
      dosageUrdu: "۸ تا ۱۰ کلو فی ایکڑ",
      targetEnglish: "Bollworm Resistance",
      targetUrdu: "سنڈی سے مدافعت",
      dealerNameEnglish: "Chaudhry Agri Store",
      dealerNameUrdu: "چوہدری ایگرو سینٹر",
      dealerPhone: "0300-8472910",
      dealerLocationEnglish: "Grain Market, Multan",
      dealerLocationUrdu: "غلہ منڈی، ملتان",
      imageUrl: "https://images.unsplash.com/photo-1600651215852-9d3bf0765709?q=80&w=400&auto=format&fit=crop",
    ),
    const AgriProductModel(
      id: "prod-4",
      nameEnglish: "Guard Super Basmati",
      nameUrdu: "گارڈ سپر باسمتی",
      category: AgriProductCategory.seeds,
      companyEnglish: "Guard Agri Research",
      companyUrdu: "گارڈ ایگری",
      packSizeEnglish: "20 kg Bag",
      packSizeUrdu: "۲۰ کلو بوری",
      price: 6800,
      originalPrice: 7200,
      rating: 4.7,
      reviewsCount: 88,
      inStock: true,
      descriptionEnglish: "Authentic long-grain aromatic Basmati rice seed.",
      descriptionUrdu: "خوشبودار لمبے دانے والا سپر باسمتی چاول بیج۔",
      dosageEnglish: "5 kg nursery / acre",
      dosageUrdu: "۵ کلو پنیری فی ایکڑ",
      targetEnglish: "Export Aroma",
      targetUrdu: "ایکسپورٹ خوشبو",
      dealerNameEnglish: "Chaudhry Agri Store",
      dealerNameUrdu: "چوہدری ایگرو سینٹر",
      dealerPhone: "0300-8472910",
      dealerLocationEnglish: "Grain Market, Multan",
      dealerLocationUrdu: "غلہ منڈی، ملتان",
      imageUrl: "https://images.unsplash.com/photo-1586201375761-83865001e31c?q=80&w=400&auto=format&fit=crop",
    ),
    const AgriProductModel(
      id: "prod-5",
      nameEnglish: "FFC Sona Urea 46%",
      nameUrdu: "سونا یوریا کھاد",
      category: AgriProductCategory.fertilizers,
      companyEnglish: "Fauji Fertilizer (FFC)",
      companyUrdu: "فوجی فرٹیلائزر",
      packSizeEnglish: "50 kg Bag",
      packSizeUrdu: "۵۰ کلو بوری",
      price: 4400,
      originalPrice: 4400,
      rating: 4.9,
      reviewsCount: 310,
      inStock: true,
      descriptionEnglish: "Standard prilled white urea with 46% Nitrogen for lush growth.",
      descriptionUrdu: "۴۶ فیصد نائٹروجن، پودے کی فوری نشوونما اور سبز رنگ کیلئے۔",
      dosageEnglish: "1 to 2 bags per acre",
      dosageUrdu: "۱ تا ۲ بوری فی ایکڑ",
      targetEnglish: "Vegetative Growth",
      targetUrdu: "بھرپور بڑھوتری",
      dealerNameEnglish: "Chaudhry Agri Store",
      dealerNameUrdu: "چوہدری ایگرو سینٹر",
      dealerPhone: "0300-8472910",
      dealerLocationEnglish: "Grain Market, Multan",
      dealerLocationUrdu: "غلہ منڈی، ملتان",
      imageUrl: "https://images.unsplash.com/photo-1585314062340-f1a5a7c9328d?q=80&w=400&auto=format&fit=crop",
    ),
    const AgriProductModel(
      id: "prod-6",
      nameEnglish: "Engro DAP Fertilizer",
      nameUrdu: "اینگرو ڈی اے پی",
      category: AgriProductCategory.fertilizers,
      companyEnglish: "Engro Fertilizers Ltd",
      companyUrdu: "اینگرو فرٹیلائزرز",
      packSizeEnglish: "50 kg Bag",
      packSizeUrdu: "۵۰ کلو بوری",
      price: 12800,
      originalPrice: 13200,
      rating: 5.0,
      reviewsCount: 245,
      inStock: true,
      descriptionEnglish: "18% Nitrogen and 46% Phosphorus for strong root establishment.",
      descriptionUrdu: "۱۸ فیصد نائٹروجن اور ۴۶ فیصد فاسفورس، مضبوط جڑوں کیلئے۔",
      dosageEnglish: "1 bag per acre at sowing",
      dosageUrdu: "۱ بوری فی ایکڑ بوقت بوائی",
      targetEnglish: "Root Development",
      targetUrdu: "مضبوط جڑیں",
      dealerNameEnglish: "Chaudhry Agri Store",
      dealerNameUrdu: "چوہدری ایگرو سینٹر",
      dealerPhone: "0300-8472910",
      dealerLocationEnglish: "Grain Market, Multan",
      dealerLocationUrdu: "غلہ منڈی، ملتان",
      imageUrl: "https://images.unsplash.com/photo-1628352081506-83c43123ed6d?q=80&w=400&auto=format&fit=crop",
    ),
  ];

  late List<AgriProductModel> _activeList;

  @override
  void initState() {
    super.initState();
    _activeList = List.from(_products);
  }

  void _toggleProductStock(int index) {
    setState(() {
      final item = _activeList[index];
      _activeList[index] = AgriProductModel(
        id: item.id,
        nameEnglish: item.nameEnglish,
        nameUrdu: item.nameUrdu,
        category: item.category,
        companyEnglish: item.companyEnglish,
        companyUrdu: item.companyUrdu,
        packSizeEnglish: item.packSizeEnglish,
        packSizeUrdu: item.packSizeUrdu,
        price: item.price,
        originalPrice: item.originalPrice,
        rating: item.rating,
        reviewsCount: item.reviewsCount,
        inStock: !item.inStock,
        descriptionEnglish: item.descriptionEnglish,
        descriptionUrdu: item.descriptionUrdu,
        dosageEnglish: item.dosageEnglish,
        dosageUrdu: item.dosageUrdu,
        targetEnglish: item.targetEnglish,
        targetUrdu: item.targetUrdu,
        dealerNameEnglish: item.dealerNameEnglish,
        dealerNameUrdu: item.dealerNameUrdu,
        dealerPhone: item.dealerPhone,
        dealerLocationEnglish: item.dealerLocationEnglish,
        dealerLocationUrdu: item.dealerLocationUrdu,
        imageUrl: item.imageUrl,
      );
    });

    final updated = _activeList[index];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updated.inStock
              ? (_isUrdu ? "${updated.getName(_isUrdu)} دستیاب ہے" : "${updated.nameEnglish} marked In Stock")
              : (_isUrdu ? "${updated.getName(_isUrdu)} اسٹاک ختم ہو گیا" : "${updated.nameEnglish} marked Out of Stock"),
        ),
        duration: const Duration(milliseconds: 900),
        backgroundColor: AppColors.primaryDark,
      ),
    );
  }

  Future<void> _openAddProductScreen() async {
    final newProduct = await Navigator.push<AgriProductModel>(
      context,
      MaterialPageRoute(
        builder: (_) => DealerAddProductScreen(isUrdu: _isUrdu),
      ),
    );

    if (newProduct != null) {
      setState(() {
        _activeList.insert(0, newProduct);
      });
    }
  }

  void _showMandiRatesDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.trending_up_rounded, color: Color(0xFF7C3AED), size: 22),
            const SizedBox(width: 8),
            const Text(
              "Official Mandi Rates",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRateRow("Wheat Seed (Akbar-19)", "Rs. 5,200 / Bag"),
            const Divider(),
            _buildRateRow("Engro DAP Fertilizer", "Rs. 12,800 / Bag"),
            const Divider(),
            _buildRateRow("FFC Sona Urea", "Rs. 4,400 / Bag"),
            const Divider(),
            _buildRateRow("Pioneer Hybrid Corn (30Y87)", "Rs. 14,500 / Bag"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close", style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildRateRow(String item, String rate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(item, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          Text(rate, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
        ],
      ),
    );
  }

  Future<void> _openProductDetails(AgriProductModel product) async {
    final updated = await Navigator.push<AgriProductModel>(
      context,
      MaterialPageRoute(
        builder: (_) => DealerProductDetailScreen(
          product: product,
          isUrdu: _isUrdu,
        ),
      ),
    );

    if (updated != null) {
      setState(() {
        final index = _activeList.indexWhere((p) => p.id == updated.id);
        if (index != -1) {
          _activeList[index] = updated;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentNavIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentNavIndex != 0) {
          setState(() => _currentNavIndex = 0);
        }
      },
      child: ResponsiveLayout(
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildHeaderAppBar(),
          body: SafeArea(
            child: _currentNavIndex == 1
                ? _buildMyProductsCatalogView()
                : _currentNavIndex == 2
                    ? DealerOrdersScreen(isStandalone: false, isUrdu: _isUrdu)
                    : _buildDashboardHomeView(),
          ),
          // Bottom Navigation Bar
          bottomNavigationBar: _buildModernNavbar(),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 1. APPBAR
  // -------------------------------------------------------------
  // 1. APPBAR (JUST 'SELLER DASHBOARD', BACK ARROW & NOTIFICATION ICON)
  // -------------------------------------------------------------
  PreferredSizeWidget _buildHeaderAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryDark, size: 22),
        onPressed: () {
          if (_currentNavIndex != 0) {
            setState(() => _currentNavIndex = 0);
          } else {
            Navigator.maybePop(context);
          }
        },
      ),
      title: Text(
        _currentNavIndex == 1
            ? "My Products"
            : _currentNavIndex == 2
                ? "Farmer Orders"
                : "Seller Dashboard",
        style: AppTheme.english(fontSize: 16.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
      ),
      actions: [
        // Corner Notification Icon with Red Badge Dot
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppColors.primaryDark, size: 22),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Agri Dept Notification: Wheat Seed subsidy monitoring active",
                    ),
                    backgroundColor: AppColors.primaryDark,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            Positioned(
              top: 13,
              right: 12,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: AppColors.alertSoftRed,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // -------------------------------------------------------------
  // 2. DASHBOARD HOME VIEW (EXACT VERTICAL ORDER REQUESTED)
  // [1. Search Bar -> 2. Piyara Green Card -> 3. Quick Action Row -> 4. Recent Requests]
  // NO PRODUCTS ON DASHBOARD
  // -------------------------------------------------------------
  Widget _buildDashboardHomeView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 14, bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. TOPMOST: SEARCH BAR (Pushed down with top spacing)
          _buildTopSearchBar(),

          const SizedBox(height: 20), // Increased gap between search bar and card

          // 2. PIYARA GREEN COLOR CARD
          _buildPiyaraGreenCard(),

          const SizedBox(height: 32), // Brought lower to eliminate empty space

          // 3. QUICK ACTIONS HEADING
          _buildQuickActionsHeader(),

          const SizedBox(height: 16),

          // 4. QUICK ACTION MENU (Directly on screen background, no separate card)
          _buildQuickActionMenuRow(),

          const SizedBox(height: 28),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 1. TOPMOST SEARCH BAR (MODERN & ELEVATED)
  // -------------------------------------------------------------
  Widget _buildTopSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(Icons.search_rounded, size: 21, color: Color(0xFF16A34A)),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                onChanged: (val) {
                  setState(() => _searchQuery = val);
                  if (val.trim().isNotEmpty && _currentNavIndex != 1) {
                    setState(() => _currentNavIndex = 1);
                  }
                },
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText: _isUrdu ? "بیج، کھاد یا آرڈر تلاش کریں..." : "Search seed, fertilizer, or order...",
                  hintStyle: const TextStyle(fontSize: 12, color: AppColors.textLight, fontWeight: FontWeight.w500),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textMuted),
                onPressed: () => setState(() => _searchQuery = ""),
              )
            else
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.tune_rounded, size: 16, color: Color(0xFF15803D)),
              ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 2. PIYARA GREEN COLOR CARD (EXACT USER WEATHER CARD GRADIENT)
  // -------------------------------------------------------------
  Widget _buildPiyaraGreenCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: AppColors.freshLeafGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryMedium.withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Decorative Watermark Icon
          Positioned(
            right: -10,
            bottom: -15,
            child: Icon(
              Icons.spa_rounded,
              size: 110,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: FSC&RD Badge & Open/Closed Switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_rounded, size: 13, color: AppColors.accentLime),
                        const SizedBox(width: 4),
                        Text(
                          _isUrdu ? "FSC&RD رجسٹرڈ ایجنسی" : "FSC&RD Registered Agency",
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  // Store Status Switch
                  Row(
                    children: [
                      Text(
                        _isShopOpen ? (_isUrdu ? "دکان کھلی ہے" : "Open") : (_isUrdu ? "بند ہے" : "Closed"),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _isShopOpen ? AppColors.accentLime : Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        height: 22,
                        width: 36,
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: Switch(
                            value: _isShopOpen,
                            onChanged: (v) => setState(() => _isShopOpen = v),
                            activeThumbColor: AppColors.accentLime,
                            activeTrackColor: Colors.white38,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Shop Name (Prominent & Crisp White)
              Text(
                UserSessionController.instance.businessOrFarmName.isNotEmpty
                    ? UserSessionController.instance.businessOrFarmName
                    : "Chaudhry Agri Seeds & Fertilizer",
                style: _isUrdu
                    ? AppTheme.urdu(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white)
                    : AppTheme.english(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.3),
              ),
              const SizedBox(height: 3),

              // Market & Dealer Details
              Row(
                children: [
                  const Icon(Icons.location_on_rounded, size: 13, color: AppColors.accentLime),
                  const SizedBox(width: 3),
                  Text(
                    _isUrdu ? "غلہ منڈی، ملتان (پنجاب)" : "Grain Market, Multan (Punjab)",
                    style: TextStyle(fontSize: 11.5, color: Colors.white.withValues(alpha: 0.95), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // License ID & Certified Tags Strip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isUrdu ? "لائسنس: FSC-PB-2024-8849" : "License: FSC-PB-2024-8849",
                      style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      _isUrdu ? "میعاد: ایکٹو ۲۰۲۷" : "Valid: Active 2027",
                      style: const TextStyle(fontSize: 9.5, color: AppColors.accentLime, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 3. QUICK ACTIONS HEADING
  // -------------------------------------------------------------
  Widget _buildQuickActionsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Quick Actions",
            style: AppTheme.english(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
              letterSpacing: -0.2,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt_rounded, size: 13, color: Color(0xFF15803D)),
                SizedBox(width: 3),
                Text(
                  "Shortcuts",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF15803D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 4. QUICK ACTION MENU (SEAMLESS ON SCREEN BG - NO SEPARATE CARD)
  // [1. Add -> 2. My Products -> 3. Orders -> 4. Rate List]
  // -------------------------------------------------------------
  Widget _buildQuickActionMenuRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 1st: Add
          _buildQuickActionBtn(
            title: "Add",
            icon: Icons.add_box_rounded,
            color: const Color(0xFF16A34A),
            bgColor: const Color(0xFFDCFCE7),
            onTap: _openAddProductScreen,
          ),
          // 2nd: My Products
          _buildQuickActionBtn(
            title: "My Products",
            icon: Icons.inventory_2_rounded,
            color: const Color(0xFF0284C7),
            bgColor: const Color(0xFFE0F2FE),
            onTap: () => setState(() => _currentNavIndex = 1),
          ),
          // 3rd: Order
          _buildQuickActionBtn(
            title: "Orders",
            icon: Icons.receipt_long_rounded,
            color: const Color(0xFF2563EB),
            bgColor: const Color(0xFFDBEAFE),
            badgeText: "3",
            onTap: () => setState(() => _currentNavIndex = 2),
          ),
          // 4th: Rate List
          _buildQuickActionBtn(
            title: "Rate List",
            icon: Icons.trending_up_rounded,
            color: const Color(0xFF7C3AED),
            bgColor: const Color(0xFFEDE9FE),
            onTap: _showMandiRatesDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionBtn({
    required String title,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
    String? badgeText,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(icon, size: 28, color: color),
                ),
              ),
              if (badgeText != null)
                Positioned(
                  top: -3,
                  right: -3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.alertSoftRed,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // MY PRODUCTS VIEW (PREMIUM 2-COLUMN GRID WITH CATEGORY FILTERS)
  // -------------------------------------------------------------
  Widget _buildMyProductsCatalogView() {
    // 1. Search Query Filter
    final searchFiltered = _searchQuery.trim().isEmpty
        ? _activeList
        : _activeList.where((p) {
            final q = _searchQuery.toLowerCase().trim();
            return p.nameEnglish.toLowerCase().contains(q) ||
                p.companyEnglish.toLowerCase().contains(q) ||
                p.packSizeEnglish.toLowerCase().contains(q);
          }).toList();

    // 2. Category Tab Filter
    final list = searchFiltered.where((p) {
      if (_selectedCategoryFilter == "seeds") {
        return p.category == AgriProductCategory.seeds;
      } else if (_selectedCategoryFilter == "fertilizers") {
        return p.category == AgriProductCategory.fertilizers;
      } else if (_selectedCategoryFilter == "instock") {
        return p.inStock;
      }
      return true;
    }).toList();

    return Column(
      children: [
        // Inventory Header Bar with Quick Add Button
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    "Products Inventory",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${list.length}",
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF15803D)),
                    ),
                  ),
                ],
              ),

              // + Add Product Shortcut Pill
              InkWell(
                onTap: _openAddProductScreen,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDark.withValues(alpha: 0.18),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        "Add Item",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Category Filter Chips
        _buildCategoryFilterBar(),

        const SizedBox(height: 4),

        // Premium 2-Column Product Grid
        Expanded(
          child: list.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textLight.withValues(alpha: 0.6)),
                      const SizedBox(height: 10),
                      const Text(
                        "No products found",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Try changing your search or category filter",
                        style: TextStyle(fontSize: 11, color: AppColors.textLight),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(10, 6, 10, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 in one row as requested
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.495,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return _buildModernThreeInOneProductCard(list[index], index);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          _buildFilterChip("All", "all", _activeList.length),
          const SizedBox(width: 8),
          _buildFilterChip("Seeds", "seeds", _activeList.where((p) => p.category == AgriProductCategory.seeds).length),
          const SizedBox(width: 8),
          _buildFilterChip("Fertilizers", "fertilizers", _activeList.where((p) => p.category == AgriProductCategory.fertilizers).length),
          const SizedBox(width: 8),
          _buildFilterChip("In Stock", "instock", _activeList.where((p) => p.inStock).length),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String key, int count) {
    final bool isSelected = _selectedCategoryFilter == key;

    return InkWell(
      onTap: () => setState(() => _selectedCategoryFilter = key),
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDark : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primaryDark : AppColors.borderLight,
            width: 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryDark.withValues(alpha: 0.16),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textDark,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.22) : AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "$count",
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernThreeInOneProductCard(AgriProductModel product, int index) {
    final bool isSeeds = product.category == AgriProductCategory.seeds;
    final catColor = isSeeds ? const Color(0xFF16A34A) : const Color(0xFF0284C7);
    final catBg = isSeeds ? const Color(0xFFDCFCE7) : const Color(0xFFE0F2FE);

    return InkWell(
      onTap: () => _openProductDetails(product),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: product.inStock ? AppColors.borderLight : AppColors.alertSoftRed.withValues(alpha: 0.35),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image Header (106px)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                  child: SizedBox(
                    height: 106,
                    width: double.infinity,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: catColor.withValues(alpha: 0.08),
                          child: Center(
                            child: Icon(
                              isSeeds ? Icons.spa_rounded : Icons.science_rounded,
                              color: catColor,
                              size: 26,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Category Tag Pill
                Positioned(
                  top: 5,
                  left: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: catBg,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: catColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      isSeeds ? "Seed" : "Fertilizer",
                      style: TextStyle(
                        fontSize: 7.5,
                        fontWeight: FontWeight.w800,
                        color: catColor,
                      ),
                    ),
                  ),
                ),

                // Live Stock Indicator Dot
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: product.inStock ? const Color(0xFF16A34A) : AppColors.alertSoftRed,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.2),
                    ),
                  ),
                ),
              ],
            ),

            // 2. Card Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(7, 5, 7, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Company
                        Text(
                          product.companyEnglish.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 7.8,
                            fontWeight: FontWeight.w800,
                            color: catColor,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 1),

                        // Title
                        Text(
                          product.nameEnglish,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 3),

                        // Pack Size Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.packSizeEnglish,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 7.5,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Price & Stock Toggle Button
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Rs. ${product.price.toInt()}",
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        InkWell(
                          onTap: () {
                            final actIdx = _activeList.indexWhere((p) => p.id == product.id);
                            if (actIdx != -1) {
                              _toggleProductStock(actIdx);
                            } else {
                              _toggleProductStock(index);
                            }
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 2.5),
                            decoration: BoxDecoration(
                              color: product.inStock ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: product.inStock ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
                                width: 0.8,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: product.inStock ? const Color(0xFF16A34A) : AppColors.alertSoftRed,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  product.inStock ? "In Stock" : "Out of Stock",
                                  style: TextStyle(
                                    fontSize: 7.5,
                                    fontWeight: FontWeight.w800,
                                    color: product.inStock ? const Color(0xFF15803D) : AppColors.alertSoftRed,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 5. FLOATING MODERN BOTTOM NAVBAR (MATCHES USER APP WITH ENLARGED ICONS)
  // -------------------------------------------------------------
  Widget _buildModernNavbar() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.only(left: 18, right: 18, bottom: 16, top: 4),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(34),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              index: 0,
              icon: Icons.home_rounded,
              label: "Home",
            ),
            _buildNavItem(
              index: 1,
              icon: Icons.inventory_2_rounded,
              label: "Products",
            ),
            _buildNavItem(
              index: 2,
              icon: Icons.receipt_long_rounded,
              label: "Orders",
              badge: "3",
            ),
            _buildNavItem(
              index: 3,
              icon: Icons.menu_book_rounded,
              label: "Ledger",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    String? badge,
  }) {
    final bool isSelected = _currentNavIndex == index;

    return InkWell(
      onTap: () {
        setState(() => _currentNavIndex = index);
        if (index == 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Opening Farmer Credit Ledger"),
              backgroundColor: Color(0xFFD97706),
              duration: Duration(milliseconds: 900),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(26),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDark : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 24, // Enlarged crisp icon size
                  color: isSelected ? Colors.white : AppColors.textLight,
                ),
                if (badge != null && !isSelected)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3.5),
                      decoration: const BoxDecoration(
                        color: AppColors.alertSoftRed,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(fontSize: 7.5, color: Colors.white, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: _isUrdu
                    ? AppTheme.urdu(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      )
                    : AppTheme.english(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
