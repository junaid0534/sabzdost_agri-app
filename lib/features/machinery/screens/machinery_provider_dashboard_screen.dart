import 'package:flutter/material.dart';
import '../../../core/localization/language_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../auth/controllers/user_session_controller.dart';
import '../models/machinery_model.dart';
import 'add_machine_screen.dart';

class ProviderBookingItem {
  final String id;
  final String farmerNameUrdu;
  final String farmerNameEnglish;
  final String farmerPhone;
  final String machineNameUrdu;
  final String machineNameEnglish;
  final String machineCategory;
  final String locationUrdu;
  final String locationEnglish;
  final double distanceKm;
  final String workDetailsUrdu;
  final String workDetailsEnglish;
  final double totalAmount;
  final String scheduledDateUrdu;
  final String scheduledDateEnglish;
  String status; // 'pending', 'accepted', 'in_progress', 'completed'

  ProviderBookingItem({
    required this.id,
    required this.farmerNameUrdu,
    required this.farmerNameEnglish,
    required this.farmerPhone,
    required this.machineNameUrdu,
    required this.machineNameEnglish,
    required this.machineCategory,
    required this.locationUrdu,
    required this.locationEnglish,
    required this.distanceKm,
    required this.workDetailsUrdu,
    required this.workDetailsEnglish,
    required this.totalAmount,
    required this.scheduledDateUrdu,
    required this.scheduledDateEnglish,
    required this.status,
  });

  String getFarmerName(bool isUrdu) => isUrdu ? farmerNameUrdu : farmerNameEnglish;
  String getMachineName(bool isUrdu) => isUrdu ? machineNameUrdu : machineNameEnglish;
  String getLocation(bool isUrdu) => isUrdu ? locationUrdu : locationEnglish;
  String getWorkDetails(bool isUrdu) => isUrdu ? workDetailsUrdu : workDetailsEnglish;
  String getScheduledDate(bool isUrdu) => isUrdu ? scheduledDateUrdu : scheduledDateEnglish;

  // Convenient fallback getters
  String get farmerName => farmerNameUrdu;
  String get machineName => machineNameUrdu;
  String get location => locationUrdu;
  String get workDetails => workDetailsUrdu;
  String get scheduledDate => scheduledDateUrdu;
}

class MachineryProviderDashboardScreen extends StatefulWidget {
  final bool? isUrdu;

  const MachineryProviderDashboardScreen({super.key, this.isUrdu});

  @override
  State<MachineryProviderDashboardScreen> createState() =>
      _MachineryProviderDashboardScreenState();
}

class _MachineryProviderDashboardScreenState
    extends State<MachineryProviderDashboardScreen> {
  bool get _isUrdu => LanguageController.instance.isUrdu;
  int _selectedBottomNav = 0; // 0: Home, 1: Bookings, 2: Fleet, 3: Khata
  int _selectedBookingFilter = 0; // 0: All, 1: Pending, 2: Active, 3: Completed

  // State: Registered Machinery Fleet
  final List<MachineryModel> _myFleet = [
    const MachineryModel(
      id: "p1",
      name: "Claas Crop Tiger 30",
      urduName: "کلاس ہارویسٹر 30",
      category: "Harvester",
      distanceKm: 0.0,
      rate: 4500,
      rateUnit: "Acre",
      ownerName: "ملک اسلم",
      ownerPhone: "0300-7382910",
      location: "شجاع آباد، ملتان",
      rating: 4.9,
      completedJobs: 138,
      isAvailable: true,
      imageUrl: "https://images.unsplash.com/photo-1592982537447-7440770cbfc9?q=80&w=400&auto=format&fit=crop",
    ),
    const MachineryModel(
      id: "p2",
      name: "Greenland Laser Leveler",
      urduName: "گرین لینڈ لیزر لیولر",
      category: "Laser Leveler",
      distanceKm: 0.0,
      rate: 1800,
      rateUnit: "Hour",
      ownerName: "ملک اسلم",
      ownerPhone: "0300-7382910",
      location: "شجاع آباد، ملتان",
      rating: 4.8,
      completedJobs: 94,
      isAvailable: true,
      imageUrl: "https://images.unsplash.com/photo-1595009552535-be753447727e?q=80&w=400&auto=format&fit=crop",
    ),
    const MachineryModel(
      id: "p3",
      name: "DJI Agras T40 Spray Drone",
      urduName: "سپرے ڈرون T40 (40L)",
      category: "Agri Drone",
      distanceKm: 0.0,
      rate: 900,
      rateUnit: "Acre",
      ownerName: "ملک اسلم",
      ownerPhone: "0300-7382910",
      location: "شجاع آباد، ملتان",
      rating: 5.0,
      completedJobs: 215,
      isAvailable: false,
      imageUrl: "https://images.unsplash.com/photo-1508614589041-895b88991e3e?q=80&w=400&auto=format&fit=crop",
    ),
    const MachineryModel(
      id: "p4",
      name: "New Holland Straw Baler",
      urduName: "سٹرا بیلر (گٹھی)",
      category: "Straw Baler",
      distanceKm: 0.0,
      rate: 45,
      rateUnit: "Bale",
      ownerName: "ملک اسلم",
      ownerPhone: "0300-7382910",
      location: "شجاع آباد، ملتان",
      rating: 4.7,
      completedJobs: 82,
      isAvailable: true,
      imageUrl: "https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=400&auto=format&fit=crop",
    ),
  ];

  // State: Live Bookings List (Full Bilingual & Explicit Accepted State for Upcoming Reminder)
  final List<ProviderBookingItem> _bookings = [
    ProviderBookingItem(
      id: "b101",
      farmerNameUrdu: "چوہدری ریاض احمد",
      farmerNameEnglish: "Chaudhry Riaz Ahmed",
      farmerPhone: "0300-8472910",
      machineNameUrdu: "کلاس ہارویسٹر 30",
      machineNameEnglish: "Claas Crop Tiger 30",
      machineCategory: "Harvester",
      locationUrdu: "موضع جلال پور، ملتان",
      locationEnglish: "Jalalpur, Multan",
      distanceKm: 6.2,
      workDetailsUrdu: "15 ایکڑ گندم کٹائی",
      workDetailsEnglish: "15 Acres Wheat Harvesting",
      totalAmount: 67500,
      scheduledDateUrdu: "آج، صبح 8:30 بجے",
      scheduledDateEnglish: "Today, 08:30 AM",
      status: "pending",
    ),
    ProviderBookingItem(
      id: "b102",
      farmerNameUrdu: "ملک طارق حسین",
      farmerNameEnglish: "Malik Tariq Hussain",
      farmerPhone: "0302-9918234",
      machineNameUrdu: "گرین لینڈ لیزر لیولر",
      machineNameEnglish: "Greenland Laser Leveler",
      machineCategory: "Laser Leveler",
      locationUrdu: "کبیر والا روڈ، ملتان",
      locationEnglish: "Kabirwala Road, Multan",
      distanceKm: 4.8,
      workDetailsUrdu: "6 گھنٹے لیزر لیولنگ",
      workDetailsEnglish: "6 Hours Laser Leveling",
      totalAmount: 10800,
      scheduledDateUrdu: "آج، دوپہر 2:00 بجے",
      scheduledDateEnglish: "Today, 02:00 PM",
      status: "accepted",
    ),
    ProviderBookingItem(
      id: "b103",
      farmerNameUrdu: "حاجی فاروق وٹو",
      farmerNameEnglish: "Haji Farooq Wattoo",
      farmerPhone: "0306-1234567",
      machineNameUrdu: "سپرے ڈرون T40",
      machineNameEnglish: "DJI Agras T40 Spray Drone",
      machineCategory: "Agri Drone",
      locationUrdu: "بوسن روڈ، ملتان",
      locationEnglish: "Bosan Road, Multan",
      distanceKm: 8.5,
      workDetailsUrdu: "25 ایکڑ کپاس اسپرے",
      workDetailsEnglish: "25 Acres Cotton Spray",
      totalAmount: 22500,
      scheduledDateUrdu: "کل، صبح 6:30 بجے",
      scheduledDateEnglish: "Tomorrow, 06:30 AM",
      status: "pending",
    ),
    ProviderBookingItem(
      id: "b104",
      farmerNameUrdu: "میاں ناصر خان",
      farmerNameEnglish: "Mian Nasir Khan",
      farmerPhone: "0301-4455667",
      machineNameUrdu: "سٹرا بیلر (گٹھی)",
      machineNameEnglish: "New Holland Straw Baler",
      machineCategory: "Straw Baler",
      locationUrdu: "لودھراں بائی پاس، ملتان",
      locationEnglish: "Lodhran Bypass, Multan",
      distanceKm: 14.0,
      workDetailsUrdu: "350 گٹھیاں (Bales)",
      workDetailsEnglish: "350 Bales Straw Baling",
      totalAmount: 15750,
      scheduledDateUrdu: "کل، شام 4:00 بجے",
      scheduledDateEnglish: "Tomorrow, 04:00 PM",
      status: "completed",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageController.instance,
      builder: (context, _) {
        final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

        return ResponsiveLayout(
          child: Directionality(
            textDirection: _isUrdu ? TextDirection.rtl : TextDirection.ltr,
            child: Scaffold(
              backgroundColor: AppColors.background,
              body: SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: 18,
                    right: 18,
                    top: isLandscape ? 6 : 12,
                    bottom: isLandscape ? 64 : 86,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. TOP HEADER (Clean, Compact, Centered Texts)
                      _buildTopHeader(),
                      SizedBox(height: isLandscape ? 16 : 22),

                      // 2. TAB-BASED BODY CONTENT
                      if (_selectedBottomNav == 0) ...[
                        if (isLandscape) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               // Left Column: Upcoming Booking + Quick Actions
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildUpcomingBookingCard(),
                                    const SizedBox(height: 22),
                                    _buildQuickActionsRow(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              // Right Column: Live Bookings Orders
                              Expanded(
                                flex: 6,
                                child: _buildBookingsSection(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          _buildMyFleetSection(),
                        ] else ...[
                          _buildUpcomingBookingCard(),
                          const SizedBox(height: 22),
                          _buildQuickActionsRow(),
                          const SizedBox(height: 24),
                          _buildBookingsSection(),
                          const SizedBox(height: 22),
                          _buildMyFleetSection(),
                        ],
                      ] else if (_selectedBottomNav == 1) ...[
                        _buildBookingsSection(),
                      ] else if (_selectedBottomNav == 2) ...[
                        _buildMyFleetSection(),
                      ] else if (_selectedBottomNav == 3) ...[
                        _buildKhataSection(),
                      ],
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: _buildFloatingBottomNav(),
            ),
          ),
        );
      },
    );
  }

  // --- 1. CLEAN TOP HEADER (Texts Centered) ---
  Widget _buildTopHeader() {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final double iconBoxSize = isLandscape ? 36 : 42;
    final double innerIconSize = isLandscape ? 18 : 22;

    final providerName = UserSessionController.instance.businessOrFarmName.isNotEmpty
        ? UserSessionController.instance.businessOrFarmName
        : (_isUrdu ? "ملک ایگرو سروسز" : "Malik Agro Services");

    final district = UserSessionController.instance.district.isNotEmpty
        ? UserSessionController.instance.district
        : (_isUrdu ? "ملتان" : "Multan");

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: Compact Icon Box
        Container(
          width: iconBoxSize,
          height: iconBoxSize,
          decoration: BoxDecoration(
            gradient: AppColors.greenGradient,
            borderRadius: BorderRadius.circular(isLandscape ? 10 : 13),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.15),
                blurRadius: isLandscape ? 6 : 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.agriculture_rounded,
              color: AppColors.accentLime,
              size: innerIconSize,
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Center: Business Title & District (Centered)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                providerName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _isUrdu
                    ? AppTheme.urdu(
                        fontSize: isLandscape ? 14 : 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                      )
                    : AppTheme.english(
                        fontSize: isLandscape ? 14 : 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                        letterSpacing: -0.3,
                      ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 11,
                    color: Color(0xFF2E7D32),
                  ),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      _isUrdu ? "$district • تصدیق شدہ سروس سینٹر" : "$district • Verified Service Center",
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isLandscape ? 9.5 : 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Right: Language Switcher Toggle Pill [اردو | EN]
        InkWell(
          onTap: () {
            LanguageController.instance.toggleLanguage();
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isLandscape ? 9 : 11,
              vertical: isLandscape ? 4 : 5.5,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              _isUrdu ? "EN" : "اردو",
              style: TextStyle(
                fontSize: isLandscape ? 10 : 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- 2. UPCOMING BOOKING REMINDER CARD (Only Accepted/In-Progress, Weather Card Colors, Generous Size) ---
  Widget _buildUpcomingBookingCard() {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    // Filter ONLY confirmed bookings (accepted or in_progress, NOT pending)
    final confirmedBookings = _bookings.where(
      (b) => b.status == 'accepted' || b.status == 'in_progress',
    ).toList();
    final nextBooking = confirmedBookings.isNotEmpty ? confirmedBookings.first : null;

    if (nextBooking == null) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(isLandscape ? 14 : 18),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_available_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isUrdu ? "کوئی تصدیق شدہ اگلی بکنگ نہیں" : "No Confirmed Upcoming Bookings",
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isUrdu
                        ? "نئے آرڈرز نیچے بکنگ لسٹ میں چیک کریں اور قبول کریں"
                        : "Check pending requests in the orders list below to accept",
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isLandscape ? 14 : 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: AppColors.freshLeafGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryMedium.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Reminder Pill + Scheduled Date & Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.notifications_active_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _isUrdu ? "اگلی بکنگ ریمائنڈر" : "Next Booking",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time_filled_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    nextBooking.getScheduledDate(_isUrdu),
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Farmer Name & Total Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        nextBooking.getFarmerName(_isUrdu),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  "Rs. ${nextBooking.totalAmount.round()}",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1B4332),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Kaam Kitna Hai (Work details & machine)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.agriculture_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    "${nextBooking.getMachineName(_isUrdu)}  •  ${nextBooking.getWorkDetails(_isUrdu)}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Location Row
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 14,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  "${nextBooking.getLocation(_isUrdu)} (${nextBooking.distanceKm} km)",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Exactly 2 Buttons: Navigation & Call
          Row(
            children: [
              // 1. Navigation Button (White Button with Dark Green Text)
              Expanded(
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  elevation: 1,
                  shadowColor: Colors.black26,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _isUrdu
                                ? "${nextBooking.getLocation(_isUrdu)} کی لوکیشن اور راستہ کھولا جا رہا ہے"
                                : "Navigating to ${nextBooking.getLocation(_isUrdu)} (${nextBooking.distanceKm} km)",
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: const Color(0xFF1B4332),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9.5),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.directions_rounded,
                            size: 16,
                            color: Color(0xFF1B4332),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _isUrdu ? "راستہ" : "Navigate",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1B4332),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // 2. Call Button (Dark Forest Green Button with White Text)
              Expanded(
                child: Material(
                  color: const Color(0xFF1B4332),
                  borderRadius: BorderRadius.circular(12),
                  elevation: 1,
                  shadowColor: Colors.black26,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _isUrdu
                                ? "${nextBooking.getFarmerName(_isUrdu)} کو کال ملائی جا رہی ہے: ${nextBooking.farmerPhone}"
                                : "Calling ${nextBooking.getFarmerName(_isUrdu)}: ${nextBooking.farmerPhone}",
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: const Color(0xFF2E7D32),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9.5),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.phone_in_talk_rounded,
                            size: 15,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _isUrdu ? "کسان کو کال" : "Call Farmer",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 3. QUICK ACTIONS ROW ---
  Widget _buildQuickActionsRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isUrdu ? "فوری سہولیات" : "Quick Actions",
          style: _isUrdu
              ? AppTheme.urdu(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                )
              : AppTheme.english(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // 1. Add Machine
            Expanded(
              child: _buildProviderActionTile(
                icon: Icons.add_circle_outline_rounded,
                title: _isUrdu ? "نئی مشین" : "Add Machine",
                color: const Color(0xFF257538),
                bgColor: const Color(0xFFE8F5E9),
                onTap: _showAddMachineDialog,
              ),
            ),
            const SizedBox(width: 8),

            // 2. Diesel & Expenses Log
            Expanded(
              child: _buildProviderActionTile(
                icon: Icons.local_gas_station_rounded,
                title: _isUrdu ? "ڈیزل لاگ" : "Diesel Log",
                color: const Color(0xFFE65100),
                bgColor: const Color(0xFFFFF3E0),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _isUrdu ? "ڈیزل و مینٹیننس لاگ کھولا جا رہا ہے" : "Opening Diesel & Maintenance Log",
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: AppColors.primaryDark,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),

            // 3. Schedule & Calendar
            Expanded(
              child: _buildProviderActionTile(
                icon: Icons.calendar_month_rounded,
                title: _isUrdu ? "شیڈول" : "Schedule",
                color: const Color(0xFF00838F),
                bgColor: const Color(0xFFE0F7FA),
                onTap: () {
                  setState(() {
                    _selectedBottomNav = 1;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),

            // 4. Client Directory
            Expanded(
              child: _buildProviderActionTile(
                icon: Icons.account_balance_wallet_rounded,
                title: _isUrdu ? "کھاتہ" : "Ledger",
                color: const Color(0xFF5E35B1),
                bgColor: const Color(0xFFEDE7F6),
                onTap: () {
                  setState(() {
                    _selectedBottomNav = 3;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProviderActionTile({
    required IconData icon,
    required String title,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.7)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 7),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: _isUrdu
                  ? AppTheme.urdu(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    )
                  : AppTheme.english(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 4. LIVE BOOKINGS SECTION ---
  Widget _buildBookingsSection() {
    final pendingCount = _bookings.where((b) => b.status == 'pending').length;
    final activeCount = _bookings.where((b) => b.status == 'accepted' || b.status == 'in_progress').length;
    final completedCount = _bookings.where((b) => b.status == 'completed').length;

    final filtered = _bookings.where((b) {
      if (_selectedBookingFilter == 1) return b.status == 'pending';
      if (_selectedBookingFilter == 2) return b.status == 'accepted' || b.status == 'in_progress';
      if (_selectedBookingFilter == 3) return b.status == 'completed';
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E7D32),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _isUrdu ? "کسان آرڈرز و درخواستیں" : "Farmer Booking Orders",
                  style: _isUrdu
                      ? AppTheme.urdu(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        )
                      : AppTheme.english(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                ),
              ],
            ),
            Text(
              "${filtered.length} ${_isUrdu ? 'آرڈرز' : 'Orders'}",
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Filter Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildFilterPill(0, _isUrdu ? "تمام (${_bookings.length})" : "All (${_bookings.length})"),
              const SizedBox(width: 6),
              _buildFilterPill(1, _isUrdu ? "زیر التواء ($pendingCount)" : "Pending ($pendingCount)"),
              const SizedBox(width: 6),
              _buildFilterPill(2, _isUrdu ? "تصدیق شدہ ($activeCount)" : "Confirmed ($activeCount)"),
              const SizedBox(width: 6),
              _buildFilterPill(3, _isUrdu ? "مکمل ($completedCount)" : "Completed ($completedCount)"),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Bookings Card List
        if (filtered.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Center(
              child: Text(
                _isUrdu ? "اس کیٹیگری میں کوئی آرڈر نہیں ہے" : "No orders found in this category",
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5, fontWeight: FontWeight.w600),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return _buildBookingCard(filtered[index]);
            },
          ),
      ],
    );
  }

  Widget _buildFilterPill(int index, String label) {
    final isSelected = _selectedBookingFilter == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedBookingFilter = index;
        });
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDark : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primaryDark : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(ProviderBookingItem item) {
    Color statusBg;
    Color statusText;
    String statusLabel;

    if (item.status == 'pending') {
      statusBg = const Color(0xFFFFF3E0);
      statusText = const Color(0xFFE65100);
      statusLabel = _isUrdu ? "زیر التواء" : "Pending";
    } else if (item.status == 'accepted') {
      statusBg = const Color(0xFFE8F5E9);
      statusText = const Color(0xFF2E7D32);
      statusLabel = _isUrdu ? "تصدیق شدہ" : "Confirmed";
    } else if (item.status == 'in_progress') {
      statusBg = const Color(0xFFE0F7FA);
      statusText = const Color(0xFF00838F);
      statusLabel = _isUrdu ? "جاری" : "Active";
    } else {
      statusBg = const Color(0xFFF1F8E9);
      statusText = const Color(0xFF33691E);
      statusLabel = _isUrdu ? "مکمل" : "Done";
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Machine Name, Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.agriculture_rounded,
                        color: AppColors.primaryDark,
                        size: 15,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        item.getMachineName(_isUrdu),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: statusText,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          // Middle: Farmer details & location
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 13, color: AppColors.textMuted),
              const SizedBox(width: 3),
              Text(
                item.getFarmerName(_isUrdu),
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.location_on_outlined, size: 13, color: AppColors.accentLime),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  "${item.getLocation(_isUrdu)} (${item.distanceKm} km)",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Work Scope & Amount Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.work_outline_rounded, size: 13, color: AppColors.primaryMedium),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.getWorkDetails(_isUrdu),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "Rs. ${item.totalAmount.round()}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Actions Row: Call Farmer & Status Buttons
          Row(
            children: [
              // Call Button
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _isUrdu ? "${item.getFarmerName(_isUrdu)} کو کال ملائی جا رہی ہے: ${item.farmerPhone}" : "Calling ${item.getFarmerName(_isUrdu)}: ${item.farmerPhone}",
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: const Color(0xFF2E7D32),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  side: const BorderSide(color: Color(0xFF2E7D32)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  minimumSize: const Size(0, 30),
                ),
                icon: const Icon(Icons.call_rounded, size: 13, color: Color(0xFF2E7D32)),
                label: Text(
                  _isUrdu ? "کال" : "Call",
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF2E7D32)),
                ),
              ),
              const SizedBox(width: 6),

              // Action Trigger Button based on status
              Expanded(
                child: item.status == 'pending'
                    ? ElevatedButton(
                        onPressed: () {
                          setState(() {
                            item.status = 'accepted';
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _isUrdu ? "بکنگ قبول ہو گئی اور اگلی بکنگ ریمائنڈر میں شامل ہو گئی!" : "Booking accepted! Added to upcoming reminder.",
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: AppColors.primaryDark,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                          minimumSize: const Size(0, 30),
                        ),
                        child: Text(
                          _isUrdu ? "قبول کریں" : "Accept",
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      )
                    : item.status == 'accepted'
                        ? ElevatedButton(
                            onPressed: () {
                              setState(() {
                                item.status = 'in_progress';
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _isUrdu ? "کام شروع ہو گیا!" : "Work started!",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: const Color(0xFF00838F),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00838F),
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                              minimumSize: const Size(0, 30),
                            ),
                            child: Text(
                              _isUrdu ? "کام شروع کریں" : "Start Job",
                              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          )
                        : item.status == 'in_progress'
                            ? ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    item.status = 'completed';
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        _isUrdu ? "کام مکمل مارک کر دیا گیا!" : "Job marked as completed!",
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                      backgroundColor: const Color(0xFF2E7D32),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E7D32),
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                  minimumSize: const Size(0, 30),
                                ),
                                child: Text(
                                  _isUrdu ? "مکمل مارک کریں" : "Mark Done",
                                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                              )
                            : Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Text(
                                  _isUrdu ? "مکمل شدہ" : "Completed",
                                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF2E7D32)),
                                ),
                              ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 5. MY MACHINERY FLEET SECTION ---
  Widget _buildMyFleetSection() {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.precision_manufacturing_rounded,
                  size: 17,
                  color: AppColors.primaryMedium,
                ),
                const SizedBox(width: 6),
                Text(
                  _isUrdu ? "مشینری فلیٹ" : "My Fleet",
                  style: _isUrdu
                      ? AppTheme.urdu(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        )
                      : AppTheme.english(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${_myFleet.length}",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryMedium,
                    ),
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: _showAddMachineDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add_rounded, size: 14, color: AppColors.primaryDark),
                    const SizedBox(width: 2),
                    Text(
                      _isUrdu ? "نئی مشین" : "Add Machine",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (isLandscape)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              mainAxisExtent: 78,
            ),
            itemCount: _myFleet.length,
            itemBuilder: (context, index) {
              return _buildFleetMachineCard(_myFleet[index]);
            },
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _myFleet.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return _buildFleetMachineCard(_myFleet[index]);
            },
          ),
      ],
    );
  }

  Widget _buildFleetMachineCard(MachineryModel machine) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 54,
              height: 54,
              child: Image.network(
                machine.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.surfaceAlt,
                  child: const Icon(Icons.agriculture_rounded, color: AppColors.primaryMedium, size: 22),
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _isUrdu ? machine.urduName : machine.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _isUrdu
                            ? AppTheme.urdu(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              )
                            : AppTheme.english(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: machine.isAvailable ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        machine.isAvailable
                            ? (_isUrdu ? "دستیاب" : "Ready")
                            : (_isUrdu ? "مصروف" : "Busy"),
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          color: machine.isAvailable ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Rs. ${machine.rate.round()}/${_isUrdu ? (machine.rateUnit == 'Acre' ? 'ایکڑ' : machine.rateUnit == 'Hour' ? 'گھنٹہ' : 'گٹھی') : machine.rateUnit}",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF257538),
                      ),
                    ),
                    Text(
                      "${machine.completedJobs} ${_isUrdu ? 'کام' : 'Jobs'} • ${machine.rating}★",
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 6. KHATA / FINANCIAL EARNINGS SECTION (Tab 3) ---
  Widget _buildKhataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 18,
                  color: Color(0xFF2E7D32),
                ),
                const SizedBox(width: 6),
                Text(
                  _isUrdu ? "مشینری کھاتہ و آمدن" : "Machinery Khata & Revenue",
                  style: _isUrdu
                      ? AppTheme.urdu(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        )
                      : AppTheme.english(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _isUrdu ? "اس ماہ کا ریکارڈ" : "This Month",
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Financial Overview Cards
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isUrdu ? "کل موصول آمدن" : "Total Revenue",
                      style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Rs. 485,000",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF2E7D32)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isUrdu ? "ڈیزل و اخراجات" : "Fuel Cost",
                      style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Rs. 92,000",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFFE65100)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isUrdu ? "خالص بچت" : "Net Profit",
                      style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Rs. 393,000",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF00838F)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Recent Client Payment History
        Text(
          _isUrdu ? "حالیہ کسان کھاتہ ٹرانزیکشنز" : "Recent Farmer Ledger Entries",
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),

        _buildKhataEntryTile(
          farmer: _isUrdu ? "چوہدری ریاض احمد" : "Chaudhry Riaz Ahmed",
          machine: _isUrdu ? "کلاس ہارویسٹر (15 ایکڑ کٹائی)" : "Claas Harvester (15 Acres)",
          amount: 67500,
          isPaid: true,
          date: _isUrdu ? "آج، 10:30 AM" : "Today, 10:30 AM",
        ),
        const SizedBox(height: 8),
        _buildKhataEntryTile(
          farmer: _isUrdu ? "ملک طارق حسین" : "Malik Tariq Hussain",
          machine: _isUrdu ? "لیزر لیولر (6 گھنٹے)" : "Laser Leveler (6 Hours)",
          amount: 10800,
          isPaid: false,
          date: _isUrdu ? "کل، 5:00 PM" : "Yesterday, 05:00 PM",
        ),
        const SizedBox(height: 8),
        _buildKhataEntryTile(
          farmer: _isUrdu ? "حاجی فاروق وٹو" : "Haji Farooq Wattoo",
          machine: _isUrdu ? "سپرے ڈرون (25 ایکڑ)" : "Spray Drone (25 Acres)",
          amount: 22500,
          isPaid: true,
          date: _isUrdu ? "11 اکتوبر" : "11 Oct",
        ),
      ],
    );
  }

  Widget _buildKhataEntryTile({
    required String farmer,
    required String machine,
    required double amount,
    required bool isPaid,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.7)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isPaid ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isPaid ? Icons.check_circle_outline_rounded : Icons.pending_outlined,
                  size: 16,
                  color: isPaid ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    farmer,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    machine,
                    style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Rs. ${amount.round()}",
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: isPaid ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isPaid ? (_isUrdu ? "موصول شدہ" : "Received") : (_isUrdu ? "باقی رقم" : "Pending"),
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: isPaid ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 7. FLOATING MODERN BOTTOM NAV (Matches App Theme) ---
  Widget _buildFloatingBottomNav() {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(
        left: isLandscape ? 36 : 18,
        right: isLandscape ? 36 : 18,
        bottom: isLandscape ? 6 : 14,
        top: 2,
      ),
      child: Container(
        height: isLandscape ? 50 : 64,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(isLandscape ? 25 : 32),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.10),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              index: 0,
              icon: Icons.home_rounded,
              label: _isUrdu ? "ہوم" : "Home",
              isLandscape: isLandscape,
            ),
            _buildNavItem(
              index: 1,
              icon: Icons.calendar_today_rounded,
              label: _isUrdu ? "بکنگز" : "Bookings",
              isLandscape: isLandscape,
            ),
            _buildNavItem(
              index: 2,
              icon: Icons.agriculture_rounded,
              label: _isUrdu ? "فلیٹ" : "Fleet",
              isLandscape: isLandscape,
            ),
            _buildNavItem(
              index: 3,
              icon: Icons.account_balance_wallet_rounded,
              label: _isUrdu ? "کھاتہ" : "Khata",
              isLandscape: isLandscape,
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
    required bool isLandscape,
  }) {
    final bool isSelected = _selectedBottomNav == index;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedBottomNav = index;
        });
      },
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? (isLandscape ? 12 : 14) : (isLandscape ? 8 : 10),
          vertical: isLandscape ? 5 : 7,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDark : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isLandscape ? 17 : 20,
              color: isSelected ? Colors.white : AppColors.textLight,
            ),
            if (isSelected) ...[
              const SizedBox(width: 5),
              Text(
                label,
                style: _isUrdu
                    ? AppTheme.urdu(
                        color: Colors.white,
                        fontSize: isLandscape ? 10 : 11,
                        fontWeight: FontWeight.w700,
                      )
                    : AppTheme.english(
                        color: Colors.white,
                        fontSize: isLandscape ? 10.5 : 11.5,
                        fontWeight: FontWeight.w700,
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- OPEN ADD NEW MACHINE SCREEN (Dedicated Full Screen with Modern UI/UX) ---
  Future<void> _showAddMachineDialog() async {
    final newMachine = await Navigator.push<MachineryModel>(
      context,
      MaterialPageRoute(
        builder: (_) => AddMachineScreen(isUrdu: _isUrdu),
      ),
    );

    if (newMachine != null && mounted) {
      setState(() {
        _myFleet.insert(0, newMachine);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isUrdu
                ? "${newMachine.name} فلیٹ میں کامیابی سے شامل ہو گئی!"
                : "${newMachine.name} added to fleet successfully!",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
