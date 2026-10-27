import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sabzdost/features/home/screens/dashboard_screen.dart';
import 'package:sabzdost/features/home/screens/farmer_settings_screen.dart';
import 'package:sabzdost/features/ledger/models/ledger_entry.dart';
import 'package:sabzdost/features/ledger/screens/crop_khata_detail_screen.dart';
import 'package:sabzdost/features/ledger/screens/farm_ledger_screen.dart';
import 'package:sabzdost/features/ledger/widgets/add_ledger_entry_sheet.dart';

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
}
