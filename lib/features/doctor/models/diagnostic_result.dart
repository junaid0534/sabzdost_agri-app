class DiagnosticResult {
  final String diseaseEnglish;
  final String diseaseUrdu;
  final String cropEnglish;
  final String cropUrdu;
  final double confidenceScore;
  final String severityLevel; // High, Medium, Low
  final String symptomsEnglish;
  final String symptomsUrdu;
  final String treatmentEnglish;
  final String treatmentUrdu;
  final String chemicalName;
  final String dosageEnglish;
  final String dosageUrdu;
  final String preventionEnglish;
  final String preventionUrdu;
  final bool isPlantOrCrop;
  final String? nonCropMessage;

  const DiagnosticResult({
    required this.diseaseEnglish,
    required this.diseaseUrdu,
    required this.cropEnglish,
    required this.cropUrdu,
    required this.confidenceScore,
    required this.severityLevel,
    required this.symptomsEnglish,
    required this.symptomsUrdu,
    required this.treatmentEnglish,
    required this.treatmentUrdu,
    required this.chemicalName,
    required this.dosageEnglish,
    required this.dosageUrdu,
    required this.preventionEnglish,
    required this.preventionUrdu,
    this.isPlantOrCrop = true,
    this.nonCropMessage,
  });

  factory DiagnosticResult.fromJson(Map<String, dynamic> json) {
    return DiagnosticResult(
      isPlantOrCrop: json['isPlantOrCrop'] as bool? ?? true,
      nonCropMessage: json['nonCropMessage'] as String?,
      diseaseEnglish: json['diseaseEnglish'] as String? ?? 'Plant Disease',
      diseaseUrdu: json['diseaseUrdu'] as String? ?? 'فصل کی بیماری',
      cropEnglish: json['cropEnglish'] as String? ?? 'Crop',
      cropUrdu: json['cropUrdu'] as String? ?? 'فصل',
      confidenceScore: (json['confidenceScore'] is num)
          ? (json['confidenceScore'] as num).toDouble()
          : 95.0,
      severityLevel: json['severityLevel'] as String? ?? 'High Risk • زیادہ خطرہ',
      symptomsEnglish: json['symptomsEnglish'] as String? ?? '',
      symptomsUrdu: json['symptomsUrdu'] as String? ?? '',
      treatmentEnglish: json['treatmentEnglish'] as String? ?? '',
      treatmentUrdu: json['treatmentUrdu'] as String? ?? '',
      chemicalName: json['chemicalName'] as String? ?? '',
      dosageEnglish: json['dosageEnglish'] as String? ?? '',
      dosageUrdu: json['dosageUrdu'] as String? ?? '',
      preventionEnglish: json['preventionEnglish'] as String? ?? '',
      preventionUrdu: json['preventionUrdu'] as String? ?? '',
    );
  }

  static DiagnosticResult get sampleResult => const DiagnosticResult(
        diseaseEnglish: "Pink Bollworm Infestation",
        diseaseUrdu: "گلابی سنڈی کا حملہ",
        cropEnglish: "Cotton",
        cropUrdu: "کپاس",
        confidenceScore: 98.4,
        severityLevel: "High Risk • زیادہ خطرہ",
        symptomsEnglish:
            "Holes bored into cotton bolls, damaged lint, and stunted growth.",
        symptomsUrdu:
            "کپاس کے ٹینڈوں میں سوراخ، روئی کا اندر سے کالا ہونا اور پھولوں کا گرنا۔",
        treatmentEnglish:
            "Apply recommended insecticide spray immediately during evening hours.",
        treatmentUrdu:
            "ایما مRelevant یا لیمبڈا سائہیلوتھرین کا شام کے وقت یکساں اسپرے کریں۔",
        chemicalName: "Emamectin Benzoate 5% SG / Lambda-Cyhalothrin",
        dosageEnglish: "200 ml per acre with 100L clean water",
        dosageUrdu: "۲۰۰ ملی لیٹر فی ایکڑ (۱۰۰ لیٹر صاف پانی میں ملا کر)",
        preventionEnglish:
            "Install pheromone traps in the field and destroy affected bolls.",
        preventionUrdu:
            "کھیت میں فیرومون ٹریپس لگائیں اور متاثرہ ٹینڈے چن کر تلف کر دیں۔",
      );
}
