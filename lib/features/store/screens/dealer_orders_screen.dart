import 'package:flutter/material.dart';
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
  late bool _isUrdu;
  late List<DealerOrderModel> _orders;
  String _selectedFilter = "all"; // all, pending, confirmed, dispatched, completed
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    // Strictly English for Dealer Section as requested
    _isUrdu = false;
    _orders = MockDealerOrders.getInitialOrders();
  }

  List<DealerOrderModel> get _filteredOrders {
    return _orders.where((order) {
      // 1. Status Filter
      if (_selectedFilter == "pending" && order.status != DealerOrderStatus.pending) {
        return false;
      }
      if (_selectedFilter == "confirmed" && order.status != DealerOrderStatus.confirmed) {
        return false;
      }
      if (_selectedFilter == "dispatched" && order.status != DealerOrderStatus.dispatched) {
        return false;
      }
      if (_selectedFilter == "completed" && order.status != DealerOrderStatus.completed) {
        return false;
      }

      // 2. Search Query
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        final matchName = order.farmerName.toLowerCase().contains(q);
        final matchCity = order.farmerCity.toLowerCase().contains(q) || order.farmerVillage.toLowerCase().contains(q);
        final matchProduct = order.productNameEnglish.toLowerCase().contains(q) || order.productNameUrdu.contains(q);
        final matchId = order.id.toLowerCase().contains(q);
        return matchName || matchCity || matchProduct || matchId;
      }

      return true;
    }).toList();
  }

  int get _pendingCount => _orders.where((o) => o.status == DealerOrderStatus.pending).length;
  int get _dispatchedCount => _orders.where((o) => o.status == DealerOrderStatus.dispatched).length;
  double get _totalRevenue => _orders
      .where((o) => o.status == DealerOrderStatus.completed || o.status == DealerOrderStatus.dispatched)
      .fold(0.0, (sum, o) => sum + o.totalPrice);

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
              order.farmerName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            Text(
              order.getFullLocation(_isUrdu),
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
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
                          content: Text(_isUrdu ? "کال ملائی جا رہی ہے: ${order.farmerPhone}" : "Dialing ${order.farmerPhone}..."),
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
                    _isUrdu ? "آرڈر رسید و انوائس" : "Order Invoice Details",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
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
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
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
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: order.getStatusColor()),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Farmer Info
                    Text(
                      _isUrdu ? "کسان کی تفصیلات:" : "Farmer Information:",
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
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
                          _buildDetailRow(_isUrdu ? "نام کسان" : "Farmer Name", order.farmerName),
                          const Divider(height: 12),
                          _buildDetailRow(_isUrdu ? "پتہ و علاقہ" : "Delivery Location", order.getFullLocation(_isUrdu)),
                          const Divider(height: 12),
                          _buildDetailRow(_isUrdu ? "موبائل نمبر" : "Phone", order.farmerPhone),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Itemized Breakdown
                    Text(
                      _isUrdu ? "مصنوعات کی تفصیل:" : "Itemized Bill:",
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
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
                          _buildDetailRow(_isUrdu ? "تعداد / پیکنگ" : "Quantity", "${order.quantity} × ${order.getPackUnit(_isUrdu)}"),
                          const Divider(height: 12),
                          _buildDetailRow(_isUrdu ? "فی بوری ریٹ" : "Unit Rate", "Rs. ${order.unitPrice.toInt()}"),
                          const Divider(height: 12),
                          _buildDetailRow(_isUrdu ? "ادائیگی کا طریقہ" : "Payment Mode", order.paymentMethod),
                          const Divider(height: 12),
                          _buildDetailRow(
                            _isUrdu ? "کل بل (Total Amount)" : "Total Bill",
                            "Rs. ${order.totalPrice.toInt()}",
                            isBold: true,
                            textColor: AppColors.primaryDark,
                          ),
                        ],
                      ),
                    ),
                    if (order.deliveryNotes != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        _isUrdu ? "خصوصی ہدایات:" : "Delivery Instructions:",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textDark),
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
                          order.deliveryNotes!,
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF92400E)),
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
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: textColor ?? AppColors.textDark,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        // 1. TOP METRICS CARDS (PENDING, DISPATCHED, REVENUE)
        _buildMetricsHeader(),

        // 2. SEARCH & QUICK FILTER PILLS
        _buildFilterBar(),

        // 3. ORDER LIST
        Expanded(
          child: _filteredOrders.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
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
            _isUrdu ? "کسان آرڈرز مینجمنٹ" : "Farmer Orders",
            style: _isUrdu
                ? AppTheme.urdu(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primaryDark)
                : AppTheme.english(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
          ),
          centerTitle: true,
          actions: [
            InkWell(
              onTap: () => setState(() => _isUrdu = !_isUrdu),
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
  // 1. METRICS ROW
  // -------------------------------------------------------------
  Widget _buildMetricsHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetricItem(
            label: _isUrdu ? "نئے آرڈرز" : "Pending",
            value: "$_pendingCount",
            color: const Color(0xFFD97706),
            icon: Icons.pending_actions_rounded,
          ),
          Container(width: 1, height: 32, color: AppColors.borderLight),
          _buildMetricItem(
            label: _isUrdu ? "روانہ شدہ" : "Dispatched",
            value: "$_dispatchedCount",
            color: const Color(0xFF7C3AED),
            icon: Icons.local_shipping_rounded,
          ),
          Container(width: 1, height: 32, color: AppColors.borderLight),
          _buildMetricItem(
            label: _isUrdu ? "آمدن والیم" : "Delivered",
            value: "Rs. ${_totalRevenue > 999 ? '${(_totalRevenue / 1000).toInt()}k' : _totalRevenue.toInt()}",
            color: const Color(0xFF16A34A),
            icon: Icons.check_circle_outline_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({required String label, required String value, required Color color, required IconData icon}) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // 2. SEARCH & FILTER TABS
  // -------------------------------------------------------------
  Widget _buildFilterBar() {
    return Column(
      children: [
        // Search Box
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: _isUrdu ? "کسان، آرڈر ID یا پروڈکٹ تلاش کریں..." : "Search farmer, order ID or product...",
                hintStyle: const TextStyle(fontSize: 11.5, color: AppColors.textLight),
                prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF16A34A)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 16),
                        onPressed: () => setState(() => _searchQuery = ""),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Filter Pills Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              _buildFilterPill("all", _isUrdu ? "تمام آرڈرز (${_orders.length})" : "All (${_orders.length})"),
              const SizedBox(width: 6),
              _buildFilterPill("pending", _isUrdu ? "نئے (${_orders.where((o) => o.status == DealerOrderStatus.pending).length})" : "Pending (${_orders.where((o) => o.status == DealerOrderStatus.pending).length})"),
              const SizedBox(width: 6),
              _buildFilterPill("dispatched", _isUrdu ? "روانہ شدہ (${_orders.where((o) => o.status == DealerOrderStatus.dispatched).length})" : "Dispatched (${_orders.where((o) => o.status == DealerOrderStatus.dispatched).length})"),
              const SizedBox(width: 6),
              _buildFilterPill("completed", _isUrdu ? "مکمل (${_orders.where((o) => o.status == DealerOrderStatus.completed).length})" : "Completed (${_orders.where((o) => o.status == DealerOrderStatus.completed).length})"),
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDark : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
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
  // 3. ORDER CARD
  // -------------------------------------------------------------
  Widget _buildOrderCard(DealerOrderModel order) {
    final catColor = order.category == AgriProductCategory.seeds
        ? const Color(0xFF16A34A)
        : const Color(0xFF0284C7);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            color: Colors.black.withValues(alpha: 0.03),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                // 2. Farmer Name & Call Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.farmerName,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark),
                          ),
                          const SizedBox(height: 1),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textMuted),
                              const SizedBox(width: 2),
                              Text(
                                order.getFullLocation(_isUrdu),
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Quick Call Button
                    InkWell(
                      onTap: () => _callFarmer(order),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.call_rounded, size: 13, color: Color(0xFF16A34A)),
                            const SizedBox(width: 4),
                            Text(
                              _isUrdu ? "کال کریں" : "Call",
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF15803D)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // 3. Product & Quantity
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          order.category == AgriProductCategory.seeds ? Icons.spa_rounded : Icons.science_rounded,
                          color: catColor,
                          size: 20,
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
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${order.quantity} × ${order.getPackUnit(_isUrdu)}  (Rs. ${order.unitPrice.toInt()} / unit)",
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    // Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Rs. ${order.totalPrice.toInt()}",
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
                        ),
                        Text(
                          order.paymentMethod.split('(').first.trim(),
                          style: const TextStyle(fontSize: 9.5, color: AppColors.textLight, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),

                // 4. Action Buttons based on status
                const SizedBox(height: 12),
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
                _isUrdu ? "منسوخ کریں" : "Decline",
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.alertSoftRed),
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
                _isUrdu ? "آرڈر قبول کر لیا گیا ہے" : "Order accepted & confirmed",
              ),
              icon: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
              label: Text(
                _isUrdu ? "آرڈر قبول کریں" : "Accept Order",
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white),
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
                _isUrdu ? "مال فارم کے لیے روانہ ہو چکا ہے" : "Order dispatched to farm",
              ),
              icon: const Icon(Icons.local_shipping_rounded, size: 16, color: Colors.white),
              label: Text(
                _isUrdu ? "مال روانہ کریں (Dispatch)" : "Dispatch to Farm",
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white),
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
                _isUrdu ? "آرڈر مکمل اور کیش وصول ہو گیا" : "Order marked Delivered & Paid",
              ),
              icon: const Icon(Icons.check_circle_outline_rounded, size: 16, color: Colors.white),
              label: Text(
                _isUrdu ? "مکمل / ڈیلیورڈ مارک کریں" : "Mark as Delivered",
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white),
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
            icon: const Icon(Icons.receipt_long_rounded, size: 15, color: AppColors.primaryDark),
            label: Text(
              _isUrdu ? "مکمل رسید و سمری دیکھیں" : "View Complete Receipt",
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
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
          const Icon(Icons.inbox_rounded, size: 48, color: AppColors.textLight),
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
