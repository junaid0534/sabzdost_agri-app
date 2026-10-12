import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../core/config/api_config.dart';
import '../models/diagnostic_result.dart';

class CropDiseaseService {
  static const String _apiKey =
      String.fromEnvironment('GEMINI_API_KEY', defaultValue: ApiConfig.geminiApiKey);

  // Available Gemini vision models with automatic failover
  // Prioritizing high-availability & dedicated quota flash-lite and flash models
  static const List<String> _models = [
    "gemini-3.5-flash-lite",
    "gemini-3.1-flash-lite",
    "gemini-flash-lite-latest",
    "gemini-3-flash-preview",
    "gemini-3.5-flash",
    "gemini-3.7-flash",
  ];

  /// Real multimodal crop disease & leaf analysis via Gemini Vision API
  static Future<DiagnosticResult> analyzeCropImage(XFile imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final path = imageFile.path.toLowerCase();
    String mimeType = "image/jpeg";
    if (path.endsWith(".png")) {
      mimeType = "image/png";
    } else if (path.endsWith(".webp")) {
      mimeType = "image/webp";
    }

    const promptText = """
You are an expert Pakistani plant pathologist and agronomist.
Analyze this agricultural photo carefully.

VALIDATION CHECK:
If this image is clearly NOT an agricultural crop, leaf, plant, orchard, farm field, or pest (e.g. human face, indoor room, vehicle, computer screen, paper, random object), return JSON with:
{
  "isPlantOrCrop": false,
  "nonCropMessage": "یہ تصویر کسی فصل یا پودے کی نہیں ہے۔ برائے مہربانی کھیت میں متاثرہ پتے کی واضح تصویر بنائیں۔",
  "diseaseEnglish": "Not a Crop Leaf",
  "diseaseUrdu": "پودے کی تصویر نہیں ہے",
  "cropEnglish": "Unknown",
  "cropUrdu": "نامعلوم",
  "confidenceScore": 0.0,
  "severityLevel": "Invalid Photo",
  "symptomsEnglish": "No crop detected in photo.",
  "symptomsUrdu": "تصویر میں کوئی فصل یا پودا ظاہر نہیں ہوا۔",
  "treatmentEnglish": "Please take a photo of an agricultural crop in daylight.",
  "treatmentUrdu": "دن کی روشنی میں کھیت میں جا کر پودے یا پتے کی صاف تصویر بنائیں۔",
  "chemicalName": "N/A",
  "dosageEnglish": "N/A",
  "dosageUrdu": "N/A",
  "preventionEnglish": "N/A",
  "preventionUrdu": "N/A"
}

IF IT IS A CROP/PLANT (whether a close-up leaf, stem, or a full farm field):
Detect the crop (e.g. Wheat/گندم, Cotton/کپاس, Rice/چاول, Sugarcane/کماد, Maize/مکئی, Citrus/کینو, Mango/آم, Tomato/ٹماٹر, Potato/آلو, etc.).

Check health status:
Case A: If the crop is healthy with no clear disease/pest (e.g. vibrant green wheat field, normal growth):
{
  "isPlantOrCrop": true,
  "cropEnglish": "Wheat",
  "cropUrdu": "گندم",
  "diseaseEnglish": "Healthy Crop (No Disease Detected)",
  "diseaseUrdu": "صحت مند فصل (کوئی بیماری ظاہر نہیں ہوئی)",
  "confidenceScore": 98.0,
  "severityLevel": "Healthy • تندرست",
  "symptomsEnglish": "Crop shows vibrant green vegetative growth, healthy leaf canopy, and no active fungal rust or pest damage.",
  "symptomsUrdu": "فصل سرسبز و شاداب ہے اور معمول کے مطابق نشوونما پا رہی ہے۔ فی الحال کنگی، سست تیلے یا کسی بیماری کی علامات ظاہر نہیں ہوئیں۔",
  "treatmentEnglish": "No chemical pesticide spray required. Maintain timely irrigation and balanced fertilizer application.",
  "treatmentUrdu": "فی الحال کسی زہریلے اسپرے کی ضرورت نہیں۔ معمول کے مطابق پانی اور متوازن کھاد جاری رکھیں۔",
  "chemicalName": "N/A",
  "dosageEnglish": "None required",
  "dosageUrdu": "اسپرے کی ضرورت نہیں",
  "preventionEnglish": "Scout field weekly for rust (کنگی) or aphids, and maintain weed-free watercourses.",
  "preventionUrdu": "ہفتہ وار بنیاد پر کنگی اور سست تیلے کا معائنہ کرتے رہیں اور کھیت کو جڑی بوٹیوں سے پاک رکھیں۔"
}

Case B: If disease, pest, or deficiency IS detected:
{
  "isPlantOrCrop": true,
  "cropEnglish": "Crop name in English",
  "cropUrdu": "فصل کا نام اردو میں",
  "diseaseEnglish": "Accurate disease or pest name in English (e.g. Yellow Rust)",
  "diseaseUrdu": "بیماری یا کیڑے کا مستند اردو نام (مثلاً پیلی کنگی / رسٹ)",
  "confidenceScore": 95.0,
  "severityLevel": "High Risk • زیادہ خطرہ",
  "symptomsEnglish": "Clear symptoms description in English",
  "symptomsUrdu": "علامات کی مکمل اور آسان اردو تفصیل",
  "treatmentEnglish": "Actionable treatment and spray instructions in English",
  "treatmentUrdu": "کسان کے لیے فوری قابل عمل زرعی اسپرے اور تدابیر اردو میں",
  "chemicalName": "Pesticide active ingredient (e.g. Tebuconazole / Azoxystrobin / Emamectin)",
  "dosageEnglish": "Accurate dose per acre (e.g. 200 ml per acre in 100L clean water)",
  "dosageUrdu": "فی ایکڑ مقدار اردو میں (مثلاً ۲۰۰ ملی لیٹر فی ایکڑ ۱۰۰ لیٹر صاف پانی میں ملا کر اسپرے کریں)",
  "preventionEnglish": "Preventative cultural practices in English",
  "preventionUrdu": "آئندہ بچاؤ کی تدابیر اردو میں"
}

MANDATORY: Return valid JSON matching the exact structure above. All Urdu fields MUST be written in natural Pakistani Urdu.
Return ONLY valid JSON.
""";

    final requestBody = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": promptText},
            {
              "inline_data": {
                "mime_type": mimeType,
                "data": base64Image,
              }
            }
          ]
        }
      ],
      "generationConfig": {
        "response_mime_type": "application/json",
        "temperature": 0.2,
      }
    });

    String lastError = "Unknown error";

    // Try available models with automatic fallback
    for (final model in _models) {
      try {
        final endpoint =
            "https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$_apiKey";
        final response = await http
            .post(
              Uri.parse(endpoint),
              headers: {"Content-Type": "application/json"},
              body: requestBody,
            )
            .timeout(const Duration(seconds: 20));

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          final candidates = decoded["candidates"] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final text =
                candidates[0]["content"]["parts"][0]["text"] as String;
            final jsonResult = jsonDecode(text) as Map<String, dynamic>;
            return DiagnosticResult.fromJson(jsonResult);
          }
        } else {
          lastError = "Model $model returned HTTP ${response.statusCode}: ${response.body}";
          if (kDebugMode) {
            print("CropDiseaseService: $lastError");
          }
        }
      } catch (e) {
        lastError = "Model $model threw exception: $e";
        if (kDebugMode) {
          print("CropDiseaseService: $lastError");
        }
      }
    }

    throw Exception("Failed to analyze image across all AI models: $lastError");
  }
}
