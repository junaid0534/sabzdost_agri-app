import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sabzdost/features/home/screens/dashboard_screen.dart';
import 'package:sabzdost/features/home/screens/farmer_settings_screen.dart';
import 'package:sabzdost/features/ledger/models/ledger_entry.dart';
import 'package:sabzdost/features/ledger/screens/crop_khata_detail_screen.dart';
import 'package:sabzdost/features/ledger/screens/farm_ledger_screen.dart';
import 'package:sabzdost/features/ledger/widgets/add_ledger_entry_sheet.dart';
import 'package:sabzdost/features/store/screens/dealer_dashboard_screen.dart';
import 'package:sabzdost/features/store/screens/dealer_orders_screen.dart';
import 'package:sabzdost/features/store/models/agri_product_model.dart';
import 'package:sabzdost/features/store/screens/dealer_product_detail_screen.dart';
import 'package:sabzdost/features/store/screens/dealer_settings_screen.dart';
import 'package:sabzdost/features/store/services/product_firebase_service.dart';
import 'package:sabzdost/features/store/widgets/product_safe_image.dart';
import 'package:sabzdost/features/auth/screens/login_screen.dart';

void main() {
  testWidgets('FarmerSettingsScreen renders settings and logout button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FarmerSettingsScreen(isUrdu: false),
      ),
    );

    // Verify Settings Header is present
    expect(find.text('Settings & Profile'), findsOneWidget);

    // Verify App Preferences section is present
    expect(find.text('App Preferences'), findsOneWidget);

    // Verify Logout button is present
    expect(find.text('Log Out from Account'), findsOneWidget);
    expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
  });

  testWidgets('DashboardScreen contains 5 navbar items and Settings tab works', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardScreen(initialIndex: 4),
      ),
    );

    // Check navbar icons: Home, Doctor, Khata, Mandi, Settings
    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    expect(find.byIcon(Icons.psychology_rounded), findsOneWidget);
    expect(find.byIcon(Icons.menu_book_rounded), findsOneWidget);
    expect(find.byIcon(Icons.trending_up_rounded), findsOneWidget);
    expect(find.byIcon(Icons.settings_rounded), findsOneWidget);

    // Verify FarmerSettingsScreen is displayed because initialIndex is 4
    expect(find.byType(FarmerSettingsScreen), findsOneWidget);
    expect(find.text('Settings & Profile'), findsOneWidget);
  });

  testWidgets('FarmLedgerScreen renders in Urdu and English correctly', (WidgetTester tester) async {
    // 1. Urdu Mode
    await tester.pumpWidget(
      const MaterialApp(
        home: FarmLedgerScreen(isUrdu: true),
      ),
    );

    expect(find.text('فصل وار کھاتہ'), findsOneWidget);
    expect(find.text('فصل منتخب کریں'), findsOneWidget);
    expect(find.text('گندم'), findsOneWidget);
    expect(find.text('کپاس'), findsOneWidget);

    // 2. English Mode
    await tester.pumpWidget(
      const MaterialApp(
        home: FarmLedgerScreen(isUrdu: false),
      ),
    );

    expect(find.text('Crop-wise Ledger'), findsOneWidget);
    expect(find.text('Select Crop'), findsOneWidget);
    expect(find.text('Wheat'), findsOneWidget);
    expect(find.text('Cotton'), findsOneWidget);
    expect(find.text('Rice'), findsOneWidget);
  });

  testWidgets('CropKhataDetailScreen renders in Urdu and English properly', (WidgetTester tester) async {
    final testEntries = [
      LedgerEntry(
        id: "1",
        title: "Wheat Harvest Sale",
        titleUrdu: "گندم فروخت",
        totalAmount: 50000,
        paidAmount: 50000,
        type: LedgerEntryType.income,
        category: LedgerCategory.cropSale,
        cropName: "Wheat",
        date: DateTime.now(),
      ),
      LedgerEntry(
        id: "2",
        title: "Urea Fertilizer",
        titleUrdu: "یوریا کھاد",
        totalAmount: 10000,
        paidAmount: 10000,
        type: LedgerEntryType.expense,
        category: LedgerCategory.fertilizer,
        cropName: "Wheat",
        date: DateTime.now(),
      ),
    ];

    // 1. Urdu Mode
    await tester.pumpWidget(
      MaterialApp(
        home: CropKhataDetailScreen(
          cropName: "Wheat",
          cropUrduName: "گندم",
          icon: Icons.grass_rounded,
          themeColor: const Color(0xFFE5A93C),
          entries: testEntries,
          isUrdu: true,
          onAddEntry: (_) {},
          onSettle: (item, amount, note) {},
        ),
      ),
    );

    expect(find.text('گندم کھاتہ'), findsOneWidget);
    expect(find.text('خالص منافع / بچت'), findsOneWidget);
    expect(find.text('تمام اندراج'), findsOneWidget);
    expect(find.text('گندم فروخت'), findsOneWidget);

    // 2. English Mode
    await tester.pumpWidget(
      MaterialApp(
        home: CropKhataDetailScreen(
          cropName: "Wheat",
          cropUrduName: "گندم",
          icon: Icons.grass_rounded,
          themeColor: const Color(0xFFE5A93C),
          entries: testEntries,
          isUrdu: false,
          onAddEntry: (_) {},
          onSettle: (item, amount, note) {},
        ),
      ),
    );

    expect(find.text('Wheat Ledger'), findsOneWidget);
    expect(find.text('Net Balance / Profit'), findsOneWidget);
    expect(find.text('All Entries'), findsOneWidget);
    expect(find.text('Expenses'), findsOneWidget);
    expect(find.text('Income'), findsNWidgets(2));
    expect(find.text('Wheat Harvest Sale'), findsOneWidget);
    expect(find.text('Urea Fertilizer'), findsOneWidget);
  });

  testWidgets('AddLedgerEntrySheet renders clean Urdu and English layouts without clutter', (WidgetTester tester) async {
    // 1. Urdu Mode
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AddLedgerEntrySheet(
            isUrdu: true,
            onAddEntry: (_) {},
            initialCrop: "Wheat",
          ),
        ),
      ),
    );

    expect(find.text('نیا اندراج'), findsOneWidget);
    expect(find.text('آمدن'), findsOneWidget);
    expect(find.text('خرچہ'), findsOneWidget);
    expect(find.text('رقم'), findsOneWidget);
    expect(find.text('ادائیگی'), findsOneWidget);
    expect(find.text('مکمل نقد'), findsOneWidget);
    expect(find.text('کچھ نقد'), findsOneWidget);
    expect(find.text('ادھار'), findsOneWidget);
    expect(find.text('آمدن محفوظ کریں'), findsOneWidget);

    // 2. English Mode
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AddLedgerEntrySheet(
            isUrdu: false,
            onAddEntry: (_) {},
            initialCrop: "Wheat",
          ),
        ),
      ),
    );

    expect(find.text('New Entry'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
    expect(find.text('Expense'), findsOneWidget);
    expect(find.text('Amount'), findsOneWidget);
    expect(find.text('Payment'), findsOneWidget);
    expect(find.text('Full Cash'), findsOneWidget);
    expect(find.text('Partial'), findsOneWidget);
    expect(find.text('Credit'), findsOneWidget);
    expect(find.text('Save Income Entry'), findsOneWidget);

    // Switch to Expense
    await tester.tap(find.text('Expense'));
    await tester.pumpAndSettle();

    expect(find.text('Save Expense Entry'), findsOneWidget);
  });

  testWidgets('DealerOrdersScreen renders clean English UI, centered title, improved search bar, and no KPI cards', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DealerOrdersScreen(isStandalone: true, isUrdu: false),
      ),
    );

    // Verify AppBar Title is present and centerTitle is set
    expect(find.text('Farmer Orders'), findsOneWidget);
    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.centerTitle, isTrue);

    // Verify KPI cards / metrics row is removed (no standalone metrics card)
    expect(find.byIcon(Icons.pending_actions_rounded), findsNothing);

    // Verify Search Bar has clean, concise hint text
    expect(find.text('Search orders...'), findsOneWidget);

    // Verify Filter Pills
    expect(find.text('All (6)'), findsOneWidget);
    expect(find.text('Pending (3)'), findsOneWidget);

    // Verify Farmer Orders are rendered in Pure English
    expect(find.text('Malik Riaz Ahmad'), findsOneWidget);
    expect(find.text('Basti Malook, Lodhran'), findsOneWidget);
    expect(find.text('Akbar-19 Certified Wheat'), findsOneWidget);
    expect(find.text('Call'), findsWidgets);
    expect(find.text('Accept'), findsWidgets);
    expect(find.text('Decline'), findsWidgets);
  });

  testWidgets('DealerDashboardScreen centers app bar title for Farmer Orders tab', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DealerDashboardScreen(),
      ),
    );

    // Tap on Orders tab (nav index 2)
    await tester.tap(find.byIcon(Icons.receipt_long_rounded).first);
    await tester.pumpAndSettle();

    // Verify AppBar Title 'Farmer Orders' is present and centered
    expect(find.text('Farmer Orders'), findsOneWidget);
    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.centerTitle, isTrue);
  });

  testWidgets('DealerDashboardScreen products catalog categorizes into Seeds, Fertilizers, Sprays and displays pack unit and price', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DealerDashboardScreen(),
      ),
    );

    // Tap on Products catalog tab (nav index 1)
    await tester.tap(find.byIcon(Icons.inventory_2_rounded).first);
    await tester.pumpAndSettle();

    // Verify categories bar
    expect(find.text('Seeds'), findsOneWidget);
    expect(find.text('Fertilizers'), findsOneWidget);
    expect(find.text('Sprays'), findsOneWidget);

    // Verify GridView has 3 columns (3 in 1 row)
    final grid = tester.widget<GridView>(find.byType(GridView));
    final delegate = grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, equals(3));

    // Verify no 'In Stock' pills on the catalog cards
    expect(find.text('In Stock'), findsNothing);

    // Verify product card details: name, pack unit, price
    expect(find.text('Akbar-19 Wheat'), findsOneWidget);
    expect(find.text('50 kg / Bag'), findsWidgets);
    expect(find.text('Rs. 5200'), findsOneWidget);

    // Filter by Sprays
    await tester.tap(find.text('Sprays'));
    await tester.pumpAndSettle();

    // Verify spray product is shown
    expect(find.text('Confidor 200 SL'), findsOneWidget);
    expect(find.text('250 ml / Bottle'), findsOneWidget);
    expect(find.text('Rs. 2450'), findsOneWidget);
  });

  testWidgets('DealerProductDetailScreen renders compact animated status pill, compact switch, and product details', (WidgetTester tester) async {
    const testProduct = AgriProductModel(
      id: "test-1",
      nameEnglish: "Confidor 200 SL",
      nameUrdu: "کانفیڈور 200 ایس ایل",
      category: AgriProductCategory.sprays,
      companyEnglish: "Bayer Crop Science",
      companyUrdu: "بائیر کراپ سائنس",
      packSizeEnglish: "250 ml / Bottle",
      packSizeUrdu: "250 ملی لیٹر بوتل",
      price: 1850.0,
      originalPrice: 1950.0,
      rating: 4.8,
      reviewsCount: 38,
      inStock: true,
      descriptionEnglish: "Systemic insecticide for aphid, jassid and whitefly control in cotton and vegetable crops.",
      descriptionUrdu: "کپاس اور سبزیوں میں سفید مکھی اور سست تیلے کا مؤثر تدارک۔",
      dosageEnglish: "250 ml per 100 liters of water / acre",
      dosageUrdu: "250 ملی لیٹر فی 100 لیٹر پانی فی ایکڑ",
      targetEnglish: "Cotton, Vegetables (Aphids, Jassids, Whitefly)",
      targetUrdu: "کپاس، سبزیاں (تیلا اور سفید مکھی)",
      dealerNameEnglish: "SabzDost Agri Center",
      dealerNameUrdu: "سبزدوسٹ ایگری سنٹر",
      dealerPhone: "+92 300 1234567",
      dealerLocationEnglish: "Grain Market, Khanewal",
      dealerLocationUrdu: "غلہ منڈی، خانیوال",
      imageUrl: "https://images.unsplash.com/photo-1592417817098-8f3d6eb22513?w=500",
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: DealerProductDetailScreen(product: testProduct),
      ),
    );

    // Verify AppBar Title and animated status pill
    expect(find.text('Product Details'), findsOneWidget);
    expect(find.text('In Stock'), findsOneWidget); // AppBar animated mini badge
    expect(find.text('In Stock (Available)'), findsOneWidget); // Toggle card

    // Verify Title & Price section
    expect(find.text('Confidor 200 SL'), findsOneWidget);
    expect(find.text('Bayer Crop Science'), findsOneWidget);
    expect(find.text('Rs. 1850'), findsOneWidget);

    // Verify Compact Switch is present
    expect(find.byType(Switch), findsOneWidget);

    // Verify Specifications
    expect(find.text('Specifications & Agri Dosage'), findsOneWidget);
    expect(find.text('Pack Size'), findsOneWidget);
    expect(find.text('Dosage / Acre'), findsOneWidget);

    // Tap switch to toggle out of stock
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.text('Out of Stock'), findsOneWidget);
    expect(find.text('Out of Stock (Inactive)'), findsOneWidget);
  });

  testWidgets('DealerDashboardScreen navbar has 5 items including Settings and switches to DealerSettingsScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DealerDashboardScreen(),
      ),
    );

    // Verify 5 navbar icon items
    expect(find.byIcon(Icons.home_rounded), findsWidgets);
    expect(find.byIcon(Icons.inventory_2_rounded), findsWidgets);
    expect(find.byIcon(Icons.receipt_long_rounded), findsWidgets);
    expect(find.byIcon(Icons.menu_book_rounded), findsWidgets);
    expect(find.byIcon(Icons.settings_rounded), findsWidgets);

    // Tap on Settings tab
    await tester.tap(find.byIcon(Icons.settings_rounded).first);
    await tester.pumpAndSettle();

    // Verify DealerSettingsScreen is displayed
    expect(find.byType(DealerSettingsScreen), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Log Out'), findsOneWidget);
  });

  testWidgets('DealerSettingsScreen renders and direct logout navigates to LoginScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DealerSettingsScreen(isStandalone: true),
      ),
    );

    // Verify profile summary & logout option
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Log Out'), findsOneWidget);
    expect(find.text('End dealer session and return to login screen'), findsOneWidget);

    // Tap Log Out
    await tester.tap(find.text('Log Out'));
    await tester.pumpAndSettle();

    // Verify directly navigated to LoginScreen
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  test('AgriProductModel supports 1 to 5 images, toMap, fromMap and copyWith', () {
    const images = [
      'https://example.com/img1.jpg',
      'https://example.com/img2.jpg',
      'https://example.com/img3.jpg',
    ];

    final product = AgriProductModel(
      id: 'test-1',
      nameEnglish: 'Test Seeds',
      nameUrdu: 'ٹیسٹ بیج',
      category: AgriProductCategory.seeds,
      companyEnglish: 'Test Agri Ltd',
      companyUrdu: 'ٹیسٹ لمیٹڈ',
      packSizeEnglish: '50 kg Bag',
      packSizeUrdu: '۵۰ کلو بوری',
      price: 5000,
      originalPrice: 5500,
      rating: 4.8,
      reviewsCount: 12,
      inStock: true,
      imageUrl: images.first,
      imageUrls: images,
    );

    expect(product.allImages.length, 3);
    expect(product.allImages[0], images[0]);
    expect(product.allImages[2], images[2]);

    final map = product.toMap();
    expect(map['imageUrls'], images);
    expect(map['nameEnglish'], 'Test Seeds');

    final restored = AgriProductModel.fromMap(map, 'test-1');
    expect(restored.id, 'test-1');
    expect(restored.allImages.length, 3);
    expect(restored.inStock, true);

    final modified = restored.copyWith(inStock: false);
    expect(modified.inStock, false);
    expect(modified.allImages.length, 3);
  });

  testWidgets('ProductSafeImage renders without crash with contain fit', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProductSafeImage(
            imageUrl: 'https://example.com/seed.jpg',
            category: AgriProductCategory.seeds,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );

    expect(find.byType(ProductSafeImage), findsOneWidget);
  });

  test('ProductFirebaseService saves product and streams updates', () async {
    final service = ProductFirebaseService.instance;
    final testProduct = AgriProductModel(
      id: 'unit-test-prod',
      nameEnglish: 'Firebase Realtime Fertilizer',
      nameUrdu: 'ریئل ٹائم کھاد',
      category: AgriProductCategory.fertilizers,
      companyEnglish: 'Engro',
      companyUrdu: 'اینگرو',
      packSizeEnglish: '50 kg Bag',
      packSizeUrdu: '۵۰ کلو بوری',
      price: 12000,
      originalPrice: 12500,
      rating: 5.0,
      reviewsCount: 1,
      inStock: true,
      imageUrl: 'https://example.com/fertilizer.jpg',
      imageUrls: const ['https://example.com/fertilizer.jpg'],
    );

    await service.saveProduct(testProduct);
    final products = await service.streamProducts().first;
    expect(products.any((p) => p.id == 'unit-test-prod'), isTrue);

    await service.toggleStock('unit-test-prod', false);
    final updatedList = await service.streamProducts().first;
    final found = updatedList.firstWhere((p) => p.id == 'unit-test-prod');
    expect(found.inStock, isFalse);
  });
}
