import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gemini_input_assistant_sheet.dart';
import '../models/ledger_entry.dart';

class CropOption {
  final String key;
  final String urduName;
  final String englishName;
  final IconData icon;

  const CropOption({
    required this.key,
    required this.urduName,
    required this.englishName,
    required this.icon,
  });
}

const List<CropOption> kLedgerCropOptions = [
  CropOption(
    key: "Wheat",
    urduName: "گندم",
    englishName: "Wheat",
    icon: Icons.grass_rounded,
  ),
  CropOption(
    key: "Cotton",
    urduName: "کپاس",
    englishName: "Cotton",
    icon: Icons.cloud_rounded,
  ),
  CropOption(
    key: "Rice",
    urduName: "دھان / چاول",
    englishName: "Rice",
    icon: Icons.water_drop_rounded,
  ),
  CropOption(
    key: "Maize",
    urduName: "مکئی",
    englishName: "Maize",
    icon: Icons.eco_rounded,
  ),
  CropOption(
    key: "Sugarcane",
    urduName: "کماد / گنا",
    englishName: "Sugarcane",
    icon: Icons.forest_rounded,
  ),
  CropOption(
    key: "Vegetables",
    urduName: "باغ و سبزیاں",
    englishName: "Vegetables",
    icon: Icons.local_florist_rounded,
  ),
  CropOption(
    key: "General",
    urduName: "عام فارم",
    englishName: "General Farm",
    icon: Icons.agriculture_rounded,
  ),
];

class AddLedgerEntrySheet extends StatefulWidget {
  final bool isUrdu;
  final Function(LedgerEntry) onAddEntry;
  final String? initialCrop;

  const AddLedgerEntrySheet({
    super.key,
    required this.isUrdu,
    required this.onAddEntry,
    this.initialCrop,
  });

  @override
  State<AddLedgerEntrySheet> createState() => _AddLedgerEntrySheetState();
}

class _AddLedgerEntrySheetState extends State<AddLedgerEntrySheet> {
  final _totalAmountController = TextEditingController();
  final _paidAmountController = TextEditingController();
  final _noteController = TextEditingController();
  final _partyController = TextEditingController();

  LedgerEntryType _entryType = LedgerEntryType.income;
  late LedgerCategory _selectedCategory;
  late CropOption _selectedCrop;
  DateTime _selectedDate = DateTime.now();

  // Payment Mode:
  // 0: Full Payment (مکمل نقد)
  // 1: Partial Payment (کچھ نقد)
  // 2: Full Credit (ادھار)
  int _paymentMode = 0;

  @override
  void initState() {
    super.initState();
    _selectedCategory = LedgerCategory.cropSale;

    if (widget.initialCrop != null && widget.initialCrop!.isNotEmpty) {
      final initial = widget.initialCrop!.toLowerCase();
      _selectedCrop = kLedgerCropOptions.firstWhere(
        (c) =>
            c.key.toLowerCase() == initial ||
            c.englishName.toLowerCase() == initial ||
            initial.contains(c.key.toLowerCase()) ||
            c.urduName.contains(widget.initialCrop!),
        orElse: () => kLedgerCropOptions.first,
      );
    } else {
      _selectedCrop = kLedgerCropOptions.first;
    }

    _totalAmountController.addListener(_onTotalAmountChanged);
  }

  void _onTotalAmountChanged() {
    if (_paymentMode == 0) {
      _paidAmountController.text = _totalAmountController.text;
    }
  }

  @override
  void dispose() {
    _totalAmountController.dispose();
    _paidAmountController.dispose();
    _noteController.dispose();
    _partyController.dispose();
    super.dispose();
  }

  void _onTypeChanged(LedgerEntryType newType) {
    if (_entryType == newType) return;
    setState(() {
      _entryType = newType;
      if (newType == LedgerEntryType.expense) {
        _selectedCategory = LedgerCategory.fertilizer;
      } else {
        _selectedCategory = LedgerCategory.cropSale;
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryDark,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submit() {
    final totalText = _totalAmountController.text.trim();
    if (totalText.isEmpty) return;
    final totalAmount = double.tryParse(totalText);
    if (totalAmount == null || totalAmount <= 0) return;

    double paidAmount = 0.0;
    if (_paymentMode == 0) {
      paidAmount = totalAmount;
    } else if (_paymentMode == 2) {
      paidAmount = 0.0;
    } else {
      final paidText = _paidAmountController.text.trim();
      paidAmount = double.tryParse(paidText) ?? 0.0;
      if (paidAmount > totalAmount) {
        paidAmount = totalAmount;
      }
    }

    final noteText = _noteController.text.trim();
    final defaultUrduTitle = _selectedCategory.urduTitle;
    final defaultEngTitle = _selectedCategory.englishTitle;

    final title = noteText.isNotEmpty
        ? noteText
        : (widget.isUrdu ? defaultUrduTitle : defaultEngTitle);
    final titleUrdu = noteText.isNotEmpty ? noteText : defaultUrduTitle;

    final newEntry = LedgerEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      titleUrdu: titleUrdu,
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      type: _entryType,
      category: _selectedCategory,
      cropName: _selectedCrop.key,
      date: _selectedDate,
      note: noteText,
      partyName: _partyController.text.trim(),
    );

    widget.onAddEntry(newEntry);
    Navigator.of(context).pop();
  }

  String _formatDateDisplay(DateTime date, bool isUrdu) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return isUrdu ? "آج" : "Today";
    }
    const urduMonths = [
      "", "جنوری", "فروری", "مارچ", "اپریل", "مئی", "جون",
      "جولائی", "اگست", "ستمبر", "اکتوبر", "نومبر", "دسمبر"
    ];
    const englishMonths = [
      "", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    final m = isUrdu ? urduMonths[date.month] : englishMonths[date.month];
    return "${date.day} $m";
  }

  @override
  Widget build(BuildContext context) {
    final bool isUrdu = widget.isUrdu;
    final activeCategories = _entryType == LedgerEntryType.expense
        ? LedgerCategoryExt.expenseCategories
        : LedgerCategoryExt.incomeCategories;

    final double totalEntered = double.tryParse(_totalAmountController.text) ?? 0.0;
    final double paidEntered = _paymentMode == 0
        ? totalEntered
        : (_paymentMode == 2 ? 0.0 : (double.tryParse(_paidAmountController.text) ?? 0.0));
    final double remainingPreview = (totalEntered - paidEntered) > 0 ? (totalEntered - paidEntered) : 0.0;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 14,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Sheet Grab Handle
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 2. Header Row: Title & Date Selector Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isUrdu ? "نیا اندراج" : "New Entry",
                  style: isUrdu
                      ? AppTheme.urdu(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                          height: 1.8,
                        )
                      : AppTheme.english(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                ),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          size: 15,
                          color: AppColors.primaryDark,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _formatDateDisplay(_selectedDate, isUrdu),
                          style: isUrdu
                              ? AppTheme.urdu(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark,
                                  height: 1.6,
                                )
                              : AppTheme.english(
                                  fontSize: 11.5,
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
            const SizedBox(height: 14),

            // 3. Segmented Type Switch: Income vs Expense
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTypePill(
                      type: LedgerEntryType.income,
                      title: isUrdu ? "آمدن" : "Income",
                      icon: Icons.arrow_downward_rounded,
                      activeColor: AppColors.successGreen,
                      isUrdu: isUrdu,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildTypePill(
                      type: LedgerEntryType.expense,
                      title: isUrdu ? "خرچہ" : "Expense",
                      icon: Icons.arrow_upward_rounded,
                      activeColor: AppColors.alertSoftRed,
                      isUrdu: isUrdu,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. Amount Hero Input
            Text(
              isUrdu ? "رقم" : "Amount",
              style: isUrdu
                  ? AppTheme.urdu(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      height: 1.8,
                    )
                  : AppTheme.english(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: TextField(
                controller: _totalAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: _entryType == LedgerEntryType.income
                      ? AppColors.successGreen
                      : AppColors.primaryDark,
                ),
                decoration: const InputDecoration(
                  prefixIcon: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Text(
                      "Rs.",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                  border: InputBorder.none,
                  hintText: "0",
                  hintStyle: TextStyle(color: AppColors.textLight, fontSize: 22),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 14),

            // 5. Payment Mode Segmented Pills (Full / Partial / Credit)
            Text(
              isUrdu ? "ادائیگی" : "Payment",
              style: isUrdu
                  ? AppTheme.urdu(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      height: 1.8,
                    )
                  : AppTheme.english(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _buildPaymentModeChip(
                  mode: 0,
                  label: isUrdu ? "مکمل نقد" : "Full Cash",
                  icon: Icons.check_circle_outline_rounded,
                  isUrdu: isUrdu,
                ),
                const SizedBox(width: 8),
                _buildPaymentModeChip(
                  mode: 1,
                  label: isUrdu ? "کچھ نقد" : "Partial",
                  icon: Icons.pie_chart_outline_rounded,
                  isUrdu: isUrdu,
                ),
                const SizedBox(width: 8),
                _buildPaymentModeChip(
                  mode: 2,
                  label: isUrdu ? "ادھار" : "Credit",
                  icon: Icons.schedule_rounded,
                  isUrdu: isUrdu,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 6. Conditional: Partial Payment Card
            if (_paymentMode == 1) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isUrdu
                              ? (_entryType == LedgerEntryType.income ? "نقد وصول" : "نقد ادا")
                              : (_entryType == LedgerEntryType.income ? "Cash Received" : "Cash Paid"),
                          style: isUrdu
                              ? AppTheme.urdu(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF92400E),
                                  height: 1.6,
                                )
                              : AppTheme.english(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF92400E),
                                ),
                        ),
                        Text(
                          isUrdu
                              ? "بقایا: Rs. ${remainingPreview.toStringAsFixed(0)}"
                              : "Due: Rs. ${remainingPreview.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: TextField(
                        controller: _paidAmountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                        decoration: InputDecoration(
                          prefixIcon: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            child: Text(
                              "Rs.",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                          border: InputBorder.none,
                          hintText: "0",
                          hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 16),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // 7. Conditional: Full Credit Notice
            if (_paymentMode == 2) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.alertSoftRed.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.alertSoftRed.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.alertSoftRed),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isUrdu
                            ? "یہ رقم کھاتے میں بطور بقایا ادھار درج ہوگی"
                            : "Full amount will be recorded as pending credit",
                        style: isUrdu
                            ? AppTheme.urdu(
                                fontSize: 11,
                                color: AppColors.alertSoftRed,
                                fontWeight: FontWeight.w700,
                                height: 1.6,
                              )
                            : AppTheme.english(
                                fontSize: 11,
                                color: AppColors.alertSoftRed,
                                fontWeight: FontWeight.w600,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // 8. Category Chips Row
            Text(
              isUrdu ? "کیٹیگری" : "Category",
              style: isUrdu
                  ? AppTheme.urdu(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      height: 1.8,
                    )
                  : AppTheme.english(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: activeCategories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      selected: isSelected,
                      onSelected: (val) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                      avatar: Icon(
                        cat.icon,
                        size: 15,
                        color: isSelected ? Colors.white : cat.color,
                      ),
                      label: Text(
                        isUrdu ? cat.urduTitle : cat.englishTitle,
                        style: isUrdu
                            ? AppTheme.urdu(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : AppColors.textDark,
                                height: 1.6,
                              )
                            : AppTheme.english(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : AppColors.textDark,
                              ),
                      ),
                      selectedColor: _entryType == LedgerEntryType.expense
                          ? AppColors.alertSoftRed
                          : AppColors.primaryDark,
                      backgroundColor: AppColors.surfaceVariant,
                      side: BorderSide(
                        color: isSelected
                            ? (_entryType == LedgerEntryType.expense
                                ? AppColors.alertSoftRed
                                : AppColors.primaryDark)
                            : AppColors.borderLight,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // 9. Crop Dropdown & Party Name Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Crop Dropdown
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isUrdu ? "فصل" : "Crop",
                        style: isUrdu
                            ? AppTheme.urdu(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                                height: 1.8,
                              )
                            : AppTheme.english(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<CropOption>(
                            value: _selectedCrop,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
                            items: kLedgerCropOptions.map((crop) {
                              return DropdownMenuItem<CropOption>(
                                value: crop,
                                child: Row(
                                  children: [
                                    Icon(crop.icon, size: 15, color: AppColors.primaryDark),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        isUrdu ? crop.urduName : crop.englishName,
                                        overflow: TextOverflow.ellipsis,
                                        style: isUrdu
                                            ? AppTheme.urdu(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textDark,
                                                height: 1.6,
                                              )
                                            : AppTheme.english(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textDark,
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedCrop = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Party / Mandi / Store Name
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _entryType == LedgerEntryType.income
                                  ? (isUrdu ? "خریدار / منڈی" : "Buyer / Mandi")
                                  : (isUrdu ? "دکاندار / ڈیلر" : "Vendor / Store"),
                              overflow: TextOverflow.ellipsis,
                              style: isUrdu
                                  ? AppTheme.urdu(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                      height: 1.8,
                                    )
                                  : AppTheme.english(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                    ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              GeminiInputAssistantSheet.show(
                                context: context,
                                initialText: _partyController.text,
                                title: isUrdu ? "خریدار / ڈیلر AI اسسٹنٹ" : "Party Name AI",
                                hintText: isUrdu ? "یہاں نام لکھیں..." : "Write name here...",
                                domainContext: "Agriculture dealer, grain market, seed store",
                                onSelected: (corrected, _) {
                                  setState(() {
                                    _partyController.text = corrected;
                                  });
                                },
                              );
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                              child: Icon(
                                Icons.auto_awesome_rounded,
                                size: 14,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: TextField(
                          controller: _partyController,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: isUrdu ? "نام لکھیں..." : "Name...",
                            hintStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 10. Note / Details (Optional) with AI Assist
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isUrdu ? "تفصیل یا نوٹ (اختیاری)" : "Note / Details (Optional)",
                  style: isUrdu
                      ? AppTheme.urdu(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                          height: 1.8,
                        )
                      : AppTheme.english(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                ),
                InkWell(
                  onTap: () {
                    GeminiInputAssistantSheet.show(
                      context: context,
                      initialText: _noteController.text,
                      title: isUrdu ? "AI نوٹ اسسٹنٹ" : "AI Note Assistant",
                      hintText: isUrdu ? "یہاں نوٹ لکھیں..." : "Write note here...",
                      domainContext:
                          "Farm ledger transaction note, fertilizer, seed, pesticide, wheat harvest, crop sale in Pakistan",
                      onSelected: (corrected, _) {
                        setState(() {
                          _noteController.text = corrected;
                        });
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome_rounded, size: 12, color: AppColors.primaryDark),
                        const SizedBox(width: 4),
                        Text(
                          isUrdu ? "AI مدد" : "AI Assist",
                          style: isUrdu
                              ? AppTheme.urdu(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark,
                                  height: 1.5,
                                )
                              : AppTheme.english(
                                  fontSize: 10,
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
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: TextField(
                controller: _noteController,
                maxLines: 2,
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: isUrdu
                      ? "اضافی تفصیل اگر ہو تو..."
                      : "Optional transaction details...",
                  hintStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  contentPadding: const EdgeInsets.all(10),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // 11. Primary Submit CTA Button
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _entryType == LedgerEntryType.income
                    ? AppColors.successGreen
                    : AppColors.primaryDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.accentLime, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    _entryType == LedgerEntryType.income
                        ? (isUrdu ? "آمدن محفوظ کریں" : "Save Income Entry")
                        : (isUrdu ? "خرچہ محفوظ کریں" : "Save Expense Entry"),
                    style: isUrdu
                        ? AppTheme.urdu(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.7,
                          )
                        : AppTheme.english(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypePill({
    required LedgerEntryType type,
    required String title,
    required IconData icon,
    required Color activeColor,
    required bool isUrdu,
  }) {
    final isSelected = _entryType == type;

    return InkWell(
      onTap: () => _onTypeChanged(type),
      borderRadius: BorderRadius.circular(11),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: isUrdu
                  ? AppTheme.urdu(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : AppColors.textDark,
                      height: 1.6,
                    )
                  : AppTheme.english(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.textDark,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentModeChip({
    required int mode,
    required String label,
    required IconData icon,
    required bool isUrdu,
  }) {
    final isSelected = _paymentMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _paymentMode = mode;
            if (mode == 0) {
              _paidAmountController.text = _totalAmountController.text;
            } else if (mode == 2) {
              _paidAmountController.text = "0";
            }
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryDark : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primaryDark : AppColors.borderLight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 13,
                color: isSelected ? AppColors.accentLime : AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: isUrdu
                    ? AppTheme.urdu(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColors.textDark,
                        height: 1.6,
                      )
                    : AppTheme.english(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColors.textDark,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
