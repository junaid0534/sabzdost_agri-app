import 'package:flutter/material.dart';
import '../../../core/localization/language_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gemini_input_assistant_sheet.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../models/machinery_model.dart';

class AddMachineScreen extends StatefulWidget {
  final bool? isUrdu;

  const AddMachineScreen({super.key, this.isUrdu});

  @override
  State<AddMachineScreen> createState() => _AddMachineScreenState();
}

class _AddMachineScreenState extends State<AddMachineScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _urduNameController = TextEditingController();
  final _rateController = TextEditingController();
  final _locationController = TextEditingController(text: "ملتان");
  final _ownerNameController = TextEditingController(text: "ملک اسلم");
  final _ownerPhoneController = TextEditingController(text: "0300-7382910");

  String _selectedCategory = "Tractor";
  String _selectedUnit = "Hour";
  bool _isAvailable = true;

  bool get _isUrdu => widget.isUrdu ?? LanguageController.instance.isUrdu;

  final List<Map<String, dynamic>> _machineCategories = [
    {
      "id": "Tractor",
      "name": "Tractor",
      "urdu": "زرعی ٹریکٹر",
      "subUrdu": "ہل چلانا، بجائی، ٹرالی",
      "subEn": "Plowing & Haulage",
      "icon": Icons.agriculture_rounded,
      "color": Color(0xFF257538),
      "image": "https://images.unsplash.com/photo-1592982537447-7440770cbfc9?q=80&w=600&auto=format&fit=crop",
    },
    {
      "id": "Harvester",
      "name": "Combine Harvester",
      "urdu": "کمبائن ہارویسٹر",
      "subUrdu": "گندم و دھان کٹائی",
      "subEn": "Harvesting Crops",
      "icon": Icons.engineering_rounded,
      "color": Color(0xFFC05621),
      "image": "https://images.unsplash.com/photo-1592982537447-7440770cbfc9?q=80&w=600&auto=format&fit=crop",
    },
    {
      "id": "Laser Leveler",
      "name": "Laser Leveler",
      "urdu": "لیزر لیولر",
      "subUrdu": "زمین ہموار کرنا",
      "subEn": "Land Leveling",
      "icon": Icons.architecture_rounded,
      "color": Color(0xFF2B6CB0),
      "image": "https://images.unsplash.com/photo-1595009552535-be753447727e?q=80&w=600&auto=format&fit=crop",
    },
    {
      "id": "Agri Drone",
      "name": "Spray Drone",
      "urdu": "سپرے ڈرون",
      "subUrdu": "فصل پر سپرے",
      "subEn": "Aerial Spray",
      "icon": Icons.flight_takeoff_rounded,
      "color": Color(0xFF00897B),
      "image": "https://images.unsplash.com/photo-1508614589041-895b88991e3e?q=80&w=600&auto=format&fit=crop",
    },
    {
      "id": "Straw Baler",
      "name": "Straw Baler",
      "urdu": "سٹرا بیلر",
      "subUrdu": "پُرالی کی گٹھیں",
      "subEn": "Straw Baling",
      "icon": Icons.inventory_2_rounded,
      "color": Color(0xFF8D6E63),
      "image": "https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=600&auto=format&fit=crop",
    },
    {
      "id": "Thresher / Sheller",
      "name": "Thresher",
      "urdu": "تھریشر و شیلر",
      "subUrdu": "دانہ علیحدگی",
      "subEn": "Grain Separation",
      "icon": Icons.settings_suggest_rounded,
      "color": Color(0xFF744210),
      "image": "https://images.unsplash.com/photo-1592982537447-7440770cbfc9?q=80&w=600&auto=format&fit=crop",
    },
    {
      "id": "Rotavator / Plow",
      "name": "Rotavator / Plow",
      "urdu": "روٹاویٹر و ہل",
      "subUrdu": "زمین کی تیاری",
      "subEn": "Tilling & Plowing",
      "icon": Icons.landscape_rounded,
      "color": Color(0xFF43A047),
      "image": "https://images.unsplash.com/photo-1595009552535-be753447727e?q=80&w=600&auto=format&fit=crop",
    },
  ];

  final List<Map<String, String>> _units = [
    {"id": "Hour", "name": "Per Hour", "urdu": "فی گھنٹہ"},
    {"id": "Acre", "name": "Per Acre", "urdu": "فی ایکڑ"},
    {"id": "Bale", "name": "Per Bale", "urdu": "فی گٹھی"},
    {"id": "Day", "name": "Per Day", "urdu": "فی دن"},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _urduNameController.dispose();
    _rateController.dispose();
    _locationController.dispose();
    _ownerNameController.dispose();
    _ownerPhoneController.dispose();
    super.dispose();
  }

  void _onCategorySelected(Map<String, dynamic> cat) {
    setState(() {
      _selectedCategory = cat["id"] as String;
      // Auto set recommended unit
      if (_selectedCategory == "Tractor" || _selectedCategory == "Laser Leveler" || _selectedCategory == "Thresher / Sheller") {
        _selectedUnit = "Hour";
      } else if (_selectedCategory == "Straw Baler") {
        _selectedUnit = "Bale";
      } else {
        _selectedUnit = "Acre";
      }
    });
  }

  void _saveMachine() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final urduName = _urduNameController.text.trim().isNotEmpty
        ? _urduNameController.text.trim()
        : name;
    final rate = double.tryParse(_rateController.text.trim()) ?? 0.0;
    if (rate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isUrdu ? "براہ کرم درست کرایہ درج کریں" : "Please enter valid rental rate"),
          backgroundColor: AppColors.alertSoftRed,
        ),
      );
      return;
    }

    final catData = _machineCategories.firstWhere(
      (c) => c["id"] == _selectedCategory,
      orElse: () => _machineCategories.first,
    );

    final newMachine = MachineryModel(
      id: "p_${DateTime.now().millisecondsSinceEpoch}",
      name: name,
      urduName: urduName,
      category: _selectedCategory,
      distanceKm: 0.0,
      rate: rate,
      rateUnit: _selectedUnit,
      ownerName: _ownerNameController.text.trim().isNotEmpty ? _ownerNameController.text.trim() : "ملک اسلم",
      ownerPhone: _ownerPhoneController.text.trim().isNotEmpty ? _ownerPhoneController.text.trim() : "0300-7382910",
      location: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : "ملتان",
      rating: 5.0,
      completedJobs: 0,
      isAvailable: _isAvailable,
      imageUrl: catData["image"] as String,
    );

    Navigator.pop(context, newMachine);
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final double headerHeight = isLandscape ? 40 : 48;

    return ResponsiveLayout(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          toolbarHeight: headerHeight,
          backgroundColor: AppColors.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryDark, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              color: AppColors.borderLight.withValues(alpha: 0.6),
              height: 1,
            ),
          ),
          title: Text(
            _isUrdu ? "نئی مشین فلیٹ میں شامل کریں" : "Add Machine to Fleet",
            style: _isUrdu
                ? AppTheme.urdu(
                    fontSize: isLandscape ? 13.5 : 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  )
                : AppTheme.english(
                    fontSize: isLandscape ? 14 : 15.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
          ),
        ),
        body: SafeArea(
          bottom: true,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isLandscape ? 24 : 14,
              vertical: 12,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Category Selection
                  _buildSectionHeader(
                    title: _isUrdu ? "1. مشین کی قسم منتخب کریں:" : "1. Select Machine Category:",
                    icon: Icons.category_rounded,
                  ),
                  const SizedBox(height: 5),
                  _buildCategorySelector(),
                  const SizedBox(height: 12),

                  // 2. Machine Model & Name
                  _buildSectionHeader(
                    title: _isUrdu ? "2. مشین کا ماڈل اور نام:" : "2. Machine Model & Name:",
                    icon: Icons.badge_rounded,
                  ),
                  const SizedBox(height: 5),
                  _buildModelNameCard(),
                  const SizedBox(height: 12),

                  // 3. Rental Pricing & Billing Unit
                  _buildSectionHeader(
                    title: _isUrdu ? "3. کرایہ اور پیمانہ (اکائی):" : "3. Rental Rate & Billing Unit:",
                    icon: Icons.payments_rounded,
                  ),
                  const SizedBox(height: 5),
                  _buildPricingCard(),
                  const SizedBox(height: 12),

                  // 4. Operator & Location Details
                  _buildSectionHeader(
                    title: _isUrdu ? "4. لوکیشن اور رابطہ:" : "4. Location & Contact Details:",
                    icon: Icons.location_on_rounded,
                  ),
                  const SizedBox(height: 5),
                  _buildOperatorCard(),
                  const SizedBox(height: 12),

                  // 5. Availability Switch
                  _buildAvailabilityCard(),
                  const SizedBox(height: 16),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _saveMachine,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_circle_rounded, color: AppColors.accentLime, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            _isUrdu ? "مشین فلیٹ میں شامل کریں" : "Add Machine to Fleet",
                            style: _isUrdu
                                ? AppTheme.urdu(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  )
                                : AppTheme.english(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required IconData icon}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryMedium),
        const SizedBox(width: 6),
        Text(
          title,
          style: _isUrdu
              ? AppTheme.urdu(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                )
              : AppTheme.english(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Container(
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryDark, size: 22),
          dropdownColor: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          menuMaxHeight: 350,
          itemHeight: 52,
          selectedItemBuilder: (context) {
            return _machineCategories.map((cat) {
              final Color color = cat["color"] as Color;
              return Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(cat["icon"] as IconData, size: 17, color: color),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: _isUrdu ? "${cat['urdu']} " : "${cat['name']} ",
                                style: _isUrdu
                                    ? AppTheme.urdu(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark)
                                    : AppTheme.english(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                              ),
                              TextSpan(
                                text: _isUrdu ? "(${cat['name']})" : "(${cat['urdu']})",
                                style: _isUrdu
                                    ? AppTheme.english(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted)
                                    : AppTheme.urdu(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _isUrdu ? (cat['subUrdu'] as String) : (cat['subEn'] as String),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _isUrdu
                              ? AppTheme.urdu(fontSize: 9.5, color: AppColors.textMuted)
                              : AppTheme.english(fontSize: 9.5, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList();
          },
          items: _machineCategories.map((cat) {
            final isSelected = _selectedCategory == cat["id"];
            final Color color = cat["color"] as Color;
            return DropdownMenuItem<String>(
              value: cat["id"] as String,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(cat["icon"] as IconData, size: 16, color: color),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: _isUrdu ? "${cat['urdu']} " : "${cat['name']} ",
                                  style: _isUrdu
                                      ? AppTheme.urdu(
                                          fontSize: 11,
                                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                          color: isSelected ? AppColors.primaryDark : AppColors.textDark,
                                        )
                                      : AppTheme.english(
                                          fontSize: 11.5,
                                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                          color: isSelected ? AppColors.primaryDark : AppColors.textDark,
                                        ),
                                ),
                                TextSpan(
                                  text: _isUrdu ? "(${cat['name']})" : "(${cat['urdu']})",
                                  style: _isUrdu
                                      ? AppTheme.english(
                                          fontSize: 10,
                                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                          color: isSelected ? AppColors.primaryDark : AppColors.textMuted,
                                        )
                                      : AppTheme.urdu(
                                          fontSize: 10.5,
                                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                          color: isSelected ? AppColors.primaryDark : AppColors.textDark,
                                        ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _isUrdu ? (cat['subUrdu'] as String) : (cat['subEn'] as String),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _isUrdu
                                ? AppTheme.urdu(
                                    fontSize: 9,
                                    color: isSelected ? AppColors.primaryMedium : AppColors.textMuted,
                                  )
                                : AppTheme.english(
                                    fontSize: 9,
                                    color: isSelected ? AppColors.primaryMedium : AppColors.textMuted,
                                  ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.primaryDark),
                  ],
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val == null) return;
            final cat = _machineCategories.firstWhere((c) => c["id"] == val);
            _onCategorySelected(cat);
          },
        ),
      ),
    );
  }

  Widget _buildModelNameCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isUrdu ? "مشین ماڈل / برانڈ (مثلاً MF 385 یا Claas)" : "Machine Model / Brand",
                style: _isUrdu
                    ? AppTheme.urdu(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)
                    : AppTheme.english(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted),
              ),
              InkWell(
                onTap: () {
                  GeminiInputAssistantSheet.show(
                    context: context,
                    initialText: _nameController.text,
                    title: _isUrdu ? "مشین نام AI اسسٹنٹ" : "Machine Name AI Assistant",
                    hintText: _isUrdu ? "ماڈل لکھیں (مثلاً mf 385)..." : "Write model (e.g. mf 385)...",
                    domainContext: "Farm machinery brands in Pakistan, Millat, Massey, New Holland, Claas, Greenland",
                    onSelected: (corrected, _) {
                      setState(() {
                        _nameController.text = corrected;
                      });
                    },
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primaryDark.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome_rounded, size: 12, color: AppColors.primaryDark),
                      const SizedBox(width: 4),
                      Text(
                        _isUrdu ? "AI ٹھیک کریں" : "AI Fix",
                        style: _isUrdu
                            ? AppTheme.urdu(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryDark,
                              )
                            : AppTheme.english(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryDark,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nameController,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? (_isUrdu ? "ماڈل نام درج کرنا ضروری ہے" : "Model name is required")
                : null,
            style: _isUrdu
                ? AppTheme.urdu(fontSize: 12.5, fontWeight: FontWeight.w700)
                : AppTheme.english(fontSize: 13, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: _isUrdu ? "مثلاً Millat MF 385 (85HP)" : "e.g. Millat MF 385 (85HP)",
              hintStyle: _isUrdu
                  ? AppTheme.urdu(fontSize: 11, color: AppColors.textLight)
                  : AppTheme.english(fontSize: 11, color: AppColors.textLight),
              filled: true,
              fillColor: AppColors.surfaceAlt,
              contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryMedium, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rate Field
          Text(
            _isUrdu ? "کرایہ رقم (روپے میں):" : "Rental Rate (PKR):",
            style: _isUrdu
                ? AppTheme.urdu(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)
                : AppTheme.english(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _rateController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? (_isUrdu ? "کرایہ درج کریں" : "Enter rental rate")
                : null,
            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textDark),
            decoration: InputDecoration(
              prefixIcon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Text(
                  "Rs.",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              hintText: "e.g. 2500",
              hintStyle: const TextStyle(fontSize: 12, color: AppColors.textLight),
              filled: true,
              fillColor: AppColors.surfaceAlt,
              contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryMedium, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Unit Selection - Fitted in 1 Single Responsive Row
          Text(
            _isUrdu ? "کرایہ کا پیمانہ (بلنگ اکائی):" : "Billing Unit:",
            style: _isUrdu
                ? AppTheme.urdu(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)
                : AppTheme.english(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted),
          ),
          const SizedBox(height: 6),
          Row(
            children: _units.map((u) {
              final isSelected = _selectedUnit == u["id"];
              final isLast = u == _units.last;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: isLast ? 0 : 5),
                  child: InkWell(
                    onTap: () => setState(() => _selectedUnit = u["id"]!),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryDark : AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryDark : AppColors.borderLight,
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _isUrdu ? u["urdu"]! : u["name"]!,
                          maxLines: 1,
                          style: _isUrdu
                              ? AppTheme.urdu(
                                  fontSize: 10,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected ? Colors.white : AppColors.textDark,
                                )
                              : AppTheme.english(
                                  fontSize: 10,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected ? Colors.white : AppColors.textDark,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOperatorCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // City / Location
          Text(
            _isUrdu ? "سروس لوکیشن یا تحصیل / شہر:" : "Service City / Area:",
            style: _isUrdu
                ? AppTheme.urdu(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)
                : AppTheme.english(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: _locationController,
            style: AppTheme.urdu(fontSize: 12.5, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.location_on_rounded, size: 16, color: AppColors.primaryMedium),
              hintText: _isUrdu ? "مثلاً شجاع آباد، ملتان" : "e.g. Multan",
              hintStyle: _isUrdu
                  ? AppTheme.urdu(fontSize: 11, color: AppColors.textLight)
                  : AppTheme.english(fontSize: 11, color: AppColors.textLight),
              filled: true,
              fillColor: AppColors.surfaceAlt,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.borderLight)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.borderLight)),
            ),
          ),
          const SizedBox(height: 10),

          // Owner Name & Phone Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isUrdu ? "مالک / ڈرائیور:" : "Operator / Owner:",
                      style: _isUrdu
                          ? AppTheme.urdu(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)
                          : AppTheme.english(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: _ownerNameController,
                      style: AppTheme.urdu(fontSize: 12.5, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        hintText: "ملک اسلم",
                        hintStyle: _isUrdu
                            ? AppTheme.urdu(fontSize: 11, color: AppColors.textLight)
                            : AppTheme.english(fontSize: 11, color: AppColors.textLight),
                        filled: true,
                        fillColor: AppColors.surfaceAlt,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.borderLight)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.borderLight)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isUrdu ? "فون نمبر:" : "Phone No:",
                      style: _isUrdu
                          ? AppTheme.urdu(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)
                          : AppTheme.english(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: _ownerPhoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: "0300-1234567",
                        filled: true,
                        fillColor: AppColors.surfaceAlt,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.borderLight)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.borderLight)),
                      ),
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

  Widget _buildAvailabilityCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                _isAvailable ? Icons.check_circle_rounded : Icons.pause_circle_rounded,
                color: _isAvailable ? AppColors.successGreen : AppColors.textMuted,
                size: 20,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isUrdu ? "فوری بکنگ کیلئے دستیاب" : "Available for Instant Booking",
                    style: _isUrdu
                        ? AppTheme.urdu(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textDark)
                        : AppTheme.english(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                  ),
                  Text(
                    _isUrdu ? "کاشتکاروں کو ایپ پر ایکٹو نظر آئے گی" : "Visible to farmers on booking list",
                    style: _isUrdu
                        ? AppTheme.urdu(fontSize: 9.5, color: AppColors.textMuted)
                        : AppTheme.english(fontSize: 10, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: _isAvailable,
            activeThumbColor: AppColors.primaryDark,
            onChanged: (val) => setState(() => _isAvailable = val),
          ),
        ],
      ),
    );
  }
}
