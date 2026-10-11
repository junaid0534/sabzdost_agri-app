import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../models/ledger_entry.dart';

class SettlePaymentDialog extends StatefulWidget {
  final LedgerEntry entry;
  final bool isUrdu;
  final Function(double collectedAmount, String note) onSettle;

  const SettlePaymentDialog({
    super.key,
    required this.entry,
    required this.isUrdu,
    required this.onSettle,
  });

  @override
  State<SettlePaymentDialog> createState() => _SettlePaymentDialogState();
}

class _SettlePaymentDialogState extends State<SettlePaymentDialog> {
  late final TextEditingController _amountController;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default to the full remaining balance
    _amountController = TextEditingController(
      text: widget.entry.remainingBalance.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _amountController.text.trim();
    final amount = double.tryParse(text);
    if (amount == null || amount <= 0) return;

    if (amount > widget.entry.remainingBalance + 0.1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isUrdu
                ? "رقم بقایا حساب (${widget.entry.remainingBalance.toStringAsFixed(0)}) سے زیادہ نہیں ہو سکتی"
                : "Amount cannot exceed remaining balance (${widget.entry.remainingBalance.toStringAsFixed(0)})",
          ),
          backgroundColor: AppColors.alertSoftRed,
        ),
      );
      return;
    }

    widget.onSettle(amount, _noteController.text.trim());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isUrdu = widget.isUrdu;
    final isIncome = widget.entry.isIncome;
    final remaining = widget.entry.remainingBalance;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isIncome
                        ? AppColors.successGreen.withValues(alpha: 0.12)
                        : AppColors.alertSoftRed.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isIncome ? Icons.price_check_rounded : Icons.payments_rounded,
                    color: isIncome ? AppColors.successGreen : AppColors.alertSoftRed,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isIncome
                          ? (isUrdu ? "بقایا رقم وصول کریں" : "Collect Remaining Balance")
                          : (isUrdu ? "بقایا رقم ادا کریں" : "Pay Remaining Balance"),
                        style: isUrdu
                            ? AppTheme.urdu(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              )
                            : AppTheme.english(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.entry.titleUrdu,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Financial Summary Pill
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isUrdu ? "کُل رقم:" : "Total Amount:",
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                      Text(
                        "Rs. ${widget.entry.totalAmount.toStringAsFixed(0)}",
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isIncome
                            ? (isUrdu ? "پہلے سے وصول شدہ:" : "Previously Received:")
                            : (isUrdu ? "پہلے سے ادا شدہ:" : "Previously Paid:"),
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                      Text(
                        "Rs. ${widget.entry.paidAmount.toStringAsFixed(0)}",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isIncome ? AppColors.successGreen : AppColors.alertSoftRed,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16, color: AppColors.borderLight),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isUrdu ? "کل بقایا رقم:" : "Pending Balance:",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isIncome ? const Color(0xFFE65100) : AppColors.alertSoftRed,
                        ),
                      ),
                      Text(
                        "Rs. ${remaining.toStringAsFixed(0)}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: isIncome ? const Color(0xFFE65100) : AppColors.alertSoftRed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Input: How much is being paid/received now
            Text(
              isIncome
                  ? (isUrdu ? "ابھی موصول ہونے والی رقم:" : "Receiving Amount Now:")
                  : (isUrdu ? "ابھی ادا کرنے والی رقم:" : "Paying Amount Now:"),
              style: isUrdu
                  ? AppTheme.urdu(fontSize: 12, fontWeight: FontWeight.w700)
                  : AppTheme.english(fontSize: 12, fontWeight: FontWeight.w700),
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
                autofocus: true,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                decoration: const InputDecoration(
                  prefixIcon: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Text(
                      "Rs.",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                    ),
                  ),
                  prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Optional note
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: isUrdu ? "کوئی تفصیل یا رسید نمبر (اختیاری)" : "Note / receipt info (optional)",
                hintStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: Text(isUrdu ? "منسوخ" : "Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isIncome ? AppColors.successGreen : AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      elevation: 0,
                    ),
                    child: Text(
                      isIncome
                          ? (isUrdu ? "وصولی محفوظ کریں" : "Confirm Received")
                          : (isUrdu ? "ادائیگی محفوظ کریں" : "Confirm Payment"),
                      style: isUrdu
                          ? AppTheme.urdu(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)
                          : const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
