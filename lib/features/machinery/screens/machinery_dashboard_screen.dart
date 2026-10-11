import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../models/machinery_model.dart';
import 'machinery_booking_screen.dart';

class MachineryDashboardScreen extends StatefulWidget {
  final bool isUrdu;
  final String? initialCategory;

  const MachineryDashboardScreen({
    super.key,
    this.isUrdu = true,
    this.initialCategory,
  });

  @override
  State<MachineryDashboardScreen> createState() => _MachineryDashboardScreenState();
}

class _MachineryDashboardScreenState extends State<MachineryDashboardScreen> {
  int _selectedCategoryIndex = 0;
  String _searchQuery = "";

  final List<Map<String, dynamic>> _categories = [
    {
      "name": "All",
      "urdu": "تمام مشینیں",
      "icon": Icons.apps_rounded,
    },
    {
      "name": "Harvester",
      "urdu": "کمبائن ہارویسٹر",
      "icon": Icons.agriculture_rounded,
    },
    {
      "name": "Laser Leveler",
      "urdu": "لیزر لیولر",
      "icon": Icons.architecture_rounded,
    },
    {
      "name": "Thresher / Sheller",
      "urdu": "تھریشر و شیلر",
      "icon": Icons.settings_suggest_rounded,
    },
    {
      "name": "Straw Baler",
      "urdu": "سٹرا بیلر (پُرالی گٹھیں)",
      "icon": Icons.inventory_2_rounded,
    },
    {
      "name": "Agri Drone",
      "urdu": "سپرے ڈرون",
      "icon": Icons.flight_takeoff_rounded,
    },
    {
      "name": "Rotavator / Plow",
      "urdu": "روٹاویٹر و ہل",
      "icon": Icons.landscape_rounded,
    },
  ];

  final List<MachineryModel> _allMachines = [
    const MachineryModel(
      id: "m1",
      name: "Claas Crop Tiger 30",
      urduName: "کلاس ہارویسٹر",
      category: "Harvester",
      distanceKm: 4.2,
      rate: 4500,
      rateUnit: "Acre",
      ownerName: "ملک اسلم",
      ownerPhone: "03007382910",
      location: "شجاع آباد، ملتان",
      rating: 4.9,
      completedJobs: 138,
      isAvailable: true,
      imageUrl: "https://images.unsplash.com/photo-1592982537447-7440770cbfc9?q=80&w=400&auto=format&fit=crop",
    ),
    const MachineryModel(
      id: "m2",
      name: "Greenland Laser Leveler",
      urduName: "لیزر لیولر",
      category: "Laser Leveler",
      distanceKm: 8.5,
      rate: 1800,
      rateUnit: "Hour",
      ownerName: "رانا طارق",
      ownerPhone: "03018294711",
      location: "کبیروالا",
      rating: 4.8,
      completedJobs: 94,
      isAvailable: true,
      imageUrl: "https://images.unsplash.com/photo-1595009552535-be753447727e?q=80&w=400&auto=format&fit=crop",
    ),
    const MachineryModel(
      id: "m3",
      name: "DJI Agras T40 Spray Drone",
      urduName: "سپرے ڈرون (40L)",
      category: "Agri Drone",
      distanceKm: 3.1,
      rate: 900,
      rateUnit: "Acre",
      ownerName: "ایگرو ٹیک",
      ownerPhone: "03039918234",
      location: "بوسن روڈ، ملتان",
      rating: 5.0,
      completedJobs: 215,
      isAvailable: true,
      imageUrl: "https://images.unsplash.com/photo-1508614589041-895b88991e3e?q=80&w=400&auto=format&fit=crop",
    ),
    const MachineryModel(
      id: "m4",
      name: "New Holland Straw Baler",
      urduName: "سٹرا بیلر (گٹھی)",
      category: "Straw Baler",
      distanceKm: 12.0,
      rate: 45,
      rateUnit: "Bale",
      ownerName: "چوہدری بشیر",
      ownerPhone: "03006391024",
      location: "لودھراں",
      rating: 4.7,
      completedJobs: 82,
      isAvailable: false,
      imageUrl: "https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=400&auto=format&fit=crop",
    ),
    const MachineryModel(
      id: "m5",
      name: "Wheat Thresher",
      urduName: "گندم تھریشر",
      category: "Thresher / Sheller",
      distanceKm: 6.8,
      rate: 3200,
      rateUnit: "Hour",
      ownerName: "جام فاروق",
      ownerPhone: "03061239845",
      location: "جلال پور",
      rating: 4.6,
      completedJobs: 67,
      isAvailable: true,
      imageUrl: "https://images.unsplash.com/photo-1592982537447-7440770cbfc9?q=80&w=400&auto=format&fit=crop",
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
      final index = _categories.indexWhere((c) => c["name"] == widget.initialCategory);
      if (index != -1) {
        _selectedCategoryIndex = index;
      }
    }
  }

  List<MachineryModel> get _filteredMachines {
    return _allMachines.where((m) {
      final matchesCategory = _selectedCategoryIndex == 0 ||
          m.category == _categories[_selectedCategoryIndex]["name"];
      final matchesCity = _searchQuery.isEmpty ||
          m.location.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesCity;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryDark, size: 24),
            onPressed: () => Navigator.maybePop(context),
          ),
          centerTitle: true,
          title: Text(
            widget.initialCategory ?? "Machinery",
            style: AppTheme.english(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Search by City Only
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(23),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (v) {
                      setState(() {
                        _searchQuery = v.trim();
                      });
                    },
                    style: AppTheme.english(fontSize: 13, color: AppColors.textDark),
                    decoration: InputDecoration(
                      hintText: "Search by City (e.g. Multan, Khanewal)...",
                      hintStyle: AppTheme.english(fontSize: 12, color: AppColors.textLight),
                      prefixIcon: const Icon(Icons.location_city_rounded, size: 20, color: AppColors.primaryMedium),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // Machinery Cards List
              Expanded(
                child: _filteredMachines.isEmpty
                    ? Center(
                        child: Text(
                          "No machinery found in this category",
                          style: AppTheme.english(color: AppColors.textMuted, fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 6.0),
                        itemCount: _filteredMachines.length,
                        itemBuilder: (context, index) {
                          final machine = _filteredMachines[index];
                          return _buildMachineryCard(machine);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMachineryCard(MachineryModel machine) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Icon + Title + Status Pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.agriculture_rounded,
                  color: AppColors.primaryMedium,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      machine.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.english(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6), // Increased distance to prevent overlapping
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 13, color: AppColors.primaryMedium),
                        const SizedBox(width: 3),
                        Text(
                          machine.location,
                          style: AppTheme.urdu(
                            fontSize: 11,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text("•", style: TextStyle(color: AppColors.textLight, fontSize: 10)),
                        const SizedBox(width: 8),
                        const Icon(Icons.navigation_rounded, size: 11, color: AppColors.primaryMedium),
                        const SizedBox(width: 3),
                        Text(
                          "${machine.distanceKm} km away",
                          style: AppTheme.english(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: machine.isAvailable
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  machine.isAvailable ? "Available" : "Booked",
                  style: AppTheme.english(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: machine.isAvailable
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFC62828),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(color: AppColors.borderLight, height: 1),
          const SizedBox(height: 10),

          // Row 2: Rate & Clean Book Button (English only)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Rs. ${machine.rate.toInt()} / ${machine.rateUnit}",
                style: AppTheme.english(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: machine.isAvailable
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MachineryBookingScreen(
                                machine: machine,
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Book Now",
                        style: AppTheme.english(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded, color: AppColors.accentLime, size: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
