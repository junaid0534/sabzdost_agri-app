import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../core/config/api_config.dart';
import '../models/diagnostic_result.dart';

class CropDiseaseService {
  static const String _apiKey =
      String.fromEnvironment('GEMINI_API_KEY', defaultValue: ApiConfig.geminiApiKey);
  static const String _model = "gemini-3.8-flash";
  static const String _endpoint =
      "https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey";

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
Analyze this image carefully.
Detect the crop (e.g. Cotton/کپاس, Wheat/گندم, Rice/چاول, Sugarcane/کماد, Maize/مکئی, Tomato/ٹماٹر, Potato/آلو, Citrus/کینو, Mango/آم, etc.) and diagnose any disease, pest, or deficiency. If healthy, report as healthy.

VALIDATION CHECK:
If this image is NOT an agricultural plant, leaf, crop, fruit, or pest (e.g. human, computer screen, paper, room, car, animal, random object), return JSON with:
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
  "treatmentEnglish": "Please take a close-up photo of an affected crop leaf in good daylight.",
  "treatmentUrdu": "دن کی روشنی میں بیمار پتے کے قریب جا کر صاف تصویر بنائیں۔",
  "chemicalName": "N/A",
  "dosageEnglish": "N/A",
  "dosageUrdu": "N/A",
  "preventionEnglish": "N/A",
  "preventionUrdu": "N/A"
}

IF IT IS A CROP/PLANT, return JSON with:
{
  "isPlantOrCrop": true,
  "cropEnglish": "Crop name in English (e.g. Cotton)",
  "cropUrdu": "فصل کا نام اردو میں (مثلاً کپاس)",
  "diseaseEnglish": "Accurate disease or pest name in English (e.g. Pink Bollworm)",
  "diseaseUrdu": "بیماری یا کیڑے کا مستند اردو نام (مثلاً گلابی سنڈی کا حملہ)",
  "confidenceScore": 96.5,
  "severityLevel": "High Risk • زیادہ خطرہ",
  "symptomsEnglish": "Clear symptoms description in English",
  "symptomsUrdu": "علامات کی مکمل اور آسان اردو تفصیل (مثلاً پتے پر بھورے دھبے، جڑ کا گلنا، وغیرہ)",
  "treatmentEnglish": "Actionable treatment and spray instructions in English",
  "treatmentUrdu": "کسان کے لیے فوری قابل عمل زرعی اسپرے اور تدابیر اردو میں",
  "chemicalName": "Pesticide active ingredient or brand name (e.g. Emamectin Benzoate 5% SG / Lambda-Cyhalothrin)",
  "dosageEnglish": "Accurate dose per acre in English (e.g. 200 ml per acre in 100L clean water)",
  "dosageUrdu": "فی ایکڑ مقدار اردو میں (مثلاً ۲۰۰ ملی لیٹر فی ایکڑ ۱۰۰ لیٹر صاف پانی میں ملا کر اسپرے کریں)",
  "preventionEnglish": "Preventative cultural practices in English",
  "preventionUrdu": "آئندہ بچاؤ کی تدابیر اردو میں (مثلاً کھیت کی صفائی، فیرومون ٹریپس، متوازن کھاد)"
}
MANDATORY: All Urdu fields MUST be written in natural, fluent Pakistani Urdu. Do not leave Urdu fields blank.
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

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {"Content-Type": "application/json"},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final candidates = decoded["candidates"] as List?;
      if (candidates != null && candidates.isNotEmpty) {
        final text = candidates[0]["content"]["parts"][0]["text"] as String;
        final jsonResult = jsonDecode(text) as Map<String, dynamic>;
        return DiagnosticResult.fromJson(jsonResult);
      }
    }

    throw Exception(
      "Failed to analyze image (Status: ${response.statusCode}): ${response.body}",
    );
  }
}
