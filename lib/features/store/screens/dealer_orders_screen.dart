import 'package:flutter/material.dart';
import '../../../core/localization/language_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../data/mock_dealer_orders.dart';
import '../models/agri_product_model.dart';
import '../models/dealer_order_model.dart';

/// Clean, professional Farmer Order Management screen for Agri Dealers.
/// Supports status tracking, direct farmer communication, and order fulfillment.
class DealerOrdersScreen extends StatefulWidget {
  final bool isStandalone;
  final bool? isUrdu;

  const DealerOrdersScreen({
    super.key,
    this.isStandalone = true,
    this.isUrdu,
  });

  @override
  State<DealerOrdersScreen> createState() => _DealerOrdersScreenState();
}

class _DealerOrdersScreenState extends State<DealerOrdersScreen> {
  bool get _isUrdu => widget.isUrdu ?? LanguageController.instance.isUrdu;
  late List<DealerOrderModel> _orders;
  String _selectedFilter = "all"; // all, pending, dispatched, completed
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _orders = MockDealerOrders.getInitialOrders();
  }

  List<DealerOrderModel> get _filteredOrders {
    return _orders.where((order) {
      // 1. Status Filter
      if (_selectedFilter == "pending" && order.status != DealerOrderStatus.pending) {
        return false;
      }
      if (_selectedFilter == "dispatched" &&
          (order.status != DealerOrderStatus.dispatched && order.status != DealerOrderStatus.confirmed)) {
        return false;
      }
      if (_selectedFilter == "completed" && order.status != DealerOrderStatus.completed) {
        return false;
      }

      // 2. Search Query
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        final matchFarmer = order.getFarmerName(_isUrdu).toLowerCase().contains(q) ||
            order.farmerName.toLowerCase().contains(q) ||
            (order.farmerNameEnglish?.toLowerCase().contains(q) ?? false);
        final matchCity = order.getFullLocation(_isUrdu).toLowerCase().contains(q) ||
            order.farmerCity.toLowerCase().contains(q) ||
            (order.farmerCityEnglish?.toLowerCase().contains(q) ?? false);
        final matchProduct = order.productNameEnglish.toLowerCase().contains(q) ||
            order.productNameUrdu.contains(q);
        final matchId = order.id.toLowerCase().contains(q);
        return matchFarmer || matchCity || matchProduct || matchId;
      }

      return true;
    }).toList();
  }

  void _updateOrderStatus(DealerOrderModel order, DealerOrderStatus newStatus, String actionMessage) {
    setState(() {
      order.status = newStatus;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                actionMessage,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryDark,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _callFarmer(DealerOrderModel order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const CircleAvatar(
              radius: 26,
              backgroundColor: Color(0xFFDCFCE7),
              child: Icon(Icons.phone_in_talk_rounded, color: Color(0xFF16A34A), size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              order.getFarmerName(_isUrdu),
              style: _isUrdu
                  ? AppTheme.urdu(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)
                  : AppTheme.english(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            const SizedBox(height: 2),
            Text(
              order.getFullLocation(_isUrdu),
              style: _isUrdu
                  ? AppTheme.urdu(fontSize: 12, color: AppColors.textMuted)
                  : AppTheme.english(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 6),
            Text(
              order.farmerPhone,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(_isUrdu ? "بند کریں" : "Cancel"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_isUrdu
                              ? "کال ملائی جا رہی ہے: ${order.farmerPhone}"
                              : "Dialing ${order.farmerPhone}..."),
                          backgroundColor: const Color(0xFF16A34A),
                          duration: const Duration(milliseconds: 1000),
                        ),
                      );
                    },
                    icon: const Icon(Icons.call_rounded, size: 18, color: Colors.white),
                    label: Text(_isUrdu ? "کال کریں" : "Call Now", style: const TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  void _showOrderInvoice(DealerOrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.82,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 44,
              height: 4,
              decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isUrdu ? "آرڈر رسید" : "Order Invoice",
                    style: _isUrdu
                        ? AppTheme.urdu(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primaryDark)
                        : AppTheme.english(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Invoice Header
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.freshLeafGradient.colors.first.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.id,
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year} - ${order.orderDate.hour}:${order.orderDate.minute.toString().padLeft(2, '0')}",
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: order.getStatusBgColor(),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              order.getStatusLabel(_isUrdu),
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w800, color: order.getStatusColor()),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Farmer Info
                    Text(
                      _isUrdu ? "کسان کی تفصیلات:" : "Farmer Details:",
                      style: _isUrdu
                          ? AppTheme.urdu(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryDark)
                          : AppTheme.english(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(_isUrdu ? "نام کسان" : "Farmer Name", order.getFarmerName(_isUrdu)),
                          const Divider(height: 12),
                          _buildDetailRow(_isUrdu ? "پتہ" : "Location", order.getFullLocation(_isUrdu)),
                          const Divider(height: 12),
                          _buildDetailRow(_isUrdu ? "موبائل" : "Phone", order.farmerPhone),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Itemized Breakdown
                    Text(
                      _isUrdu ? "آرڈر تفصیل:" : "Itemized Bill:",
                      style: _isUrdu
                          ? AppTheme.urdu(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryDark)
                          : AppTheme.english(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(_isUrdu ? "پروڈکٹ" : "Product", order.getProductName(_isUrdu)),
                          const Divider(height: 12),
                          _buildDetailRow(
                              _isUrdu ? "تعداد" : "Quantity", "${order.quantity} × ${order.getPackUnit(_isUrdu)}"),
                          const Divider(height: 12),
                          _buildDetailRow(
                              _isUrdu ? "یونٹ ریٹ" : "Unit Rate", "Rs. ${order.unitPrice.toInt()}"),
                          const Divider(height: 12),
                          _buildDetailRow(
                              _isUrdu ? "ادائیگی" : "Payment Mode", order.getPaymentMethod(_isUrdu)),
                          const Divider(height: 12),
                          _buildDetailRow(
                            _isUrdu ? "کل بل" : "Total Bill",
                            "Rs. ${order.totalPrice.toInt()}",
                            isBold: true,
                            textColor: AppColors.primaryDark,
                          ),
                        ],
                      ),
                    ),
                    if (order.getDeliveryNotes(_isUrdu) != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        _isUrdu ? "خصوصی ہدایات:" : "Delivery Instructions:",
                        style: _isUrdu
                            ? AppTheme.urdu(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textDark)
                            : AppTheme.english(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Text(
                          order.getDeliveryNotes(_isUrdu)!,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: const Color(0xFF92400E),
                            height: _isUrdu ? 1.7 : 1.4,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color? textColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
              color: textColor ?? AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        // 1. IMPROVED SEARCH BAR & FILTER TABS (KPI Cards removed as requested)
        _buildFilterBar(),

        // 2. ORDER LIST
        Expanded(
          child: _filteredOrders.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
                  itemCount: _filteredOrders.length,
                  itemBuilder: (context, index) {
                    return _buildOrderCard(_filteredOrders[index]);
                  },
                ),
        ),
      ],
    );

    if (widget.isStandalone) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark, size: 21),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            _isUrdu ? "کسان آرڈرز" : "Farmer Orders",
            style: _isUrdu
                ? AppTheme.urdu(fontSize: 16.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark)
                : AppTheme.english(fontSize: 16.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
          ),
          centerTitle: true,
          actions: [
            InkWell(
              onTap: () => LanguageController.instance.toggleLanguage(),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Text(
                  _isUrdu ? "EN" : "اردو",
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                ),
              ),
            ),
          ],
        ),
        body: body,
      );
    }

    return body;
  }

  // -------------------------------------------------------------
  // IMPROVED SEARCH & FILTER TABS (Clean, elevated, no overflow)
  // -------------------------------------------------------------
  Widget _buildFilterBar() {
    return Column(
      children: [
        // Modern Elevated Search Box (Short, non-overflowing hint text)
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: _isUrdu ? "آرڈر تلاش کریں..." : "Search orders...",
                hintStyle: const TextStyle(fontSize: 12, color: AppColors.textLight, fontWeight: FontWeight.w500),
                prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF16A34A)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 17, color: AppColors.textMuted),
                        onPressed: () => setState(() => _searchQuery = ""),
                      )
                    : null,
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),

        // Filter Pills Row (Short, non-cropping labels)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              _buildFilterPill(
                  "all", _isUrdu ? "تمام (${_orders.length})" : "All (${_orders.length})"),
              const SizedBox(width: 6),
              _buildFilterPill(
                  "pending",
                  _isUrdu
                      ? "نئے (${_orders.where((o) => o.status == DealerOrderStatus.pending).length})"
                      : "Pending (${_orders.where((o) => o.status == DealerOrderStatus.pending).length})"),
              const SizedBox(width: 6),
              _buildFilterPill(
                  "dispatched",
                  _isUrdu
                      ? "روانہ (${_orders.where((o) => o.status == DealerOrderStatus.dispatched || o.status == DealerOrderStatus.confirmed).length})"
                      : "Dispatched (${_orders.where((o) => o.status == DealerOrderStatus.dispatched || o.status == DealerOrderStatus.confirmed).length})"),
              const SizedBox(width: 6),
              _buildFilterPill(
                  "completed",
                  _isUrdu
                      ? "مکمل (${_orders.where((o) => o.status == DealerOrderStatus.completed).length})"
                      : "Completed (${_orders.where((o) => o.status == DealerOrderStatus.completed).length})"),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildFilterPill(String key, String label) {
    final isSelected = _selectedFilter == key;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = key),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDark : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primaryDark : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // ORDER CARD (Clean, compact, no text overflow)
  // -------------------------------------------------------------
  Widget _buildOrderCard(DealerOrderModel order) {
    final catColor = order.category == AgriProductCategory.seeds
        ? const Color(0xFF16A34A)
        : const Color(0xFF0284C7);

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: order.status == DealerOrderStatus.pending
              ? const Color(0xFFFDE68A)
              : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Order ID & Status Header Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: order.getStatusBgColor().withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      order.id,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textDark),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "• ${order.orderDate.hour}:${order.orderDate.minute.toString().padLeft(2, '0')}",
                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: order.getStatusColor().withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    order.getStatusLabel(_isUrdu),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: order.getStatusColor(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Farmer Name & Call Action (Guaranteed no overflow)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.getFarmerName(_isUrdu),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _isUrdu
                                ? AppTheme.urdu(
                                    fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textDark)
                                : AppTheme.english(
                                    fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textDark),
                          ),
                          const SizedBox(height: 1),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textMuted),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  order.getFullLocation(_isUrdu),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Quick Call Pill
                    InkWell(
                      onTap: () => _callFarmer(order),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.call_rounded, size: 12, color: Color(0xFF16A34A)),
                            const SizedBox(width: 4),
                            Text(
                              _isUrdu ? "کال" : "Call",
                              style: const TextStyle(
                                  fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF15803D)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),

                // 3. Product & Price (Clean, no text crunching)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          order.category == AgriProductCategory.seeds
                              ? Icons.spa_rounded
                              : Icons.science_rounded,
                          color: catColor,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.getProductName(_isUrdu),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _isUrdu
                                ? AppTheme.urdu(
                                    fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textDark)
                                : AppTheme.english(
                                    fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textDark),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            "${order.quantity} × ${order.getPackUnit(_isUrdu)}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Price & Payment Badge
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Rs. ${order.totalPrice.toInt()}",
                          style: const TextStyle(
                              fontSize: 14.5, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
                        ),
                        Text(
                          order.getPaymentMethod(_isUrdu),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 9.5, color: AppColors.textLight, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),

                // 4. Concise Action Buttons (Never crop or line-wrap awkwardly)
                const SizedBox(height: 10),
                _buildActionButtonsRow(order),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonsRow(DealerOrderModel order) {
    if (order.status == DealerOrderStatus.pending) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _updateOrderStatus(
                order,
                DealerOrderStatus.cancelled,
                _isUrdu ? "آرڈر منسوخ کر دیا گیا" : "Order declined",
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                side: const BorderSide(color: Color(0xFFFCA5A5)),
              ),
              child: Text(
                _isUrdu ? "منسوخ" : "Decline",
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.alertSoftRed),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => _updateOrderStatus(
                order,
                DealerOrderStatus.confirmed,
                _isUrdu ? "آرڈر قبول کر لیا گیا ہے" : "Order accepted",
              ),
              icon: const Icon(Icons.check_rounded, size: 15, color: Colors.white),
              label: Text(
                _isUrdu ? "قبول کریں" : "Accept",
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      );
    }

    if (order.status == DealerOrderStatus.confirmed) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showOrderInvoice(order),
              icon: const Icon(Icons.receipt_long_rounded, size: 14),
              label: Text(_isUrdu ? "رسید" : "Invoice", style: const TextStyle(fontSize: 11)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                side: const BorderSide(color: AppColors.borderLight),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => _updateOrderStatus(
                order,
                DealerOrderStatus.dispatched,
                _isUrdu ? "مال روانہ ہو چکا ہے" : "Order dispatched to farm",
              ),
              icon: const Icon(Icons.local_shipping_rounded, size: 15, color: Colors.white),
              label: Text(
                _isUrdu ? "روانہ کریں" : "Dispatch",
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      );
    }

    if (order.status == DealerOrderStatus.dispatched) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showOrderInvoice(order),
              icon: const Icon(Icons.receipt_long_rounded, size: 14),
              label: Text(_isUrdu ? "تفصیل" : "Details", style: const TextStyle(fontSize: 11)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                side: const BorderSide(color: AppColors.borderLight),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => _updateOrderStatus(
                order,
                DealerOrderStatus.completed,
                _isUrdu ? "آرڈر مکمل اور کیش وصول ہو گیا" : "Order marked as Delivered",
              ),
              icon: const Icon(Icons.check_circle_outline_rounded, size: 15, color: Colors.white),
              label: Text(
                _isUrdu ? "ڈیلیورڈ" : "Delivered",
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      );
    }

    // Completed or Cancelled
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showOrderInvoice(order),
            icon: const Icon(Icons.receipt_long_rounded, size: 14, color: AppColors.primaryDark),
            label: Text(
              _isUrdu ? "رسید دیکھیں" : "View Receipt",
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              side: const BorderSide(color: AppColors.borderLight),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_rounded, size: 44, color: AppColors.textLight),
          const SizedBox(height: 8),
          Text(
            _isUrdu ? "کوئی آرڈر نہیں ملا" : "No orders found",
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
