import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gemini_input_assistant_sheet.dart';
import '../models/ledger_entry.dart';

class AddLedgerEntrySheet extends StatefulWidget {
  final bool isUrdu;
  final Function(LedgerEntry) onAddEntry;

  const AddLedgerEntrySheet({
    super.key,
    required this.isUrdu,
    required this.onAddEntry,
  });

  @override
  State<AddLedgerEntrySheet> createState() => _AddLedgerEntrySheetState();
}

class _AddLedgerEntrySheetState extends State<AddLedgerEntrySheet> {
  final _totalAmountController = TextEditingController();
  final _paidAmountController = TextEditingController();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  final _partyController = TextEditingController();

  LedgerEntryType _entryType = LedgerEntryType.income; // Default to income/sales as requested
  late LedgerCategory _selectedCategory;
  String _selectedCrop = "گندم (Wheat)";
  DateTime _selectedDate = DateTime.now();

  // Payment Mode:
  // 0: Full Payment (مکمل نقد وصول / ادا)
  // 1: Partial Payment (کچھ نقد + بقایا ادھار)
  // 2: Full Credit (مکمل ادھار / زیرو نقد)
  int _paymentMode = 0;

  final List<String> _crops = [
    "گندم (Wheat)",
    "کپاس (Cotton)",
    "دھان / چاول (Rice)",
    "مکئی (Maize)",
    "گنا (Sugarcane)",
    "باغ و سبزیاں (Orchard/Veg)",
    "عمومی فارم (General Farm)",
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = LedgerCategory.cropSale;

    _totalAmountController.addListener(_onTotalAmountChanged);
  }

  void _onTotalAmountChanged() {
    if (_paymentMode == 0) {
      // If Full Payment, keep paid amount synchronized with total amount
      _paidAmountController.text = _totalAmountController.text;
    }
  }

  @override
  void dispose() {
    _totalAmountController.dispose();
    _paidAmountController.dispose();
    _titleController.dispose();
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
      paidAmount = totalAmount; // Full paid
    } else if (_paymentMode == 2) {
      paidAmount = 0.0; // Full credit / 0 paid
    } else {
      final paidText = _paidAmountController.text.trim();
      paidAmount = double.tryParse(paidText) ?? 0.0;
      if (paidAmount > totalAmount) {
        paidAmount = totalAmount;
      }
    }

    final title = _titleController.text.trim().isNotEmpty
        ? _titleController.text.trim()
        : (widget.isUrdu ? _selectedCategory.urduTitle : _selectedCategory.englishTitle);

    final newEntry = LedgerEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      titleUrdu: title,
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      type: _entryType,
      category: _selectedCategory,
      cropName: _selectedCrop,
      date: _selectedDate,
      note: _noteController.text.trim(),
      partyName: _partyController.text.trim(),
    );

    widget.onAddEntry(newEntry);
    Navigator.of(context).pop();
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
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Modal Header with Date Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isUrdu ? "نیا کھاتہ اندراج" : "New Ledger Entry",
                  style: isUrdu
                      ? AppTheme.urdu(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        )
                      : AppTheme.english(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                ),
                // Date Picker Button
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.primaryDark),
                        const SizedBox(width: 6),
                        Text(
                          _formatDateDisplay(_selectedDate),
                          style: const TextStyle(
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
            const SizedBox(height: 14),

            // Expense vs Income Pill Selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTypePill(
                      type: LedgerEntryType.income,
                      title: isUrdu ? "آمدن (فصل فروخت)" : "Income (Crop Sale)",
                      icon: Icons.arrow_downward_rounded,
                      activeColor: AppColors.successGreen,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildTypePill(
                      type: LedgerEntryType.expense,
                      title: isUrdu ? "خرچہ (خریداری / لاگت)" : "Expense (Costs)",
                      icon: Icons.arrow_upward_rounded,
                      activeColor: AppColors.alertSoftRed,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 1. TOTAL SALE OR BILL AMOUNT (کُل رقم)
            Text(
              _entryType == LedgerEntryType.income
                  ? (isUrdu ? "کُل فروخت کی رقم (Total Sale Amount):" : "Total Sale Amount (PKR):")
                  : (isUrdu ? "کُل بل کی رقم (Total Bill Amount):" : "Total Bill Amount (PKR):"),
              style: isUrdu
                  ? AppTheme.urdu(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    )
                  : AppTheme.english(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: TextField(
                controller: _totalAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDark,
                ),
                decoration: InputDecoration(
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Text(
                      "Rs.",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  border: InputBorder.none,
                  hintText: _entryType == LedgerEntryType.income ? "مثلاً 60000" : "مثلاً 14000",
                  hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 18),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 16),

            // 2. PAYMENT BREAKDOWN SELECTOR (نقد، کچھ بقایا، مکمل ادھار)
            Text(
              _entryType == LedgerEntryType.income
                  ? (isUrdu ? "وصولی کی صورتحال (Payment Status):" : "Payment Status:")
                  : (isUrdu ? "ادائیگی کی صورتحال (Payment Status):" : "Payment Status:"),
              style: isUrdu
                  ? AppTheme.urdu(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    )
                  : AppTheme.english(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildPaymentModeChip(
                  mode: 0,
                  label: isUrdu ? "مکمل نقد" : "Full Paid",
                  icon: Icons.check_circle_rounded,
                ),
                const SizedBox(width: 8),
                _buildPaymentModeChip(
                  mode: 1,
                  label: isUrdu ? "کچھ نقد + بقایا" : "Partial (Split)",
                  icon: Icons.pie_chart_outline_rounded,
                ),
                const SizedBox(width: 8),
                _buildPaymentModeChip(
                  mode: 2,
                  label: isUrdu ? "مکمل ادھار" : "Full Credit",
                  icon: Icons.hourglass_top_rounded,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // If Partial Payment mode is active: show the Received/Paid amount box
            if (_paymentMode == 1) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9C4).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _entryType == LedgerEntryType.income
                              ? (isUrdu ? "نقد وصول شدہ رقم (Received Cash):" : "Cash Received (PKR):")
                              : (isUrdu ? "نقد ادا شدہ رقم (Cash Paid):" : "Cash Paid (PKR):"),
                          style: isUrdu
                              ? AppTheme.urdu(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                )
                              : const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          "بقایا: Rs. ${remainingPreview.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFE65100),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: TextField(
                        controller: _paidAmountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                        decoration: const InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Text(
                              "Rs.",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                            ),
                          ),
                          prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                          border: InputBorder.none,
                          hintText: "مثلاً 30000",
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // If Full Credit mode is active: informative banner
            if (_paymentMode == 2) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.alertSoftRed.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.alertSoftRed.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.alertSoftRed),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isUrdu
                            ? "پوری رقم (Rs. ${totalEntered.toStringAsFixed(0)}) کھاتے میں بطور بقایا ادھار درج ہوگی۔"
                            : "Full amount will be recorded as pending credit.",
                        style: isUrdu
                            ? AppTheme.urdu(fontSize: 10, color: AppColors.alertSoftRed, fontWeight: FontWeight.w600)
                            : const TextStyle(fontSize: 11, color: AppColors.alertSoftRed),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // 3. Category Horizontal Chips
            Text(
              _entryType == LedgerEntryType.expense
                  ? (isUrdu ? "خرچ کی قسم منتخب کریں (خریداری):" : "Expense Category (Purchases):")
                  : (isUrdu ? "فروخت کی قسم منتخب کریں (آمدن):" : "Income Category (Harvest Sale):"),
              style: isUrdu
                  ? AppTheme.urdu(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    )
                  : AppTheme.english(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
            ),
            const SizedBox(height: 10),

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
                        size: 16,
                        color: isSelected ? Colors.white : cat.color,
                      ),
                      label: Text(
                        isUrdu ? cat.urduTitle : cat.englishTitle,
                        style: isUrdu
                            ? AppTheme.urdu(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : AppColors.textDark,
                              )
                            : TextStyle(
                                fontSize: 12,
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Crop Dropdown & Party Row
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isUrdu ? "متعلقہ فصل:" : "Crop:",
                        style: isUrdu
                            ? AppTheme.urdu(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              )
                            : AppTheme.english(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCrop,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, color: AppColors.textMuted),
                            items: _crops.map((c) {
                              return DropdownMenuItem(
                                value: c,
                                child: Text(
                                  c,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
                                  ? (isUrdu ? "خریدار / منڈی کا نام:" : "Buyer / Mandi Name:")
                                  : (isUrdu ? "دکاندار / ڈیلر کا نام:" : "Vendor / Store Name:"),
                              style: isUrdu
                                  ? AppTheme.urdu(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                    )
                                  : AppTheme.english(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark,
                                    ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              GeminiInputAssistantSheet.show(
                                context: context,
                                initialText: _partyController.text,
                                title: isUrdu ? "خریدار / ڈیلر نام AI اسسٹنٹ" : "Party Name AI",
                                hintText: isUrdu
                                    ? "یہاں نام لکھیں..."
                                    : "Write name here...",
                                domainContext: "Agriculture dealer, grain market, seed store",
                                onSelected: (corrected, _) {
                                  setState(() {
                                    _partyController.text = corrected;
                                  });
                                },
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Icon(Icons.auto_awesome_rounded, size: 15, color: AppColors.primaryDark),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: TextField(
                          controller: _partyController,
                          decoration: InputDecoration(
                            hintText: _entryType == LedgerEntryType.income
                                ? (isUrdu ? "غلہ منڈی یا خریدار..." : "Grain market or buyer...")
                                : (isUrdu ? "ایگری کھاد اسٹور..." : "Agri fertilizer store..."),
                            hintStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Note / Description with Gemini Assistant
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isUrdu ? "تفصیل یا اضافی نوٹ (اختیاری):" : "Details or Note (Optional):",
                  style: isUrdu
                      ? AppTheme.urdu(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        )
                      : AppTheme.english(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                ),
                InkWell(
                  onTap: () {
                    GeminiInputAssistantSheet.show(
                      context: context,
                      initialText: _noteController.text,
                      title: isUrdu ? "سبز دوست AI نوٹ اسسٹنٹ" : "SabzDost AI Note Assistant",
                      hintText: isUrdu
                          ? "یہاں نوٹ لکھیں..."
                          : "Write note here...",
                      domainContext:
                          "Farm ledger transaction note, fertilizers, seed, pesticide, wheat harvest, crop sale in Pakistan",
                      onSelected: (corrected, _) {
                        setState(() {
                          _noteController.text = corrected;
                        });
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryDark.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome_rounded, size: 13, color: AppColors.primaryDark),
                        const SizedBox(width: 4),
                        Text(
                          isUrdu ? "AI ٹھیک کریں" : "AI Fix",
                          style: isUrdu
                              ? AppTheme.urdu(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark,
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
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: TextField(
                controller: _noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: _entryType == LedgerEntryType.income
                      ? (isUrdu
                          ? "فصل فروخت تفصیل نوٹ..."
                          : "Sale details or note...")
                      : (isUrdu
                          ? "خرچہ یا ادھار تفصیل..."
                          : "Expense or credit note..."),
                  hintStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  contentPadding: const EdgeInsets.all(12),
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 22),

            // Submit Button
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _entryType == LedgerEntryType.income
                    ? AppColors.successGreen
                    : AppColors.primaryDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.accentLime, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _entryType == LedgerEntryType.income
                        ? (isUrdu ? "فروخت کھاتے میں محفوظ کریں" : "Save Sale Entry")
                        : (isUrdu ? "خرچہ کھاتے میں محفوظ کریں" : "Save Expense Entry"),
                    style: isUrdu
                        ? AppTheme.urdu(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          )
                        : AppTheme.english(
                            fontSize: 15,
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
  }) {
    final isSelected = _entryType == type;

    return InkWell(
      onTap: () => _onTypeChanged(type),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryDark : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primaryDark : AppColors.borderLight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? AppColors.accentLime : AppColors.textMuted,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
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

  String _formatDateDisplay(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return "آج (Today)";
    }
    return "${date.day}/${date.month}/${date.year}";
  }
}
