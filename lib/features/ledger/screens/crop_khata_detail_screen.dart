import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../models/ledger_entry.dart';
import '../widgets/add_ledger_entry_sheet.dart';
import '../widgets/settle_payment_dialog.dart';

class CropKhataDetailScreen extends StatefulWidget {
  final String cropName;
  final String cropUrduName;
  final IconData icon;
  final Color themeColor;
  final List<LedgerEntry> entries;
  final bool isUrdu;
  final Function(LedgerEntry) onAddEntry;
  final Function(LedgerEntry, double, String) onSettle;

  const CropKhataDetailScreen({
    super.key,
    required this.cropName,
    required this.cropUrduName,
    required this.icon,
    required this.themeColor,
    required this.entries,
    required this.isUrdu,
    required this.onAddEntry,
    required this.onSettle,
  });

  @override
  State<CropKhataDetailScreen> createState() => _CropKhataDetailScreenState();
}

class _CropKhataDetailScreenState extends State<CropKhataDetailScreen> {
  int _filterTab = 0; // 0: تمام, 1: اخراجات, 2: آمدن

  double get _totalIncome => widget.entries
      .where((e) => e.type == LedgerEntryType.income)
      .fold(0.0, (sum, e) => sum + e.paidAmount);

  double get _totalExpense => widget.entries
      .where((e) => e.type == LedgerEntryType.expense)
      .fold(0.0, (sum, e) => sum + e.paidAmount);

  double get _netProfit => _totalIncome - _totalExpense;

  double get _pendingReceivable => widget.entries
      .where((e) => e.type == LedgerEntryType.income)
      .fold(0.0, (sum, e) => sum + e.remainingBalance);

  List<LedgerEntry> get _filteredList {
    return widget.entries.where((e) {
      if (_filterTab == 1 && e.type != LedgerEntryType.expense) return false;
      if (_filterTab == 2 && e.type != LedgerEntryType.income) return false;
      return true;
    }).toList();
  }

  void _openAddEntry() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddLedgerEntrySheet(
        isUrdu: widget.isUrdu,
        onAddEntry: widget.onAddEntry,
      ),
    );
  }

  void _openSettle(LedgerEntry item) {
    showDialog(
      context: context,
      builder: (ctx) => SettlePaymentDialog(
        entry: item,
        isUrdu: widget.isUrdu,
        onSettle: (amt, note) {
          widget.onSettle(item, amt, note);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUrdu = widget.isUrdu;

    return ResponsiveLayout(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          titleSpacing: 0,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: widget.themeColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: widget.themeColor, size: 16),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUrdu ? "${widget.cropUrduName} کھاتہ" : "${widget.cropName} Ledger",
                    style: isUrdu
                        ? AppTheme.urdu(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark)
                        : AppTheme.english(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark),
                  ),
                  Text(
                    isUrdu ? "نفع و لاگت رپورٹ" : "Profit & Analytics",
                    style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 74.0),
          child: SizedBox(
            height: 40,
            child: FloatingActionButton.extended(
              onPressed: _openAddEntry,
              backgroundColor: widget.themeColor,
              elevation: 2,
              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 16),
              label: Text(
                isUrdu ? "فصل اندراج (+)" : "Add Crop Entry (+)",
                style: isUrdu
                    ? AppTheme.urdu(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white)
                    : AppTheme.english(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 80),
          physics: const BouncingScrollPhysics(),
          children: [
            // Crop Financial Compact Banner
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.themeColor,
                    widget.themeColor.withValues(alpha: 0.88),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: widget.themeColor.withValues(alpha: 0.22),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isUrdu ? "خالص منافع / بچت" : "Net Profit",
                        style: isUrdu
                            ? AppTheme.urdu(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w600)
                            : const TextStyle(fontSize: 10, color: Colors.white70),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _netProfit >= 0
                              ? (isUrdu ? "منافع میں" : "Profitable")
                              : (isUrdu ? "زیرِ لاگت" : "Deficit"),
                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${_netProfit >= 0 ? '+' : '-'} Rs. ${_formatAmount(_netProfit.abs())}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isUrdu ? "کل فروخت (آمدن)" : "Total Income",
                              style: const TextStyle(fontSize: 9.5, color: Colors.white70),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              "Rs. ${_formatAmount(_totalIncome)}",
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 22, color: Colors.white24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isUrdu ? "کل خرچہ (لاگت)" : "Total Expense",
                              style: const TextStyle(fontSize: 9.5, color: Colors.white70),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              "Rs. ${_formatAmount(_totalExpense)}",
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (_pendingReceivable > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFE082)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Color(0xFFE65100), size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        isUrdu
                            ? "منڈی سے بقایا لینا ہے: Rs. ${_formatAmount(_pendingReceivable)}"
                            : "Pending dues to receive: Rs. ${_formatAmount(_pendingReceivable)}",
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFE65100)),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 10),

            // Sub tabs
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(2.5),
              child: Row(
                children: [
                  _buildSubTab(0, isUrdu ? "تمام اندراج" : "All"),
                  _buildSubTab(1, isUrdu ? "اخراجات" : "Expenses"),
                  _buildSubTab(2, isUrdu ? "آمدن" : "Income"),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Entries List
            if (_filteredList.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(Icons.notes_rounded, size: 28, color: AppColors.textLight),
                    const SizedBox(height: 6),
                    Text(
                      isUrdu ? "کوئی اندراج موجود نہیں ہے" : "No entries",
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )
            else
              ..._filteredList.map((item) => _buildItemTile(item, isUrdu)),
          ],
        ),
      ),
    );
  }

  Widget _buildSubTab(int index, String label) {
    final isSelected = _filterTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _filterTab = index),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? widget.themeColor : AppColors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemTile(LedgerEntry item, bool isUrdu) {
    final isExpense = item.type == LedgerEntryType.expense;
    final hasPending = item.hasRemainingBalance;

    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasPending ? const Color(0xFFFFCC80) : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: item.category.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.category.icon, size: 15, color: item.category.color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isUrdu ? item.titleUrdu : (item.title.isNotEmpty ? item.title : item.titleUrdu),
                      style: isUrdu
                          ? AppTheme.urdu(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textDark)
                          : const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textDark),
                    ),
                    Text(
                      "${item.partyName.isNotEmpty ? item.partyName : (isUrdu ? item.category.urduTitle : item.category.englishTitle)} • ${_formatDate(item.date, isUrdu)}",
                      style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${isExpense ? '-' : '+'} Rs. ${_formatAmount(item.paidAmount)}",
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      color: isExpense ? AppColors.alertSoftRed : AppColors.successGreen,
                    ),
                  ),
                  if (hasPending)
                    Text(
                      isUrdu ? "بقایا: ${_formatAmount(item.remainingBalance)}" : "Due: ${_formatAmount(item.remainingBalance)}",
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFFE65100)),
                    ),
                ],
              ),
            ],
          ),
          if (hasPending) ...[
            const SizedBox(height: 6),
            InkWell(
              onTap: () => _openSettle(item),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.successGreen.withValues(alpha: 0.4)),
                ),
                alignment: Alignment.center,
                child: Text(
                  isUrdu ? "بقایا رقم وصول کریں" : "Collect Remaining",
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.successGreen),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return "${(amount / 100000).toStringAsFixed(1)}L";
    }
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  String _formatDate(DateTime date, bool isUrdu) {
    final now = DateTime.now();
    if (now.difference(date).inHours < 24 && date.day == now.day) {
      return isUrdu ? "آج" : "Today";
    } else if (now.difference(date).inHours < 48 && (now.day - date.day == 1)) {
      return isUrdu ? "کل" : "Yesterday";
    }
    return "${date.day}/${date.month}";
  }
}
