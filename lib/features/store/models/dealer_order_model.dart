import 'package:flutter/material.dart';
import 'agri_product_model.dart';

enum DealerOrderStatus {
  pending,    // New order from farmer
  confirmed,  // Confirmed / Being prepared
  dispatched, // On the way to farm
  completed,  // Delivered & Payment settled
  cancelled,  // Cancelled
}

class DealerOrderModel {
  final String id;
  final String farmerName;
  final String? farmerNameEnglish;
  final String farmerPhone;
  final String farmerVillage;
  final String? farmerVillageEnglish;
  final String farmerCity;
  final String? farmerCityEnglish;
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
  final String? paymentMethodEnglish;
  final String? deliveryNotes;
  final String? deliveryNotesEnglish;

  DealerOrderModel({
    required this.id,
    required this.farmerName,
    this.farmerNameEnglish,
    required this.farmerPhone,
    required this.farmerVillage,
    this.farmerVillageEnglish,
    required this.farmerCity,
    this.farmerCityEnglish,
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
    this.paymentMethodEnglish,
    this.deliveryNotes,
    this.deliveryNotesEnglish,
  });

  String getFarmerName(bool isUrdu) {
    if (isUrdu) return farmerName;
    return (farmerNameEnglish != null && farmerNameEnglish!.isNotEmpty)
        ? farmerNameEnglish!
        : farmerName;
  }

  String getFarmerCity(bool isUrdu) {
    if (isUrdu) return farmerCity;
    return (farmerCityEnglish != null && farmerCityEnglish!.isNotEmpty)
        ? farmerCityEnglish!
        : farmerCity;
  }

  String getFarmerVillage(bool isUrdu) {
    if (isUrdu) return farmerVillage;
    return (farmerVillageEnglish != null && farmerVillageEnglish!.isNotEmpty)
        ? farmerVillageEnglish!
        : farmerVillage;
  }

  String getFullLocation(bool isUrdu) {
    final v = getFarmerVillage(isUrdu);
    final c = getFarmerCity(isUrdu);
    return isUrdu ? "$v، $c" : "$v, $c";
  }

  String getProductName(bool isUrdu) => isUrdu ? productNameUrdu : productNameEnglish;
  String getPackUnit(bool isUrdu) => isUrdu ? packUnitUrdu : packUnitEnglish;

  String getPaymentMethod(bool isUrdu) {
    if (isUrdu) {
      return paymentMethod.replaceAll(RegExp(r'\([^)]*\)'), '').trim();
    }
    if (paymentMethodEnglish != null && paymentMethodEnglish!.isNotEmpty) {
      return paymentMethodEnglish!;
    }
    return paymentMethod.split('(').first.trim();
  }

  String? getDeliveryNotes(bool isUrdu) {
    if (isUrdu) return deliveryNotes;
    return deliveryNotesEnglish ?? deliveryNotes;
  }

  String getStatusLabel(bool isUrdu) {
    switch (status) {
      case DealerOrderStatus.pending:
        return isUrdu ? "نیا" : "Pending";
      case DealerOrderStatus.confirmed:
        return isUrdu ? "تصدیق شدہ" : "Confirmed";
      case DealerOrderStatus.dispatched:
        return isUrdu ? "روانہ" : "Dispatched";
      case DealerOrderStatus.completed:
        return isUrdu ? "ڈیلیورڈ" : "Delivered";
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
