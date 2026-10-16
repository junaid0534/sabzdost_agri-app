import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class SmartCorrectionResult {
  final String original;
  final String correctedUrdu;
  final String correctedEnglish;
  final List<String> searchKeywords;
  final String detectedIntent; // 'machinery', 'mandi', 'doctor', 'ledger', 'general'
  final String explanation;

  const SmartCorrectionResult({
    required this.original,
    required this.correctedUrdu,
    required this.correctedEnglish,
    required this.searchKeywords,
    required this.detectedIntent,
    required this.explanation,
  });

  factory SmartCorrectionResult.fallback(String input) {
    final normalized = input.trim();
    final lower = normalized.toLowerCase();

    // Built-in heuristic dictionary for common Pakistani agricultural terms in Roman Urdu
    String urdu = normalized;
    String english = normalized;
    String intent = "general";
    final List<String> keywords = [lower];

    if (lower.contains("tractor") || lower.contains("taractor") || lower.contains("traktar") || lower.contains("millat") || lower.contains("massey") || lower.contains("fiat") || lower.contains("385") || lower.contains("240") || lower.contains("640")) {
      urdu = "زرعی ٹریکٹر";
      english = "Agricultural Tractor";
      intent = "machinery";
      keywords.addAll(["tractor", "ٹریکٹر", "millat", "massey", "fiat", "385", "640", "machinery"]);
    } else if (lower.contains("harvester") || lower.contains("harwester") || lower.contains("katai") || lower.contains("kattaye") || lower.contains("claas")) {
      urdu = "کمبائن ہارویسٹر (کٹائی مشین)";
      english = "Combine Harvester";
      intent = "machinery";
      keywords.addAll(["harvester", "ہارویسٹر", "کٹائی", "claas", "combine", "machinery"]);
    } else if (lower.contains("laser") || lower.contains("leveler") || lower.contains("lawaler") || lower.contains("karah")) {
      urdu = "لیزر لینڈ لیولر";
      english = "Laser Land Leveler";
      intent = "machinery";
      keywords.addAll(["laser", "leveler", "لیزر", "لیولر", "machinery"]);
    } else if (lower.contains("drone") || lower.contains("dron") || lower.contains("spray") || lower.contains("dji")) {
      urdu = "زرعی سپرے ڈرون";
      english = "Agri Spray Drone";
      intent = "machinery";
      keywords.addAll(["drone", "spray", "ڈرون", "سپرے", "agras", "machinery"]);
    } else if (lower.contains("rotavator") || lower.contains("roter") || lower.contains("plow") || lower.contains("hal")) {
      urdu = "روٹاویٹر و ہل";
      english = "Rotavator / Plow";
      intent = "machinery";
      keywords.addAll(["rotavator", "روٹاویٹر", "ہل", "plow", "machinery"]);
    } else if (lower.contains("thresher") || lower.contains("thesher") || lower.contains("sheller")) {
      urdu = "تھریشر و شیلر";
      english = "Thresher / Sheller";
      intent = "machinery";
      keywords.addAll(["thresher", "تھریشر", "شیلر", "sheller", "machinery"]);
    } else if (lower.contains("baler") || lower.contains("bailer") || lower.contains("parali") || lower.contains("gathi")) {
      urdu = "سٹرا بیلر (پُرالی گٹھیں)";
      english = "Straw Baler";
      intent = "machinery";
      keywords.addAll(["baler", "بیلر", "پُرالی", "گٹھی", "straw", "machinery"]);
    } else if (lower.contains("gandum") || lower.contains("gandm") || lower.contains("wheat") || lower.contains("kanak") || lower.contains("gehun")) {
      urdu = "گندم (کنک)";
      english = "Wheat (Gandum)";
      intent = "mandi";
      keywords.addAll(["wheat", "gandum", "گندم", "کنک", "mandi", "غلہ"]);
    } else if (lower.contains("makki") || lower.contains("maki") || lower.contains("corn") || lower.contains("maize") || lower.contains("chhalli")) {
      urdu = "مکئی (چھلی)";
      english = "Maize / Corn";
      intent = "mandi";
      keywords.addAll(["corn", "maize", "makki", "مکئی", "چھلی", "mandi", "غلہ"]);
    } else if (lower.contains("chawal") || lower.contains("dhan") || lower.contains("rice") || lower.contains("munji") || lower.contains("monji") || lower.contains("basmati")) {
      urdu = "باسمتی چاول / دھان";
      english = "Basmati Rice / Paddy";
      intent = "mandi";
      keywords.addAll(["rice", "paddy", "chawal", "چاول", "دھان", "مونجی", "باسmati", "mandi"]);
    } else if (lower.contains("kapas") || lower.contains("phutti") || lower.contains("cotton")) {
      urdu = "کپاس (پھٹی)";
      english = "Raw Cotton / Phutti";
      intent = "mandi";
      keywords.addAll(["cotton", "kapas", "phutti", "کپاس", "پھٹی", "mandi"]);
    } else if (lower.contains("tamatar") || lower.contains("tomato") || lower.contains("tmatar")) {
      urdu = "تازہ ٹماٹر";
      english = "Fresh Tomatoes";
      intent = "mandi";
      keywords.addAll(["tomato", "tamatar", "ٹماٹر", "mandi", "سبزی"]);
    } else if (lower.contains("pyaz") || lower.contains("piaz") || lower.contains("onion")) {
      urdu = "پیاز";
      english = "Onion";
      intent = "mandi";
      keywords.addAll(["onion", "pyaz", "پیاز", "mandi", "سبزی"]);
    } else if (lower.contains("aloo") || lower.contains("aalo") || lower.contains("potato") || lower.contains("patato")) {
      urdu = "آلو";
      english = "Potato";
      intent = "mandi";
      keywords.addAll(["potato", "aloo", "آلو", "mandi", "سبزی"]);
    } else if (lower.contains("sarson") || lower.contains("sarsoon") || lower.contains("mustard") || lower.contains("canola") || lower.contains("raya")) {
      urdu = "سرسوں / کینولا";
      english = "Mustard / Canola";
      intent = "mandi";
      keywords.addAll(["mustard", "sarson", "canola", "raya", "سرسوں", "کینولا", "mandi"]);
    } else if (lower.contains("kamad") || lower.contains("ganna") || lower.contains("sugarcane") || lower.contains("sugar")) {
      urdu = "کماد / گنا";
      english = "Sugarcane";
      intent = "mandi";
      keywords.addAll(["sugarcane", "kamad", "ganna", "کماد", "گنا", "mandi"]);
    } else if (lower.contains("khad") || lower.contains("uria") || lower.contains("urea") || lower.contains("dap") || lower.contains("fertilizer")) {
      urdu = "سونا یوریا / ڈی اے پی کھاد";
      english = "Urea / DAP Fertilizer";
      intent = "mandi";
      keywords.addAll(["fertilizer", "urea", "dap", "khad", "کھاد", "یوریا"]);
    } else if (lower.contains("keera") || lower.contains("keeda") || lower.contains("bimari") || lower.contains("sundhi") || lower.contains("sundi") || lower.contains("pest") || lower.contains("fungus")) {
      urdu = "فصل کا کیڑا اور بیماری";
      english = "Crop Pest and Disease";
      intent = "doctor";
      keywords.addAll(["pest", "disease", "keera", "کیڑا", "بیماری", "سنڈی"]);
    } else if (lower.contains("khata") || lower.contains("hisaab") || lower.contains("hisab") || lower.contains("karza") || lower.contains("udhaar") || lower.contains("udhar")) {
      urdu = "کسان کھاتہ اور ادھار";
      english = "Farm Ledger & Balance";
      intent = "ledger";
      keywords.addAll(["khata", "ledger", "کھاتہ", "ادھار", "حساب"]);
    }

    return SmartCorrectionResult(
      original: input,
      correctedUrdu: urdu,
      correctedEnglish: english,
      searchKeywords: keywords.toSet().toList(),
      detectedIntent: intent,
      explanation: "آٹو فکسڈ زرعی ان پٹ",
    );
  }
}

class GeminiSmartInputService {
  static const String _geminiApiKey =
      String.fromEnvironment('GEMINI_API_KEY', defaultValue: ApiConfig.geminiApiKey);
  static const String _model = "gemini-2.5-flash-lite";
  static const String _geminiEndpoint =
      "https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_geminiApiKey";

  // In-memory cache for instant subsequent lookups
  static final Map<String, SmartCorrectionResult> _correctionCache = {};

  /// Corrects Roman Urdu, misspelled text, or broken queries into authentic Urdu and English
  static Future<SmartCorrectionResult> correctAndTranslate(
    String rawInput, {
    String? domainContext,
  }) async {
    final query = rawInput.trim();
    if (query.isEmpty) {
      return SmartCorrectionResult(
        original: "",
        correctedUrdu: "",
        correctedEnglish: "",
        searchKeywords: [],
        detectedIntent: "general",
        explanation: "",
      );
    }

    final cacheKey = query.toLowerCase();
    if (_correctionCache.containsKey(cacheKey)) {
      return _correctionCache[cacheKey]!;
    }

    try {
      final prompt = """
You are an intelligent bilingual assistant for Pakistani farmers and agriculture in the "SabzDost" app.
The user typed the following input which might be in phonetic Roman Urdu (e.g., "gandum k liay tractor chahye", "makki ka beej", "tamatar ka bhao", "haria keeda"), broken English, misspelled words, or Urdu script:
"$query"

${domainContext != null ? 'Context / Domain hint: $domainContext' : ''}

Your tasks:
1. Autocorrect any typing, spelling, or phonetic mistakes.
2. Produce "corrected_ur": The authentic, natural, correctly spelled Urdu text in Urdu/Nastaliq script.
3. Produce "corrected_en": Professional, clear, concise English translation of what the user wants.
4. Produce "keywords": Array of 3 to 7 relevant search keywords (including Urdu words, English words, and Roman synonyms).
5. Detect "intent": one of ["machinery", "mandi", "doctor", "ledger", "general"].
6. Produce "explanation": A very short explanation (e.g. "گندم کے لیے ٹریکٹر کی تلاش" or "Wheat tractor search").

Return ONLY a valid JSON object with keys:
{
  "corrected_ur": "...",
  "corrected_en": "...",
  "keywords": ["...", "..."],
  "intent": "...",
  "explanation": "..."
}
""";

      final requestBody = jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ],
        "generationConfig": {
          "response_mime_type": "application/json",
          "temperature": 0.2,
        }
      });

      final response = await http
          .post(
            Uri.parse(_geminiEndpoint),
            headers: {"Content-Type": "application/json"},
            body: requestBody,
          )
          .timeout(const Duration(seconds: 7));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final candidates = decoded["candidates"] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates.first["content"];
          final parts = content["parts"] as List?;
          if (parts != null && parts.isNotEmpty) {
            final jsonText = parts.first["text"] as String?;
            if (jsonText != null && jsonText.isNotEmpty) {
              final Map<String, dynamic> data = jsonDecode(jsonText);
              final List<dynamic>? rawKw = data["keywords"] as List<dynamic>?;
              final keywords = rawKw != null
                  ? rawKw.map((e) => e.toString().toLowerCase()).toList()
                  : <String>[query.toLowerCase()];

              final result = SmartCorrectionResult(
                original: query,
                correctedUrdu: (data["corrected_ur"] ?? query).toString().trim(),
                correctedEnglish: (data["corrected_en"] ?? query).toString().trim(),
                searchKeywords: keywords,
                detectedIntent: (data["intent"] ?? "general").toString().trim(),
                explanation: (data["explanation"] ?? "").toString().trim(),
              );

              _correctionCache[cacheKey] = result;
              return result;
            }
          }
        }
      }
    } catch (e) {
      debugPrint("GeminiSmartInputService fallback activated: $e");
    }

    // Fallback heuristic if API timed out or network error
    final fallbackResult = SmartCorrectionResult.fallback(query);
    _correctionCache[cacheKey] = fallbackResult;
    return fallbackResult;
  }
}
