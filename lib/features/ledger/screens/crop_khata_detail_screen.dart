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
  int _filterTab = 0; // 0: All, 1: Expenses, 2: Income

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
        initialCrop: widget.cropName,
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
        appBar: _buildAppBar(isUrdu),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: FloatingActionButton.extended(
            onPressed: _openAddEntry,
            backgroundColor: widget.themeColor,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
            label: Text(
              isUrdu ? "اندراج (+)" : "Add (+)",
              style: isUrdu
                  ? AppTheme.urdu(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    )
                  : AppTheme.english(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 85),
          physics: const BouncingScrollPhysics(),
          children: [
            // 1. Sleek Financial Overview Card
            _buildFinancialOverviewCard(isUrdu),
            const SizedBox(height: 12),

            // 2. Pending dues (if any)
            if (_pendingReceivable > 0) ...[
              _buildPendingNotice(isUrdu),
              const SizedBox(height: 12),
            ],

            // 3. Compact Segmented Filter Tabs (تمام، خرچہ، آمدن)
            _buildSegmentedFilterTabs(isUrdu),
            const SizedBox(height: 12),

            // 4. Entries List or Clean Empty State
            if (_filteredList.isEmpty)
              _buildEmptyState(isUrdu)
            else
              ..._filteredList.map((item) => _buildEntryTile(item, isUrdu)),
          ],
        ),
      ),
    );
  }

  // --- APP BAR ---
  PreferredSizeWidget _buildAppBar(bool isUrdu) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, size: 22, color: AppColors.textDark),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: widget.themeColor.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(widget.icon, color: widget.themeColor, size: 17),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isUrdu ? "${widget.cropUrduName} کھاتہ" : "${widget.cropName} Ledger",
            style: isUrdu
                ? AppTheme.urdu(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    height: 1.8,
                  )
                : AppTheme.english(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.file_download_outlined, size: 20, color: AppColors.primaryDark),
          tooltip: isUrdu ? "محفوظ کریں" : "Export",
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isUrdu ? "کھاتہ محفوظ کر لیا گیا" : "Ledger exported",
                  style: isUrdu ? AppTheme.urdu(fontSize: 11, color: Colors.white) : null,
                ),
                backgroundColor: AppColors.primaryDark,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: AppColors.borderLight.withValues(alpha: 0.7),
          height: 1,
        ),
      ),
    );
  }

  // --- FINANCIAL OVERVIEW CARD ---
  Widget _buildFinancialOverviewCard(bool isUrdu) {
    final bool isProfitable = _netProfit >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Net Profit Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUrdu ? "خالص منافع / بچت" : "Net Balance / Profit",
                    style: isUrdu
                        ? AppTheme.urdu(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                            height: 1.7,
                          )
                        : AppTheme.english(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                  ),
                  SizedBox(height: isUrdu ? 4 : 2),
                  Text(
                    "${isProfitable ? '+' : '-'} Rs. ${_formatAmount(_netProfit.abs())}",
                    style: AppTheme.english(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isProfitable ? AppColors.successGreen : AppColors.alertSoftRed,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              // Compact Status Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isProfitable
                      ? AppColors.successGreen.withValues(alpha: 0.1)
                      : AppColors.alertSoftRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isProfitable
                      ? (isUrdu ? "+منافع" : "+Profit")
                      : (isUrdu ? "-خرچہ" : "-Deficit"),
                  style: isUrdu
                      ? AppTheme.urdu(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: isProfitable ? AppColors.successGreen : AppColors.alertSoftRed,
                        )
                      : AppTheme.english(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isProfitable ? AppColors.successGreen : AppColors.alertSoftRed,
                        ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 12),

          // Two Simple Stats: Income & Expense
          Row(
            children: [
              // Income
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.successGreen.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_downward_rounded,
                        color: AppColors.successGreen,
                        size: 15,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isUrdu ? "آمدن" : "Income",
                            style: isUrdu
                                ? AppTheme.urdu(fontSize: 10, color: AppColors.textMuted, height: 1.6)
                                : AppTheme.english(fontSize: 10.5, color: AppColors.textMuted),
                          ),
                          Text(
                            "Rs. ${_formatAmount(_totalIncome)}",
                            style: AppTheme.english(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 26, color: AppColors.borderLight),
              const SizedBox(width: 12),
              // Expense
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.alertSoftRed.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_upward_rounded,
                        color: AppColors.alertSoftRed,
                        size: 15,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isUrdu ? "خرچ" : "Expense",
                            style: isUrdu
                                ? AppTheme.urdu(fontSize: 10, color: AppColors.textMuted, height: 1.6)
                                : AppTheme.english(fontSize: 10.5, color: AppColors.textMuted),
                          ),
                          Text(
                            "Rs. ${_formatAmount(_totalExpense)}",
                            style: AppTheme.english(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
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

  // --- PENDING RECEIVABLE NOTICE ---
  Widget _buildPendingNotice(bool isUrdu) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFD54F)),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time_rounded, color: Color(0xFFD97706), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isUrdu
                  ? "بقایا رقم: Rs. ${_formatAmount(_pendingReceivable)}"
                  : "Pending dues: Rs. ${_formatAmount(_pendingReceivable)}",
              style: isUrdu
                  ? AppTheme.urdu(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFB45309),
                      height: 1.7,
                    )
                  : AppTheme.english(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFB45309),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SEGMENTED FILTER TABS ---
  Widget _buildSegmentedFilterTabs(bool isUrdu) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(2.5),
      child: Row(
        children: [
          _buildFilterTabItem(0, isUrdu ? "تمام اندراج" : "All Entries"),
          _buildFilterTabItem(1, isUrdu ? "اخراجات (خرچہ)" : "Expenses"),
          _buildFilterTabItem(2, isUrdu ? "آمدن (فروخت)" : "Income"),
        ],
      ),
    );
  }

  Widget _buildFilterTabItem(int index, String title) {
    final bool isSelected = _filterTab == index;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _filterTab = index),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            style: widget.isUrdu
                ? AppTheme.urdu(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? widget.themeColor : AppColors.textMuted,
                    height: 1.6,
                  )
                : AppTheme.english(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? widget.themeColor : AppColors.textMuted,
                  ),
          ),
        ),
      ),
    );
  }

  // --- CLEAN ENTRY TILE ---
  Widget _buildEntryTile(LedgerEntry item, bool isUrdu) {
    final isExpense = item.type == LedgerEntryType.expense;
    final hasPending = item.hasRemainingBalance;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasPending
              ? const Color(0xFFFFCC80)
              : AppColors.borderLight.withValues(alpha: 0.75),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: hasPending ? () => _openSettle(item) : null,
        child: Row(
          children: [
            // Category Icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: item.category.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Center(
                child: Icon(item.category.icon, size: 17, color: item.category.color),
              ),
            ),
            const SizedBox(width: 10),
            // Title & Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUrdu ? item.titleUrdu : (item.title.isNotEmpty ? item.title : item.titleUrdu),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: isUrdu
                        ? AppTheme.urdu(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                            height: 1.8,
                          )
                        : AppTheme.english(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                  ),
                  SizedBox(height: isUrdu ? 3 : 2),
                  Text(
                    "${isUrdu ? item.category.urduTitle : item.category.englishTitle} • ${_formatDate(item.date, isUrdu)}",
                    style: AppTheme.english(
                      fontSize: 10.5,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Amount & Due tag
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${isExpense ? '-' : '+'} Rs. ${_formatAmount(item.paidAmount)}",
                  style: AppTheme.english(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: isExpense ? AppColors.alertSoftRed : AppColors.successGreen,
                  ),
                ),
                if (hasPending)
                  Text(
                    isUrdu
                        ? "بقایا: ${_formatAmount(item.remainingBalance)}"
                        : "Due: ${_formatAmount(item.remainingBalance)}",
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFE65100),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- CLEAN EMPTY STATE ---
  Widget _buildEmptyState(bool isUrdu) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.7)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.receipt_long_rounded,
            size: 26,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 8),
          Text(
            isUrdu ? "کوئی اندراج موجود نہیں" : "No entries found",
            style: isUrdu
                ? AppTheme.urdu(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  )
                : AppTheme.english(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
          ),
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
