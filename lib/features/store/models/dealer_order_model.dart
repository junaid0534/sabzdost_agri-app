import 'package:flutter/material.dart';
import 'agri_product_model.dart';

enum DealerOrderStatus {
  pending,    // نیا آرڈر (New order from farmer)
  confirmed,  // تصدیق شدہ (Confirmed / Being prepared)
  dispatched, // روانہ کردہ (On the way to farm)
  completed,  // مکمل شدہ (Delivered & Payment settled)
  cancelled,  // منسوخ (Cancelled)
}

class DealerOrderModel {
  final String id;
  final String farmerName;
  final String farmerPhone;
  final String farmerVillage;
  final String farmerCity;
  final String productNameEnglish;
  final String productNameUrdu;
  final AgriProductCategory category;
  final int quantity;
  final String packUnitEnglish;
  final String packUnitUrdu;
  final double unitPrice;
  final double totalPrice;
  final DateTime orderDate;
  DealerOrderStatus status;
  final String paymentMethod;
  final String? deliveryNotes;

  DealerOrderModel({
    required this.id,
    required this.farmerName,
    required this.farmerPhone,
    required this.farmerVillage,
    required this.farmerCity,
    required this.productNameEnglish,
    required this.productNameUrdu,
    required this.category,
    required this.quantity,
    required this.packUnitEnglish,
    required this.packUnitUrdu,
    required this.unitPrice,
    required this.totalPrice,
    required this.orderDate,
    required this.status,
    required this.paymentMethod,
    this.deliveryNotes,
  });

  String getProductName(bool isUrdu) => isUrdu ? productNameUrdu : productNameEnglish;
  String getPackUnit(bool isUrdu) => isUrdu ? packUnitUrdu : packUnitEnglish;
  String getFullLocation(bool isUrdu) => isUrdu ? "$farmerVillage، $farmerCity" : "$farmerVillage, $farmerCity";

  String getStatusLabel(bool isUrdu) {
    switch (status) {
      case DealerOrderStatus.pending:
        return isUrdu ? "نیا آرڈر (پینڈنگ)" : "Pending Review";
      case DealerOrderStatus.confirmed:
        return isUrdu ? "تصدیق شدہ" : "Confirmed";
      case DealerOrderStatus.dispatched:
        return isUrdu ? "روانہ ہو چکا" : "Dispatched";
      case DealerOrderStatus.completed:
        return isUrdu ? "مکمل / ڈیلیورڈ" : "Completed";
      case DealerOrderStatus.cancelled:
        return isUrdu ? "منسوخ" : "Cancelled";
    }
  }

  Color getStatusColor() {
    switch (status) {
      case DealerOrderStatus.pending:
        return const Color(0xFFD97706); // Warm Amber
      case DealerOrderStatus.confirmed:
        return const Color(0xFF2563EB); // Royal Blue
      case DealerOrderStatus.dispatched:
        return const Color(0xFF7C3AED); // Vibrant Purple
      case DealerOrderStatus.completed:
        return const Color(0xFF16A34A); // Emerald Green
      case DealerOrderStatus.cancelled:
        return const Color(0xFFDC2626); // Alert Red
    }
  }

  Color getStatusBgColor() {
    switch (status) {
      case DealerOrderStatus.pending:
        return const Color(0xFFFEF3C7);
      case DealerOrderStatus.confirmed:
        return const Color(0xFFDBEAFE);
      case DealerOrderStatus.dispatched:
        return const Color(0xFFEDE9FE);
      case DealerOrderStatus.completed:
        return const Color(0xFFDCFCE7);
      case DealerOrderStatus.cancelled:
        return const Color(0xFFFEE2E2);
    }
  }
}
