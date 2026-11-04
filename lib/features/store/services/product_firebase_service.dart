import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../core/services/firebase_service.dart';
import '../models/agri_product_model.dart';

/// Realtime Firebase Firestore Service for Products.
/// Manages the 'products' collection with live streaming and safe fallback.
class ProductFirebaseService {
  ProductFirebaseService._();
  static final ProductFirebaseService instance = ProductFirebaseService._();

  static const String _collectionName = 'products';

  // In-memory cache & fallback when offline or in test environments
  final List<AgriProductModel> _cachedProducts = [];
  bool _seeded = false;

  List<AgriProductModel> get cachedProducts => List.unmodifiable(_cachedProducts);

  /// Default initial curated products
  static final List<AgriProductModel> defaultInitialProducts = [
    const AgriProductModel(
      id: "prod-1",
      nameEnglish: "Akbar-19 Wheat",
      nameUrdu: "اکبر ۱۹ گندم بیج",
      category: AgriProductCategory.seeds,
      companyEnglish: "Punjab Seed Corp",
      companyUrdu: "پنجاب سیڈ",
      packSizeEnglish: "50 kg Bag",
      packSizeUrdu: "۵۰ کلو بوری",
      price: 5200,
      originalPrice: 5600,
      rating: 4.9,
      reviewsCount: 184,
      inStock: true,
      descriptionEnglish: "Certified wheat seed, 95% germination rate, rust-resistant.",
      descriptionUrdu: "پنجاب حکومت سے تصدیق شدہ گندم کا بیج، ۹۵ فیصد شرح اگاؤ۔",
      dosageEnglish: "50 kg per acre",
      dosageUrdu: "۵۰ کلو فی ایکڑ",
      targetEnglish: "Rust Resistant",
      targetUrdu: "زنگ سے محفوظ",
      dealerNameEnglish: "Chaudhry Agri Store",
      dealerNameUrdu: "چوہدری ایگرو سینٹر",
      dealerPhone: "0300-8472910",
      dealerLocationEnglish: "Grain Market, Multan",
      dealerLocationUrdu: "غلہ منڈی، ملتان",
      imageUrl: "https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?q=80&w=400&auto=format&fit=crop",
    ),
    const AgriProductModel(
      id: "prod-2",
      nameEnglish: "Pioneer 30Y87 Corn",
      nameUrdu: "پائنیر ۳۰Y۸۷ مکئی",
      category: AgriProductCategory.seeds,
      companyEnglish: "Corteva Agriscience",
      companyUrdu: "کورٹیوا",
      packSizeEnglish: "8 kg Bag",
      packSizeUrdu: "۸ کلو بیگ",
      price: 14500,
      originalPrice: 15200,
      rating: 5.0,
      reviewsCount: 220,
      inStock: true,
      descriptionEnglish: "Pakistan's top-selling silage and grain corn hybrid.",
      descriptionUrdu: "پاکستان میں سب سے زیادہ بکنے والی مکئی، بہترین سائیلج۔",
      dosageEnglish: "8 kg per acre",
      dosageUrdu: "۸ کلو فی ایکڑ",
      targetEnglish: "Silage & Grain",
      targetUrdu: "سائیلج و دانہ",
      dealerNameEnglish: "Chaudhry Agri Store",
      dealerNameUrdu: "چوہدری ایگرو سینٹر",
      dealerPhone: "0300-8472910",
      dealerLocationEnglish: "Grain Market, Multan",
      dealerLocationUrdu: "غلہ منڈی، ملتان",
      imageUrl: "https://images.unsplash.com/photo-1551754655-cd27e38d2076?q=80&w=400&auto=format&fit=crop",
    ),
    const AgriProductModel(
      id: "prod-3",
      nameEnglish: "FH-333 BT Cotton",
      nameUrdu: "کپاس FH-333",
      category: AgriProductCategory.seeds,
      companyEnglish: "Four Brothers Agri",
      companyUrdu: "فور برادرز",
      packSizeEnglish: "40 kg Pack",
      packSizeUrdu: "۴۰ کلو تھیلا",
      price: 8400,
      originalPrice: 8900,
      rating: 4.8,
      reviewsCount: 96,
      inStock: true,
      descriptionEnglish: "Triple-gene BT cotton seed with resistance to bollworms.",
      descriptionUrdu: "امریکن اور گلابی سنڈی کے خلاف زبردست قوت مدافعت۔",
      dosageEnglish: "8 to 10 kg per acre",
      dosageUrdu: "۸ تا ۱۰ کلو فی ایکڑ",
      targetEnglish: "Bollworm Resistance",
      targetUrdu: "سنڈی سے مدافعت",
      dealerNameEnglish: "Chaudhry Agri Store",
      dealerNameUrdu: "چوہدری ایگرو سینٹر",
      dealerPhone: "0300-8472910",
      dealerLocationEnglish: "Grain Market, Multan",
      dealerLocationUrdu: "غلہ منڈی، ملتان",
      imageUrl: "https://images.unsplash.com/photo-1600651215852-9d3bf0765709?q=80&w=400&auto=format&fit=crop",
    ),
    const AgriProductModel(
      id: "prod-4",
      nameEnglish: "Guard Super Basmati",
      nameUrdu: "گارڈ سپر باسمتی",
      category: AgriProductCategory.seeds,
      companyEnglish: "Guard Agri Research",
      companyUrdu: "گارڈ ایگری",
      packSizeEnglish: "20 kg Bag",
      packSizeUrdu: "۲۰ کلو بوری",
      price: 6800,
      originalPrice: 7200,
      rating: 4.7,
      reviewsCount: 88,
      inStock: true,
      descriptionEnglish: "Authentic long-grain aromatic Basmati rice seed.",
      descriptionUrdu: "خوشبودار لمبے دانے والا سپر باسمتی چاول بیج۔",
      dosageEnglish: "5 kg nursery / acre",
      dosageUrdu: "۵ کلو پنیری فی ایکڑ",
      targetEnglish: "Export Aroma",
      targetUrdu: "ایکسپورٹ خوشبو",
      dealerNameEnglish: "Chaudhry Agri Store",
      dealerNameUrdu: "چوہدری ایگرو سینٹر",
      dealerPhone: "0300-8472910",
      dealerLocationEnglish: "Grain Market, Multan",
      dealerLocationUrdu: "غلہ منڈی، ملتان",
      imageUrl: "https://images.unsplash.com/photo-1586201375761-83865001e31c?q=80&w=400&auto=format&fit=crop",
    ),
    const AgriProductModel(
      id: "prod-5",
      nameEnglish: "FFC Sona Urea 46%",
      nameUrdu: "سونا یوریا کھاد",
      category: AgriProductCategory.fertilizers,
      companyEnglish: "Fauji Fertilizer (FFC)",
      companyUrdu: "فوجی فرٹیلائزر",
      packSizeEnglish: "50 kg Bag",
      packSizeUrdu: "۵۰ کلو بوری",
      price: 4400,
      originalPrice: 4400,
      rating: 4.9,
      reviewsCount: 310,
      inStock: true,
      descriptionEnglish: "Standard prilled white urea with 46% Nitrogen for lush growth.",
      descriptionUrdu: "۴۶ فیصد نائٹروجن، پودے کی فوری نشوونما اور سبز رنگ کیلئے۔",
      dosageEnglish: "1 to 2 bags per acre",
      dosageUrdu: "۱ تا ۲ بوری فی ایکڑ",
      targetEnglish: "Vegetative Growth",
      targetUrdu: "بھرپور بڑھوتری",
      dealerNameEnglish: "Chaudhry Agri Store",
      dealerNameUrdu: "چوہدری ایگرو سینٹر",
      dealerPhone: "0300-8472910",
      dealerLocationEnglish: "Grain Market, Multan",
      dealerLocationUrdu: "غلہ منڈی، ملتان",
      imageUrl: "https://images.unsplash.com/photo-1585314062340-f1a5a7c9328d?q=80&w=400&auto=format&fit=crop",
    ),
    const AgriProductModel(
      id: "prod-6",
      nameEnglish: "Engro DAP Fertilizer",
      nameUrdu: "اینگرو ڈی اے پی",
      category: AgriProductCategory.fertilizers,
      companyEnglish: "Engro Fertilizers Ltd",
      companyUrdu: "اینگرو فرٹیلائزرز",
      packSizeEnglish: "50 kg Bag",
      packSizeUrdu: "۵۰ کلو بوری",
      price: 12800,
      originalPrice: 13200,
      rating: 5.0,
      reviewsCount: 245,
      inStock: true,
      descriptionEnglish: "18% Nitrogen and 46% Phosphorus for strong root establishment.",
      descriptionUrdu: "۱۸ فیصد نائٹروجن اور ۴۶ فیصد فاسفورس، مضبوط جڑوں کیلئے۔",
      dosageEnglish: "1 bag per acre at sowing",
      dosageUrdu: "۱ بوری فی ایکڑ بوقت بوائی",
      targetEnglish: "Root Development",
      targetUrdu: "مضبوط جڑیں",
      dealerNameEnglish: "Chaudhry Agri Store",
      dealerNameUrdu: "چوہدری ایگرو سینٹر",
      dealerPhone: "0300-8472910",
      dealerLocationEnglish: "Grain Market, Multan",
      dealerLocationUrdu: "غلہ منڈی، ملتان",
      imageUrl: "https://images.unsplash.com/photo-1628352081506-83c43123ed6d?q=80&w=400&auto=format&fit=crop",
    ),
    const AgriProductModel(
      id: "prod-7",
      nameEnglish: "Confidor 200 SL",
      nameUrdu: "کونفیڈور ۲۰۰ ایس ایل",
      category: AgriProductCategory.sprays,
      companyEnglish: "Bayer CropScience",
      companyUrdu: "بائر کراپ سائنس",
      packSizeEnglish: "250 ml Bottle",
      packSizeUrdu: "۲۵۰ ملی لیٹر بوتل",
      price: 2450,
      originalPrice: 2600,
      rating: 4.9,
      reviewsCount: 160,
      inStock: true,
      descriptionEnglish: "Systemic insecticide for aphid, jassid and whitefly control.",
      descriptionUrdu: "سفید مکھی، سست تیلہ اور تھرپس کے خلاف موثر نظامی زہر۔",
      dosageEnglish: "250 ml per acre",
      dosageUrdu: "۲۵۰ ملی لیٹر فی ایکڑ",
      targetEnglish: "Sucking Pests",
      targetUrdu: "رس چوسنے والے کیڑے",
      dealerNameEnglish: "Chaudhry Agri Store",
      dealerNameUrdu: "چوہدری ایگرو سینٹر",
      dealerPhone: "0300-8472910",
      dealerLocationEnglish: "Grain Market, Multan",
      dealerLocationUrdu: "غلہ منڈی، ملتان",
      imageUrl: "https://images.unsplash.com/photo-1597848212624-a19eb35e2651?q=80&w=400&auto=format&fit=crop",
    ),
    const AgriProductModel(
      id: "prod-8",
      nameEnglish: "Belt Expert 480 SC",
      nameUrdu: "بیلٹ ایکسپرٹ ۴۸۰ ایس سی",
      category: AgriProductCategory.sprays,
      companyEnglish: "Bayer CropScience",
      companyUrdu: "بائر کراپ سائنس",
      packSizeEnglish: "100 ml Pack",
      packSizeUrdu: "۱۰۰ ملی لیٹر پیک",
      price: 3350,
      originalPrice: 3500,
      rating: 5.0,
      reviewsCount: 142,
      inStock: true,
      descriptionEnglish: "Broad-spectrum control against armyworm and bollworms.",
      descriptionUrdu: "لشکری اور امریکی سنڈی کے فوری خاتمے کے لیے جدید زہر۔",
      dosageEnglish: "100 ml per acre",
      dosageUrdu: "۱۰۰ ملی لیٹر فی ایکڑ",
      targetEnglish: "Caterpillar & Worms",
      targetUrdu: "سنڈیاں و کیڑے",
      dealerNameEnglish: "Chaudhry Agri Store",
      dealerNameUrdu: "چوہدری ایگرو سینٹر",
      dealerPhone: "0300-8472910",
      dealerLocationEnglish: "Grain Market, Multan",
      dealerLocationUrdu: "غلہ منڈی، ملتان",
      imageUrl: "https://images.unsplash.com/photo-1615485290382-441e4d049cb5?q=80&w=400&auto=format&fit=crop",
    ),
  ];

  void _ensureInitializedCache() {
    if (_cachedProducts.isEmpty) {
      _cachedProducts.addAll(defaultInitialProducts);
    }
  }

  /// Realtime Stream of Products from Firebase Firestore 'products' collection.
  Stream<List<AgriProductModel>> streamProducts() {
    _ensureInitializedCache();

    if (!FirebaseService.isInitialized) {
      return Stream.value(List.from(_cachedProducts));
    }

    try {
      final collection = FirebaseFirestore.instance.collection(_collectionName);

      // Seed if necessary in background
      _seedDefaultProductsIfEmpty(collection);

      return collection
          .snapshots()
          .map((snapshot) {
            if (snapshot.docs.isEmpty) {
              return List<AgriProductModel>.from(_cachedProducts);
            }

            final list = snapshot.docs.map((doc) {
              return AgriProductModel.fromMap(doc.data(), doc.id);
            }).toList();

            // Update in-memory cache
            _cachedProducts.clear();
            _cachedProducts.addAll(list);

            return list;
          })
          .handleError((error) {
            debugPrint("Firestore products stream error: $error");
            return List<AgriProductModel>.from(_cachedProducts);
          });
    } catch (e) {
      debugPrint("Firestore stream initialization error: $e");
      return Stream.value(List.from(_cachedProducts));
    }
  }

  Future<void> _seedDefaultProductsIfEmpty(CollectionReference collection) async {
    if (_seeded) return;
    _seeded = true;

    try {
      final existing = await collection.limit(1).get();
      if (existing.docs.isEmpty) {
        final batch = FirebaseFirestore.instance.batch();
        for (final product in defaultInitialProducts) {
          final docRef = collection.doc(product.id);
          batch.set(docRef, product.toMap());
        }
        await batch.commit();
        debugPrint("Successfully seeded initial products into Firestore 'products' table.");
      }
    } catch (e) {
      debugPrint("Note on Firestore seeding: $e");
    }
  }

  /// Save or Publish a product in Realtime to Firebase Firestore.
  Future<void> saveProduct(AgriProductModel product) async {
    _ensureInitializedCache();

    // 1. Immediately update in-memory cache for instant UI response
    final idx = _cachedProducts.indexWhere((p) => p.id == product.id);
    if (idx != -1) {
      _cachedProducts[idx] = product;
    } else {
      _cachedProducts.insert(0, product);
    }

    // 2. Persist in Realtime Firebase Firestore 'products' collection
    if (FirebaseService.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection(_collectionName)
            .doc(product.id)
            .set(product.toMap(), SetOptions(merge: true));
        debugPrint("Product ${product.nameEnglish} (${product.id}) saved to Firebase Firestore 'products' table.");
      } catch (e) {
        debugPrint("Error writing product to Firestore: $e");
      }
    }
  }

  /// Toggle stock availability in Realtime Firebase.
  Future<void> toggleStock(String productId, bool inStock) async {
    _ensureInitializedCache();

    final idx = _cachedProducts.indexWhere((p) => p.id == productId);
    if (idx != -1) {
      _cachedProducts[idx] = _cachedProducts[idx].copyWith(inStock: inStock);
    }

    if (FirebaseService.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection(_collectionName)
            .doc(productId)
            .update({
              'inStock': inStock,
              'updatedAt': DateTime.now().millisecondsSinceEpoch,
            });
        debugPrint("Product stock updated in Firestore for $productId -> $inStock");
      } catch (e) {
        debugPrint("Error updating product stock in Firestore: $e");
      }
    }
  }

  /// Delete product from Firebase.
  Future<void> deleteProduct(String productId) async {
    _cachedProducts.removeWhere((p) => p.id == productId);

    if (FirebaseService.isInitialized) {
      try {
        await FirebaseFirestore.instance.collection(_collectionName).doc(productId).delete();
      } catch (e) {
        debugPrint("Error deleting product from Firestore: $e");
      }
    }
  }
}
