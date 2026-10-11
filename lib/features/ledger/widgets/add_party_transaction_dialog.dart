import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../models/party_ledger.dart';

class AddPartyTransactionDialog extends StatefulWidget {
  final PartyLedger party;
  final bool isUrdu;
  final Function(PartyTransaction) onAdd;

  const AddPartyTransactionDialog({
    super.key,
    required this.party,
    required this.isUrdu,
    required this.onAdd,
  });

  @override
  State<AddPartyTransactionDialog> createState() => _AddPartyTransactionDialogState();
}

class _AddPartyTransactionDialogState extends State<AddPartyTransactionDialog> {
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  PartyTransactionType _type = PartyTransactionType.cropSold;
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  void _submit() {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) return;

    String defaultTitle = "";
    switch (_type) {
      case PartyTransactionType.cropSold:
        defaultTitle = widget.isUrdu ? "فصل فروخت کی" : "Crop Sold";
        break;
      case PartyTransactionType.itemPurchased:
        defaultTitle = widget.isUrdu ? "کھاد / ڈیزل / اسپرے خریداری" : "Purchased Supplies";
        break;
      case PartyTransactionType.cashReceived:
        defaultTitle = widget.isUrdu ? "نقد رقم وصولی" : "Cash Received";
        break;
      case PartyTransactionType.cashPaid:
        defaultTitle = widget.isUrdu ? "نقد رقم ادا کی" : "Cash Paid";
        break;
    }

    final title = _titleController.text.trim().isNotEmpty
        ? _titleController.text.trim()
        : defaultTitle;

    final tx = PartyTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      partyId: widget.party.id,
      title: title,
      titleUrdu: title,
      amount: amount,
      type: _type,
      date: _date,
      note: _noteController.text.trim(),
    );

    widget.onAdd(tx);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isUrdu = widget.isUrdu;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isUrdu ? "کھاتے میں نیا لین دین" : "New Khata Transaction",
                          style: isUrdu
                              ? AppTheme.urdu(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDark,
                                )
                              : AppTheme.english(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDark,
                                ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.party.name,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Transaction Type 4-Grid Selectors
              Text(
                isUrdu ? "لین دین کی نوعیت منتخب کریں:" : "Select Transaction Nature:",
                style: isUrdu
                    ? AppTheme.urdu(fontSize: 12, fontWeight: FontWeight.w700)
                    : const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),

              // 1. You sold crop
              _buildTypeCard(
                type: PartyTransactionType.cropSold,
                title: isUrdu ? "فصل دی / بیچی (آپ کے حق میں جمع +)" : "Sold Crop (Added to your credit +)",
                subtitle: isUrdu ? "مثلاً گندم، کپاس منڈی میں بیچی" : "e.g. Wheat or cotton harvest sold",
                icon: Icons.grass_rounded,
                activeColor: AppColors.successGreen,
              ),
              const SizedBox(height: 8),

              // 2. You bought Diesel/Khaad
              _buildTypeCard(
                type: PartyTransactionType.itemPurchased,
                title: isUrdu ? "سامان لیا (کھاد، ڈیزل، اسپرے -)" : "Bought Supplies (Deducted from balance -)",
                subtitle: isUrdu ? "مثلاً 50L ڈیزل، 3 بوری کھاد، اسپرے" : "e.g. Diesel, urea bags, sprays",
                icon: Icons.shopping_bag_rounded,
                activeColor: const Color(0xFFE65100),
              ),
              const SizedBox(height: 8),

              // 3. Cash Received
              _buildTypeCard(
                type: PartyTransactionType.cashReceived,
                title: isUrdu ? "نقد رقم لی / وصول کی (-)" : "Cash Received from Dealer (-)",
                subtitle: isUrdu ? "ڈیلر نے آپ کو نقد کیش دیا" : "Dealer handed you cash",
                icon: Icons.arrow_downward_rounded,
                activeColor: const Color(0xFF1565C0),
              ),
              const SizedBox(height: 8),

              // 4. Cash Paid
              _buildTypeCard(
                type: PartyTransactionType.cashPaid,
                title: isUrdu ? "نقد رقم ادا کی (+)" : "Cash Paid to Dealer (+)",
                subtitle: isUrdu ? "آپ نے ڈیلر کو ادھار کی مد میں نقد دیے" : "You paid cash towards dues",
                icon: Icons.arrow_upward_rounded,
                activeColor: AppColors.primaryDark,
              ),

              const SizedBox(height: 16),

              // Amount Field
              Text(
                isUrdu ? "رقم (روپے):" : "Amount (PKR):",
                style: isUrdu ? AppTheme.urdu(fontSize: 12, fontWeight: FontWeight.w700) : const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
                  decoration: const InputDecoration(
                    prefixIcon: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Text("Rs.", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    ),
                    prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                    border: InputBorder.none,
                    hintText: "0",
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Title / Item description
              Text(
                isUrdu ? "تفصیل / مد (مثلاً 50 لیٹر ڈیزل یا 40 من گندم):" : "Item / Description:",
                style: isUrdu ? AppTheme.urdu(fontSize: 11, fontWeight: FontWeight.w600) : const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: isUrdu ? "مثلاً 50L ڈیزل پمپ سے لائے" : "e.g. 50L diesel from pump",
                    hintStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),

              // Date Picker Pill Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isUrdu ? "تاریخ:" : "Date:",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded, size: 14, color: AppColors.primaryDark),
                          const SizedBox(width: 6),
                          Text(
                            "${_date.day}/${_date.month}/${_date.year}",
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Confirm Button
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: Text(
                  isUrdu ? "کھاتے میں محفوظ کریں" : "Save to Khata",
                  style: isUrdu ? AppTheme.urdu(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white) : const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeCard({
    required PartyTransactionType type,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color activeColor,
  }) {
    final isSelected = _type == type;
    return InkWell(
      onTap: () => setState(() => _type = type),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.09) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.borderLight,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? activeColor : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? activeColor : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, size: 18, color: activeColor),
          ],
        ),
      ),
    );
  }
}
