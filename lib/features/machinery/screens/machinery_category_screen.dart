import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';
import 'machinery_dashboard_screen.dart';

class MachineryCategoryScreen extends StatelessWidget {
  final bool isUrdu;

  const MachineryCategoryScreen({
    super.key,
    this.isUrdu = true,
  });

  static const List<Map<String, dynamic>> categories = [
    {
      "id": "all",
      "name": "All Machinery",
      "urdu": "تمام زرعی مشینیں",
      "desc": "Browse all available farm equipment",
      "urduDesc": "تمام دستیاب زرعی آلات دیکھیں",
      "icon": Icons.apps_rounded,
      "color": Color(0xFF1B4332),
      "bgColor": Color(0xFFEAF4ED),
      "badge": "Complete Catalog",
      "categoryFilter": "All",
    },
    {
      "id": "harvester",
      "name": "Combine Harvester",
      "urdu": "کمبائن ہارویسٹر",
      "desc": "Wheat, Rice & Corn harvesting",
      "urduDesc": "گندم، دھان اور مکئی کی کٹائی",
      "icon": Icons.agriculture_rounded,
      "color": Color(0xFFC05621), // Amber Harvest
      "bgColor": Color(0xFFFEEBC8),
      "badge": "Claas, New Holland",
      "categoryFilter": "Harvester",
    },
    {
      "id": "laser",
      "name": "Laser Land Leveler",
      "urdu": "لیزر لیولر",
      "desc": "Precision land leveling & water saving",
      "urduDesc": "ہموار زمین اور پانی کی بچت",
      "icon": Icons.architecture_rounded,
      "color": Color(0xFF2B6CB0), // Precision Blue
      "bgColor": Color(0xFFEBF8FF),
      "badge": "Transmitter Setup",
      "categoryFilter": "Laser Leveler",
    },
    {
      "id": "thresher",
      "name": "Thresher & Sheller",
      "urdu": "تھریشر و مکئی شیلر",
      "desc": "Grain separation & bagging",
      "urduDesc": "گندم تھریشر اور دانہ علیحدگی",
      "icon": Icons.settings_suggest_rounded,
      "color": Color(0xFF744210), // Bronze
      "bgColor": Color(0xFFFEFCBF),
      "badge": "Toka & Heavy Flywheel",
      "categoryFilter": "Thresher / Sheller",
    },
    {
      "id": "baler",
      "name": "Straw Baler",
      "urdu": "سٹرا بیلر (گٹھی بنانے والی)",
      "desc": "Square bales of wheat straw & forage",
      "urduDesc": "پُرالی اور بھوسے کی گٹھیں",
      "icon": Icons.inventory_2_rounded,
      "color": Color(0xFF276749), // Emerald
      "bgColor": Color(0xFFC6F6D5),
      "badge": "Straw Management",
      "categoryFilter": "Straw Baler",
    },
    {
      "id": "drone",
      "name": "Agri Spray Drone",
      "urdu": "زرعی سپرے ڈرون",
      "desc": "Ultra-fast spray & pesticide mapping",
      "urduDesc": "کیڑے مار دوا و کھاد سپرے",
      "icon": Icons.flight_takeoff_rounded,
      "color": Color(0xFF007791), // Tech Cyan
      "bgColor": Color(0xFFE6FFFA),
      "badge": "40L High Capacity",
      "categoryFilter": "Agri Drone",
    },
    {
      "id": "rotavator",
      "name": "Rotavator & Plow",
      "urdu": "روٹاویٹر و ہل",
      "desc": "Seedbed preparation & soil turning",
      "urduDesc": "زمین کی تیاری اور بوائی",
      "icon": Icons.landscape_rounded,
      "color": Color(0xFF4A5568),
      "bgColor": Color(0xFFEDF2F7),
      "badge": "Tractor Attachments",
      "categoryFilter": "Rotavator / Plow",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.primaryDark,
              size: 18,
            ),
            onPressed: () => Navigator.maybePop(context),
          ),
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: AppColors.accentLime,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "SabzDost",
                style: AppTheme.english(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header title banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Select Machinery Type",
                          style: AppTheme.english(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                            letterSpacing: -0.4,
                          ),
                        ),
                        Text(
                          "مشینری منتخب کریں",
                          style: AppTheme.urdu(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "Choose the equipment category you want to hire or book",
                      style: AppTheme.english(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Categories Grid / List
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 6.0),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final item = categories[index];
                    return _buildCategoryCard(context, item);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Map<String, dynamic> item) {
    final Color color = item["color"] as Color;
    final Color bgColor = item["bgColor"] as Color;
    final String categoryFilter = item["categoryFilter"] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MachineryDashboardScreen(
                  isUrdu: isUrdu,
                  initialCategory: categoryFilter,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                // Prominent Icon Container with vibrant background
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: color.withValues(alpha: 0.2)),
                  ),
                  child: Icon(
                    item["icon"] as IconData,
                    color: color,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),

                // Name, Urdu Subtitle & Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        runSpacing: 2,
                        children: [
                          Text(
                            item["name"] as String,
                            style: AppTheme.english(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            "(${item["urdu"]})",
                            style: AppTheme.urdu(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item["desc"] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.english(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item["badge"] as String,
                          style: AppTheme.english(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Clean forward arrow
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: AppColors.primaryMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
