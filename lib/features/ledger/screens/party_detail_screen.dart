import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../models/party_ledger.dart';
import '../widgets/add_party_transaction_dialog.dart';

class PartyDetailScreen extends StatefulWidget {
  final PartyLedger party;
  final bool isUrdu;
  final Function(PartyLedger) onUpdateParty;

  const PartyDetailScreen({
    super.key,
    required this.party,
    required this.isUrdu,
    required this.onUpdateParty,
  });

  @override
  State<PartyDetailScreen> createState() => _PartyDetailScreenState();
}

class _PartyDetailScreenState extends State<PartyDetailScreen> {
  late PartyLedger _party;

  @override
  void initState() {
    super.initState();
    _party = widget.party;
  }

  void _openAddTransaction() {
    showDialog(
      context: context,
      builder: (ctx) => AddPartyTransactionDialog(
        party: _party,
        isUrdu: widget.isUrdu,
        onAdd: (tx) {
          setState(() {
            final updatedList = List<PartyTransaction>.from(_party.transactions)..insert(0, tx);
            _party = _party.copyWith(transactions: updatedList);
          });
          widget.onUpdateParty(_party);
        },
      ),
    );
  }

  // Running balance calculation helper
  List<Map<String, dynamic>> _computeLedgerEntries() {
    final list = List<PartyTransaction>.from(_party.transactions)
      ..sort((a, b) => a.date.compareTo(b.date)); // Oldest first

    double running = 0.0;
    final List<Map<String, dynamic>> rows = [];

    for (final tx in list) {
      double received = 0.0;
      double paid = 0.0;

      if (tx.type == PartyTransactionType.cropSold) {
        received = tx.amount;
        running += tx.amount;
      } else if (tx.type == PartyTransactionType.cashPaid) {
        paid = tx.amount;
        running += tx.amount;
      } else if (tx.type == PartyTransactionType.itemPurchased) {
        paid = tx.amount;
        running -= tx.amount;
      } else if (tx.type == PartyTransactionType.cashReceived) {
        received = tx.amount;
        running -= tx.amount;
      }

      rows.add({
        "tx": tx,
        "received": received,
        "paid": paid,
        "balance": running,
      });
    }

    // Newest first
    return rows.reversed.toList();
  }

  void _showTransactionDetailsBottomSheet(Map<String, dynamic> row, bool isUrdu) {
    final PartyTransaction tx = row["tx"];
    final double received = row["received"];
    final double paid = row["paid"];
    final double bal = row["balance"];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 32,
                  height: 3.5,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isUrdu ? "لین دین کی مکمل تفصیل" : "Transaction Details",
                    style: isUrdu
                        ? AppTheme.urdu(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark)
                        : const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(tx.type).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _getCategoryShortTitle(tx.type, isUrdu),
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: _getCategoryColor(tx.type),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildDetailRow(isUrdu ? "مد / آئٹم:" : "Item/Title:", tx.titleUrdu),
              _buildDetailRow(isUrdu ? "تاریخ:" : "Date:", "${tx.date.day}/${tx.date.month}/${tx.date.year}"),
              if (tx.note.isNotEmpty)
                _buildDetailRow(isUrdu ? "اضافی نوٹ:" : "Note:", tx.note),
              const Divider(height: 14, color: AppColors.borderLight),
              if (received > 0)
                _buildDetailRow(
                  isUrdu ? "وصول شدہ رقم (+):" : "Received Amount (+):",
                  "Rs. ${_formatAmount(received)}",
                  color: AppColors.successGreen,
                ),
              if (paid > 0)
                _buildDetailRow(
                  isUrdu ? "ادا شدہ / کٹوتی (-):" : "Paid / Bill Amount (-):",
                  "Rs. ${_formatAmount(paid)}",
                  color: const Color(0xFFE65100),
                ),
              _buildDetailRow(
                isUrdu ? "اس وقت کا بقایا:" : "Net Balance:",
                bal.abs() <= 0.5
                    ? "Rs. 0 (برابر)"
                    : (bal > 0 ? "+ Rs. ${_formatAmount(bal)} (لینا ہے)" : "- Rs. ${_formatAmount(bal.abs())} (دینا ہے)"),
                color: bal > 0 ? AppColors.successGreen : (bal < 0 ? AppColors.alertSoftRed : AppColors.textDark),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: Text(isUrdu ? "بند کریں" : "Close", style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: color ?? AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUrdu = widget.isUrdu;
    final net = _party.netBalance;
    final ledgerEntries = _computeLedgerEntries();

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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _party.displayName(isUrdu),
                style: isUrdu
                    ? AppTheme.urdu(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark)
                    : AppTheme.english(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              Text(
                "${_party.displayLocation(isUrdu)} • ${_party.phone}",
                style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_rounded, size: 18, color: AppColors.primaryDark),
              tooltip: isUrdu ? "کھاتہ پرچی شیئر کریں" : "Share Khata Statement",
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isUrdu
                          ? "${_party.name} کی کھاتہ پرچی واٹس ایپ کے لیے تیار ہے"
                          : "Khata slip ready to share on WhatsApp",
                      style: const TextStyle(fontSize: 11),
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const SizedBox(width: 4),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 74.0),
          child: SizedBox(
            height: 40,
            child: FloatingActionButton.extended(
              onPressed: _openAddTransaction,
              backgroundColor: AppColors.primaryDark,
              elevation: 2,
              icon: const Icon(Icons.add_rounded, color: AppColors.accentLime, size: 16),
              label: Text(
                isUrdu ? "نیا اندراج (+)" : "Add Entry (+)",
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
            // Net Balance Statement Compact Banner Card
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: net >= 0
                      ? [const Color(0xFF1B4332), const Color(0xFF2D6A4F)]
                      : [const Color(0xFF881337), const Color(0xFFBE123C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: (net >= 0 ? AppColors.primaryDark : const Color(0xFFBE123C)).withValues(alpha: 0.16),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        net > 0.5
                            ? (isUrdu ? "آپ نے ڈیلر سے لینے ہیں:" : "You will receive:")
                            : (net < -0.5
                                ? (isUrdu ? "آپ نے ڈیلر کو دینے ہیں:" : "You owe dealer:")
                                : (isUrdu ? "حساب برابر ہے:" : "Khata Balanced:")),
                        style: isUrdu
                            ? AppTheme.urdu(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w600)
                            : const TextStyle(fontSize: 10, color: Colors.white70),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Rs. ${_formatAmount(net.abs())}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      net > 0.5
                          ? (isUrdu ? "لینا ہے" : "Receivable")
                          : (net < -0.5 ? (isUrdu ? "دینا ہے" : "Payable") : (isUrdu ? "برابر" : "Settled")),
                      style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Header info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isUrdu ? "کھاتہ جدول" : "Khata Table",
                  style: isUrdu
                      ? AppTheme.urdu(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textDark)
                      : const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textDark),
                ),
                Text(
                  isUrdu ? "تفصیل کیلئے ٹیپ کریں" : "Tap for info",
                  style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // 100% SCREEN-FITTING COMPACT RESPONSIVE TABLE
            _buildResponsiveLedgerTable(ledgerEntries, isUrdu),
          ],
        ),
      ),
    );
  }

  // --- 100% RESPONSIVE SCREEN-FITTING TABLE ---
  Widget _buildResponsiveLedgerTable(List<Map<String, dynamic>> rows, bool isUrdu) {
    if (rows.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        alignment: Alignment.center,
        child: Text(
          isUrdu ? "اس کھاتے میں کوئی لین دین درج نہیں ہے" : "No transactions found",
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table Column Headers Row (100% Width Fit)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            decoration: const BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                // Col 1: Date & Item (Flex 4)
                Expanded(
                  flex: 4,
                  child: Text(
                    isUrdu ? "تاریخ / مد" : "Date/Item",
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ),

                // Col 2: Received (+) (Flex 3)
                Expanded(
                  flex: 3,
                  child: Text(
                    isUrdu ? "وصول (+)" : "Recv (+)",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.successGreen,
                    ),
                  ),
                ),

                // Col 3: Paid/Bill (-) (Flex 3)
                Expanded(
                  flex: 3,
                  child: Text(
                    isUrdu ? "ادا / بل (-)" : "Paid (-)",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFE65100),
                    ),
                  ),
                ),

                // Col 4: Baqaya (Flex 3)
                Expanded(
                  flex: 3,
                  child: Text(
                    isUrdu ? "بقایا" : "Balance",
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rows.length,
            separatorBuilder: (context, _) => const Divider(height: 1, color: AppColors.borderLight),
            itemBuilder: (context, index) {
              final row = rows[index];
              final PartyTransaction tx = row["tx"];
              final double received = row["received"];
              final double paid = row["paid"];
              final double bal = row["balance"];

              return InkWell(
                onTap: () => _showTransactionDetailsBottomSheet(row, isUrdu),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                  child: Row(
                    children: [
                      // Col 1: Date & Item Title (cleanly stacked)
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isUrdu ? _cleanShortTitle(tx.titleUrdu) : (tx.title.isNotEmpty ? tx.title : tx.type.englishTitle),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: isUrdu
                                  ? AppTheme.urdu(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                    )
                                  : const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                    ),
                            ),
                            const SizedBox(height: 1),
                            Row(
                              children: [
                                Text(
                                  _formatDate(tx.date, isUrdu),
                                  style: const TextStyle(fontSize: 8.5, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(width: 3),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0.5),
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(tx.type).withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    _getCategoryShortTitle(tx.type, isUrdu),
                                    style: TextStyle(
                                      fontSize: 7.5,
                                      fontWeight: FontWeight.w700,
                                      color: _getCategoryColor(tx.type),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Col 2: Received (+)
                      Expanded(
                        flex: 3,
                        child: Text(
                          received > 0 ? _formatAmount(received) : "—",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: received > 0 ? AppColors.successGreen : AppColors.textLight,
                          ),
                        ),
                      ),

                      // Col 3: Paid/Bill (-)
                      Expanded(
                        flex: 3,
                        child: Text(
                          paid > 0 ? _formatAmount(paid) : "—",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: paid > 0 ? const Color(0xFFE65100) : AppColors.textLight,
                          ),
                        ),
                      ),

                      // Col 4: Running Baqaya (Compact Pill)
                      Expanded(
                        flex: 3,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: bal > 0.5
                                  ? AppColors.successGreen.withValues(alpha: 0.10)
                                  : (bal < -0.5
                                      ? AppColors.alertSoftRed.withValues(alpha: 0.10)
                                      : AppColors.surfaceVariant),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              bal.abs() <= 0.5
                                  ? "0"
                                  : (bal > 0 ? "+${_formatAmount(bal)}" : "-${_formatAmount(bal.abs())}"),
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: bal > 0.5
                                    ? AppColors.successGreen
                                    : (bal < -0.5 ? AppColors.alertSoftRed : AppColors.textMuted),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(PartyTransactionType type) {
    switch (type) {
      case PartyTransactionType.cropSold:
        return const Color(0xFF2E7D32);
      case PartyTransactionType.itemPurchased:
        return const Color(0xFFE65100);
      case PartyTransactionType.cashReceived:
        return const Color(0xFF1565C0);
      case PartyTransactionType.cashPaid:
        return const Color(0xFF6A1B9A);
    }
  }

  String _getCategoryShortTitle(PartyTransactionType type, bool isUrdu) {
    switch (type) {
      case PartyTransactionType.cropSold:
        return isUrdu ? "فصل" : "Crop";
      case PartyTransactionType.itemPurchased:
        return isUrdu ? "سامان" : "Item";
      case PartyTransactionType.cashReceived:
        return isUrdu ? "کیش" : "Cash";
      case PartyTransactionType.cashPaid:
        return isUrdu ? "ادائیگی" : "Paid";
    }
  }

  String _cleanShortTitle(String text) {
    return text.replaceAll("کیڑے مار اسپرے", "اسپرے")
               .replaceAll("فروخت کی", "")
               .replaceAll("لی گئی", "")
               .replaceAll("(ایما مRelevant)", "")
               .trim();
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

  String _formatDate(DateTime date, [bool isUrdu = true]) {
    final now = DateTime.now();
    if (now.difference(date).inHours < 24 && date.day == now.day) {
      return isUrdu ? "آج" : "Today";
    } else if (now.difference(date).inHours < 48 && (now.day - date.day == 1)) {
      return isUrdu ? "کل" : "Yesterday";
    }
    return "${date.day}/${date.month}";
  }
}
