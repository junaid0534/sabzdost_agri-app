import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/localization/language_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../weather/models/weather_models.dart';
import '../../weather/services/weather_service.dart';
import '../models/diagnostic_result.dart';
import '../services/crop_disease_service.dart';

class CropDoctorScreen extends StatefulWidget {
  final bool? isUrdu;

  const CropDoctorScreen({super.key, this.isUrdu});

  @override
  State<CropDoctorScreen> createState() => _CropDoctorScreenState();
}

class _CropDoctorScreenState extends State<CropDoctorScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final FlutterTts _flutterTts = FlutterTts();
  XFile? _selectedImage;
  bool _isAnalyzing = false;
  bool _hasScanError = false;
  String? _scanErrorMessage;
  String _analysisStep = "";
  DiagnosticResult? _result;
  bool _isPlayingAudio = false;
  bool _resultInUrdu = true;
  SprayAdvisory? _sprayAdvisory;
  bool _isLoadingWeatherAdvisory = false;

  late AnimationController _scanController;
  late Animation<double> _scanAnimation;

  bool get _isUrdu => widget.isUrdu ?? LanguageController.instance.isUrdu;

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadWeatherAdvisory();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.1, end: 0.9).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );
  }

  void _initTts() {
    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isPlayingAudio = false);
    });
    _flutterTts.setCancelHandler(() {
      if (mounted) setState(() => _isPlayingAudio = false);
    });
    _flutterTts.setErrorHandler((_) {
      if (mounted) setState(() => _isPlayingAudio = false);
    });
  }

  void _loadWeatherAdvisory() async {
    if (_sprayAdvisory != null) return;
    setState(() => _isLoadingWeatherAdvisory = true);
    try {
      final report = await WeatherService.fetchWeather();
      if (mounted) {
        setState(() {
          _sprayAdvisory = report.sprayAdvisory;
          _isLoadingWeatherAdvisory = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingWeatherAdvisory = false);
      }
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (file != null) {
        setState(() {
          _selectedImage = file;
          _result = null;
          _hasScanError = false;
          _scanErrorMessage = null;
        });
        _runAiScan();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isUrdu
                ? "تصویر منتخب نہیں ہو سکی"
                : "Could not access camera or gallery",
            style: _isUrdu
                ? AppTheme.urdu(color: Colors.white, fontSize: 12)
                : AppTheme.english(color: Colors.white, fontSize: 12),
          ),
          backgroundColor: AppColors.alertSoftRed,
        ),
      );
    }
  }

  void _runAiScan() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
      _hasScanError = false;
      _scanErrorMessage = null;
      _analysisStep = _isUrdu
          ? "تصویر کا جائزہ لیا جا رہا ہے..."
          : "Analyzing your picture...";
    });

    try {
      final result = await CropDiseaseService.analyzeCropImage(_selectedImage!);
      if (!mounted) return;

      setState(() {
        _isAnalyzing = false;
        _hasScanError = false;
        _result = result;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _hasScanError = true;
        _scanErrorMessage = _isUrdu
            ? "انٹرنیٹ سست ہونے یا سرور رش کی وجہ سے اسکین مکمل نہ ہو سکا۔"
            : "Scan could not complete. Check internet and retry.";
      });
    }
  }

  void _toggleAudio() async {
    if (_result == null) return;

    if (_isPlayingAudio) {
      await _flutterTts.stop();
      if (mounted) {
        setState(() => _isPlayingAudio = false);
      }
      return;
    }

    final res = _result!;
    final isHealthy = res.diseaseEnglish.toLowerCase().contains("healthy") ||
        res.severityLevel.toLowerCase().contains("healthy") ||
        res.severityLevel.contains("محفوظ");

    String speechText = "";
    if (_resultInUrdu) {
      if (isHealthy) {
        speechText = "فصل: ${res.cropUrdu}۔ ماشاءاللہ آپ کی فصل صحت مند اور تندرست ہے۔ کسی زہریلے اسپرے کی ضرورت نہیں ہے۔ باقاعدہ آبپاشی اور مٹی میں نمی برقرار رکھیں۔";
      } else {
        final chem = (res.chemicalName.isNotEmpty && res.chemicalName != "N/A")
            ? "تجویز کردہ کیمیکل: ${res.chemicalName}۔ "
            : "";
        final dose = res.dosageUrdu.isNotEmpty ? "خوراک: ${res.dosageUrdu}۔ " : "";
        final treat = res.treatmentUrdu.isNotEmpty ? "علاج: ${res.treatmentUrdu}۔ " : "";
        final weather = _sprayAdvisory != null
            ? "موسمی الرٹ: ${_sprayAdvisory!.titleUrdu}۔ ${_sprayAdvisory!.reasonUrdu}۔ ${_sprayAdvisory!.bestWindowUrdu.isNotEmpty ? 'بہترین وقت: ${_sprayAdvisory!.bestWindowUrdu}۔' : ''}"
            : "";

        speechText = "فصل: ${res.cropUrdu}۔ بیماری: ${res.diseaseUrdu}۔ علامات: ${res.symptomsUrdu}۔ $chem$dose$treat$weather";
      }
    } else {
      if (isHealthy) {
        speechText = "Crop: ${res.cropEnglish}. Status: Healthy crop. No chemical spray required. Continue regular maintenance.";
      } else {
        final chem = (res.chemicalName.isNotEmpty && res.chemicalName != "N/A")
            ? "Recommended spray: ${res.chemicalName}. "
            : "";
        final dose = res.dosageEnglish.isNotEmpty ? "Dosage: ${res.dosageEnglish}. " : "";
        final treat = res.treatmentEnglish.isNotEmpty ? "Treatment: ${res.treatmentEnglish}. " : "";
        final weather = _sprayAdvisory != null
            ? "Weather note: ${_sprayAdvisory!.titleEnglish}. ${_sprayAdvisory!.reasonEnglish}."
            : "";

        speechText = "Crop: ${res.cropEnglish}. Disease: ${res.diseaseEnglish}. Symptoms: ${res.symptomsEnglish}. $chem$dose$treat$weather";
      }
    }

    setState(() => _isPlayingAudio = true);

    try {
      await _flutterTts.setLanguage(_resultInUrdu ? "ur-PK" : "en-US");
      await _flutterTts.setSpeechRate(0.42);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.speak(speechText);
    } catch (e) {
      if (mounted) {
        setState(() => _isPlayingAudio = false);
        final isMissingPlugin = e.toString().contains("MissingPluginException");
        final msg = isMissingPlugin
            ? (_resultInUrdu
                ? "نئے آڈیو فیچر کو چالو کرنے کے لیے ایپ کو ایک بار بند کر کے دوبارہ رن (Re-run) کریں۔"
                : "Please restart / re-run the app to activate native audio.")
            : (_resultInUrdu
                ? "صوتی رہنمائی چلانے میں دشواری پیش آئی۔"
                : "Could not play voice guidance.");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              msg,
              style: _resultInUrdu
                  ? AppTheme.urdu(fontSize: 12, color: Colors.white)
                  : AppTheme.english(fontSize: 12, color: Colors.white),
            ),
            backgroundColor: AppColors.primaryDark,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _isUrdu ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              color: AppColors.borderLight.withValues(alpha: 0.7),
              height: 1,
            ),
          ),
          title: Text(
            _isUrdu ? "اے آئی فصل ڈاکٹر" : "AI Crop Doctor",
            textAlign: TextAlign.center,
            style: _isUrdu
                ? AppTheme.urdu(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  )
                : AppTheme.english(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                    letterSpacing: -0.4,
                  ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Camera Viewfinder Zone
              _buildViewfinderZone(),
              const SizedBox(height: 16),

              // Retry Card if scan failed due to connection/server (retains photo!)
              if (_hasScanError && _selectedImage != null) ...[
                _buildRetryCard(),
                const SizedBox(height: 16),
              ],

              // Diagnostic Result Card (When available)
              if (_result != null) ...[
                _buildResultCard(_result!),
                const SizedBox(height: 20),
              ],

              // Quick Tips Banner
              _buildPhotographyTipsCard(),
              const SizedBox(height: 20),

              // Recent Scan History
              _buildRecentScansSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Open Immersive Full-Screen Photo Zoom & Inspection Modal
  void _openFullScreenZoomModal() {
    if (_selectedImage == null) return;

    final TransformationController zoomController = TransformationController();

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.94),
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Directionality(
              textDirection: _isUrdu ? TextDirection.rtl : TextDirection.ltr,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                  title: Text(
                    _isUrdu ? "تصویر کو زوم اور معائنہ کریں" : "Inspect Leaf Details",
                    style: _isUrdu
                        ? AppTheme.urdu(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)
                        : AppTheme.english(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      tooltip: _isUrdu ? "اصل سائز" : "Reset Zoom",
                      icon: const Icon(Icons.restart_alt_rounded, color: Colors.white, size: 24),
                      onPressed: () {
                        setModalState(() {
                          zoomController.value = Matrix4.identity();
                        });
                      },
                    ),
                  ],
                ),
                body: Stack(
                  children: [
                    // Interactive Zoom Area
                    Center(
                      child: InteractiveViewer(
                        transformationController: zoomController,
                        minScale: 0.8,
                        maxScale: 8.0,
                        boundaryMargin: const EdgeInsets.all(60),
                        child: kIsWeb
                            ? Image.network(_selectedImage!.path, fit: BoxFit.contain)
                            : Image.file(File(_selectedImage!.path), fit: BoxFit.contain),
                      ),
                    ),

                    // Top Hint Overlay
                    Positioned(
                      top: 10,
                      left: 20,
                      right: 20,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            _isUrdu
                                ? "دو انگلیوں سے تصویر کو زوم کر کے کیڑے یا فنگس کا باریک جائزہ لیں"
                                : "Pinch with two fingers to zoom up to 8x for pest/fungus inspection",
                            textAlign: TextAlign.center,
                            style: _isUrdu
                                ? AppTheme.urdu(color: Colors.white70, fontSize: 11)
                                : AppTheme.english(color: Colors.white70, fontSize: 11),
                          ),
                        ),
                      ),
                    ),

                    // Bottom Floating Zoom Controls (+ / - / 1x Reset)
                    Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.zoom_out_rounded, color: Colors.white, size: 22),
                                onPressed: () {
                                  final current = zoomController.value.getMaxScaleOnAxis();
                                  if (current > 1.0) {
                                    final newScale = (current - 0.6).clamp(1.0, 8.0);
                                    setModalState(() {
                                      zoomController.value = Matrix4.diagonal3Values(newScale, newScale, 1.0);
                                    });
                                  }
                                },
                              ),
                              Container(
                                width: 1,
                                height: 18,
                                color: Colors.white24,
                              ),
                              TextButton(
                                onPressed: () {
                                  setModalState(() {
                                    zoomController.value = Matrix4.identity();
                                  });
                                },
                                child: Text(
                                  _isUrdu ? "1x ری سیٹ" : "1x Reset",
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 18,
                                color: Colors.white24,
                              ),
                              IconButton(
                                icon: const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 22),
                                onPressed: () {
                                  final current = zoomController.value.getMaxScaleOnAxis();
                                  final newScale = (current + 0.8).clamp(1.0, 8.0);
                                  setModalState(() {
                                    zoomController.value = Matrix4.diagonal3Values(newScale, newScale, 1.0);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Camera Viewfinder Zone
  Widget _buildViewfinderZone() {
    return Container(
      width: double.infinity,
      height: 310,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.borderLight.withValues(alpha: 0.8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // If Image is Picked, Show preview
          if (_selectedImage != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: GestureDetector(
                onTap: _openFullScreenZoomModal,
                child: kIsWeb
                    ? Image.network(
                        _selectedImage!.path,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(_selectedImage!.path),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
            ),

            // Top Floating Zoom & Inspect Pill
            Positioned(
              top: 12,
              left: _isUrdu ? 12 : null,
              right: _isUrdu ? null : 12,
              child: InkWell(
                onTap: _openFullScreenZoomModal,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.zoom_in_rounded, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        _isUrdu ? "زوم کریں" : "Zoom",
                        style: _isUrdu
                            ? AppTheme.urdu(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              )
                            : AppTheme.english(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]
          else
            // Empty State Viewfinder Graphic
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.background,
                        border: Border.all(
                          color: AppColors.primaryMedium.withValues(alpha: 0.25),
                          width: 2,
                        ),
                      ),
                    ),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.greenGradient,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x331B4332),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_a_photo_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    _isUrdu ? "بیمار پتے یا پودے کی واضح تصویر لیں" : "Point Camera at Diseased Leaf",
                    textAlign: TextAlign.center,
                    style: _isUrdu
                        ? AppTheme.urdu(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          )
                        : AppTheme.english(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    _isUrdu ? "فوری اسکین اور تصدیق شدہ علاج حاصل کریں" : "Snap a photo for instant AI pest & remedy scan",
                    textAlign: TextAlign.center,
                    style: _isUrdu
                        ? AppTheme.urdu(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryMedium,
                          )
                        : AppTheme.english(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryMedium,
                          ),
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),

          // Laser Scanning Line Animation when analyzing
          if (_isAnalyzing)
            AnimatedBuilder(
              animation: _scanAnimation,
              builder: (context, child) {
                return Positioned(
                  top: _scanAnimation.value * 270,
                  left: 16,
                  right: 16,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.accentLime,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentLime.withValues(alpha: 0.85),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

          // Analysis Status Pill Overlay
          if (_isAnalyzing)
            Positioned(
              bottom: 16,
              left: 20,
              right: 20,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.accentLime,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          _analysisStep,
                          textAlign: TextAlign.center,
                          style: _isUrdu
                              ? AppTheme.urdu(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                )
                              : AppTheme.english(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Camera & Gallery Action Buttons at bottom
          if (!_isAnalyzing)
            Positioned(
              bottom: 14,
              left: 14,
              right: 14,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_rounded, size: 17, color: Colors.white),
                      label: Text(
                        _selectedImage == null
                            ? (_isUrdu ? "کیمرہ کھولیں" : "Open Camera")
                            : (_isUrdu ? "دوبارہ تصویر لیں" : "Retake Photo"),
                        style: _isUrdu
                            ? AppTheme.urdu(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)
                            : AppTheme.english(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark.withValues(alpha: _selectedImage != null ? 0.92 : 1.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        elevation: _selectedImage != null ? 3 : 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: Icon(
                        Icons.photo_library_rounded,
                        size: 17,
                        color: _selectedImage != null ? Colors.white : AppColors.primaryDark,
                      ),
                      label: Text(
                        _isUrdu ? "گیلری سے چنیں" : "From Gallery",
                        style: _isUrdu
                            ? AppTheme.urdu(
                                color: _selectedImage != null ? Colors.white : AppColors.primaryDark,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              )
                            : AppTheme.english(
                                color: _selectedImage != null ? Colors.white : AppColors.primaryDark,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _selectedImage != null
                            ? Colors.black.withValues(alpha: 0.55)
                            : AppColors.surface,
                        side: BorderSide(
                          color: _selectedImage != null
                              ? Colors.white.withValues(alpha: 0.7)
                              : AppColors.primaryDark,
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Retry Card if scan failed due to internet / server error
  Widget _buildRetryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.alertSoftRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.alertSoftRed.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.alertSoftRed.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  color: AppColors.alertSoftRed,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _isUrdu ? "اسکین مکمل نہیں ہو سکا" : "Analysis Unsuccessful",
                  style: _isUrdu
                      ? AppTheme.urdu(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.alertSoftRed,
                        )
                      : AppTheme.english(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.alertSoftRed,
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _scanErrorMessage ??
                (_isUrdu
                    ? "انٹرنیٹ میں سست رفتاری یا سرور لوڈ کی وجہ سے اسکین مکمل نہیں ہو سکا۔ آپ کی تصویر محفوظ ہے، دوبارہ کوشش کریں۔"
                    : "Network timeout or server busy. Your picture is preserved. Please retry without re-uploading."),
            style: _isUrdu
                ? AppTheme.urdu(
                    fontSize: 11,
                    color: AppColors.textDark.withValues(alpha: 0.8),
                    height: 1.5,
                  )
                : AppTheme.english(
                    fontSize: 12,
                    color: AppColors.textDark.withValues(alpha: 0.8),
                  ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: _isAnalyzing ? null : _runAiScan,
                  icon: const Icon(Icons.refresh_rounded, size: 18, color: Colors.white),
                  label: Text(
                    _isUrdu ? "اسی تصویر پر دوبارہ کوشش کریں" : "Retry Scan",
                    style: _isUrdu
                        ? AppTheme.urdu(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          )
                        : AppTheme.english(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: OutlinedButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(
                      color: AppColors.borderLight,
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _isUrdu ? "نئی تصویر" : "New Photo",
                    style: _isUrdu
                        ? AppTheme.urdu(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          )
                        : AppTheme.english(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Rejection Card when user uploads non-crop image (human, indoors, object)
  Widget _buildRejectionCard(DiagnosticResult res) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.orange.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.no_photography_rounded,
                  color: Colors.orange.shade800,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isUrdu ? "فصل یا پودا تشخیص نہیں ہو سکا" : "No Crop / Plant Detected",
                      style: _isUrdu
                          ? AppTheme.urdu(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.orange.shade900,
                            )
                          : AppTheme.english(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.orange.shade900,
                            ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isUrdu ? "تصویر فصل یا کھیت کی نہیں ہے" : "Image does not appear to be agricultural",
                      style: _isUrdu
                          ? AppTheme.urdu(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            )
                          : AppTheme.english(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              res.nonCropMessage ??
                  (_isUrdu
                      ? "یہ تصویر کسی فصل، پودے یا پتے کی معلوم نہیں ہوتی۔ براہِ کرم کھیت میں متاثرہ پودے کے قریب جا کر واضح تصویر لیں۔"
                      : "This picture does not show a plant, crop, or leaf. Please take a clear photo of an actual crop in daylight."),
              style: _isUrdu
                  ? AppTheme.urdu(
                      fontSize: 12,
                      color: AppColors.textDark,
                      height: 1.6,
                    )
                  : AppTheme.english(
                      fontSize: 12,
                      color: AppColors.textDark,
                      height: 1.4,
                    ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _isUrdu ? "بہترین نتائج کے لیے ہدایات:" : "Tips for Accurate Results:",
            style: _isUrdu
                ? AppTheme.urdu(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  )
                : AppTheme.english(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
          ),
          const SizedBox(height: 8),
          _buildTipRow(
            Icons.wb_sunny_rounded,
            _isUrdu ? "دن کی قدرتی روشنی میں تصویر کھینچیں" : "Take photos in daylight without shadows",
          ),
          const SizedBox(height: 6),
          _buildTipRow(
            Icons.center_focus_strong_rounded,
            _isUrdu ? "متاثرہ پتے یا کیڑے پر فوکس رکھیں" : "Keep camera focused on affected leaf or pest",
          ),
          const SizedBox(height: 6),
          _buildTipRow(
            Icons.blur_off_rounded,
            _isUrdu ? "کیمرہ ہلائے بغیر صاف تصویر بنائیں" : "Avoid blurry or shaky shots",
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.white),
                  label: Text(
                    _isUrdu ? "دوبارہ تصویر لیں" : "Retake Photo",
                    style: _isUrdu
                        ? AppTheme.urdu(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          )
                        : AppTheme.english(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_rounded, size: 18, color: AppColors.primaryDark),
                  label: Text(
                    _isUrdu ? "گیلری سے چنیں" : "Pick from Gallery",
                    style: _isUrdu
                        ? AppTheme.urdu(
                            color: AppColors.primaryDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          )
                        : AppTheme.english(
                            color: AppColors.primaryDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.primaryDark, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipRow(IconData icon, String tip) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryMedium),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            tip,
            style: _isUrdu
                ? AppTheme.urdu(fontSize: 11, color: AppColors.textDark)
                : AppTheme.english(fontSize: 11, color: AppColors.textDark),
          ),
        ),
      ],
    );
  }

  // Diagnostic Result Card
  Widget _buildResultCard(DiagnosticResult res) {
    if (!res.isPlantOrCrop) {
      return _buildRejectionCard(res);
    }

    final isHealthy = res.diseaseEnglish.toLowerCase().contains("healthy") ||
        res.severityLevel.toLowerCase().contains("healthy") ||
        res.severityLevel.contains("محفوظ");

    return Directionality(
      textDirection: _resultInUrdu ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isHealthy
              ? AppColors.successGreen.withValues(alpha: 0.35)
              : AppColors.primaryMedium.withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Diagnosis Header, Confidence & Language Switcher (Responsive Wrap)
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_rounded, color: AppColors.successGreen, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      _resultInUrdu
                          ? "${res.confidenceScore.toInt()}% درست"
                          : "${res.confidenceScore.toInt()}% Accuracy",
                      style: _resultInUrdu
                          ? AppTheme.urdu(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.successGreen,
                            )
                          : AppTheme.english(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.successGreen,
                            ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: isHealthy
                      ? AppColors.successGreen.withValues(alpha: 0.12)
                      : AppColors.alertSoftRed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isHealthy
                      ? (_resultInUrdu ? "تندرست • محفوظ" : "Healthy • Safe")
                      : (_resultInUrdu ? res.severityLevel : res.severityLevel),
                  style: _resultInUrdu
                      ? AppTheme.urdu(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isHealthy ? AppColors.successGreen : AppColors.alertSoftRed,
                        )
                      : AppTheme.english(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isHealthy ? AppColors.successGreen : AppColors.alertSoftRed,
                        ),
                ),
              ),

              // Language Switcher Pill (Urdu / English)
              Directionality(
                textDirection: TextDirection.ltr,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => setState(() => _resultInUrdu = true),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: _resultInUrdu ? AppColors.primaryDark : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            "اردو",
                            style: AppTheme.urdu(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _resultInUrdu ? Colors.white : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => setState(() => _resultInUrdu = false),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: !_resultInUrdu ? AppColors.primaryDark : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            "English",
                            style: AppTheme.english(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: !_resultInUrdu ? Colors.white : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Disease / Crop Status Name
          Text(
            _resultInUrdu
                ? (res.diseaseUrdu.isNotEmpty ? res.diseaseUrdu : res.diseaseEnglish)
                : (res.diseaseEnglish.isNotEmpty ? res.diseaseEnglish : res.diseaseUrdu),
            style: _resultInUrdu
                ? AppTheme.urdu(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    height: 1.7,
                  )
                : AppTheme.english(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
          ),
          if (_resultInUrdu && res.diseaseEnglish.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              res.diseaseEnglish,
              style: AppTheme.english(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            _resultInUrdu
                ? "فصل: ${res.cropUrdu.isNotEmpty ? res.cropUrdu : res.cropEnglish}${res.cropEnglish.isNotEmpty ? ' (${res.cropEnglish})' : ''}"
                : "Crop: ${res.cropEnglish}${res.cropUrdu.isNotEmpty ? ' (${res.cropUrdu})' : ''}",
            style: _resultInUrdu
                ? AppTheme.urdu(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryMedium,
                    height: 1.6,
                  )
                : AppTheme.english(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryMedium,
                  ),
          ),
          const SizedBox(height: 14),

          // Symptoms Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isHealthy ? Icons.eco_rounded : Icons.info_outline_rounded,
                      size: 15,
                      color: isHealthy ? AppColors.successGreen : AppColors.textDark,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isHealthy
                          ? (_resultInUrdu ? "فصل کی حالت:" : "Crop Condition:")
                          : (_resultInUrdu ? "علامات:" : "Symptoms:"),
                      style: _resultInUrdu
                          ? AppTheme.urdu(fontSize: 12, fontWeight: FontWeight.w700, height: 1.6)
                          : AppTheme.english(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _resultInUrdu
                      ? (res.symptomsUrdu.isNotEmpty ? res.symptomsUrdu : res.symptomsEnglish)
                      : (res.symptomsEnglish.isNotEmpty ? res.symptomsEnglish : res.symptomsUrdu),
                  style: _resultInUrdu
                      ? AppTheme.urdu(fontSize: 13, color: AppColors.textDark, height: 2.0)
                      : AppTheme.english(fontSize: 12, color: AppColors.textDark, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Treatment Box or Care Guidance
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.greenGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isHealthy
                          ? (_resultInUrdu ? "فصل کی نگہداشت اور مشورہ" : "Crop Care Guidance")
                          : (_resultInUrdu ? "مستند اسپرے علاج" : "Recommended Treatment"),
                      style: _resultInUrdu
                          ? AppTheme.urdu(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              height: 1.6,
                            )
                          : AppTheme.english(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                    ),
                    Icon(
                      isHealthy ? Icons.eco_rounded : Icons.medical_services_rounded,
                      color: AppColors.accentLime,
                      size: 16,
                    ),
                  ],
                ),
                if (!isHealthy && res.chemicalName.isNotEmpty && res.chemicalName != "N/A") ...[
                  const SizedBox(height: 8),
                  Text(
                    res.chemicalName,
                    style: AppTheme.english(
                      color: AppColors.accentGold,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
                if (!isHealthy && (res.dosageUrdu.isNotEmpty || res.dosageEnglish.isNotEmpty)) ...[
                  const SizedBox(height: 8),
                  Text(
                    _resultInUrdu
                        ? "خوراک: ${res.dosageUrdu.isNotEmpty ? res.dosageUrdu : res.dosageEnglish}"
                        : "Dosage: ${res.dosageEnglish.isNotEmpty ? res.dosageEnglish : res.dosageUrdu}",
                    style: _resultInUrdu
                        ? AppTheme.urdu(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 1.8,
                          )
                        : AppTheme.english(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  _resultInUrdu
                      ? (res.treatmentUrdu.isNotEmpty ? res.treatmentUrdu : res.treatmentEnglish)
                      : (res.treatmentEnglish.isNotEmpty ? res.treatmentEnglish : res.treatmentUrdu),
                  style: _resultInUrdu
                      ? AppTheme.urdu(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: 12,
                          height: 2.0,
                        )
                      : AppTheme.english(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: 11,
                          height: 1.4,
                        ),
                ),
              ],
            ),
          ),

          // Prevention Box
          if ((_resultInUrdu && res.preventionUrdu.isNotEmpty) ||
              (!_resultInUrdu && res.preventionEnglish.isNotEmpty)) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined, size: 14, color: AppColors.primaryMedium),
                      const SizedBox(width: 5),
                      Text(
                        _resultInUrdu ? "احتیاطی تدابیر اور بچاؤ:" : "Prevention & Care:",
                        style: _resultInUrdu
                            ? AppTheme.urdu(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryMedium, height: 1.6)
                            : AppTheme.english(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryMedium),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _resultInUrdu ? res.preventionUrdu : res.preventionEnglish,
                    style: _resultInUrdu
                        ? AppTheme.urdu(fontSize: 12, color: AppColors.textDark, height: 2.0)
                        : AppTheme.english(fontSize: 11, color: AppColors.textDark, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),

          // Live Weather Spray Advisory
          if (_sprayAdvisory != null) ...[
            _buildWeatherSprayCard(_sprayAdvisory!, isHealthy),
            const SizedBox(height: 14),
          ] else if (_isLoadingWeatherAdvisory) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Center(
                child: Text(
                  _resultInUrdu ? "موسمی اسپرے الرٹ لوڈ ہو رہا ہے..." : "Loading live spray advisory...",
                  style: _resultInUrdu
                      ? AppTheme.urdu(fontSize: 10, color: AppColors.textMuted)
                      : AppTheme.english(fontSize: 10, color: AppColors.textMuted),
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Action Buttons: Listen Audio & Share WhatsApp
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _toggleAudio,
                  icon: Icon(
                    _isPlayingAudio ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: Text(
                    _isPlayingAudio
                        ? (_resultInUrdu ? "آواز روکیں" : "Stop Voice")
                        : (_resultInUrdu ? "آواز میں سنیں" : "Listen Audio"),
                    style: _resultInUrdu
                        ? AppTheme.urdu(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)
                        : AppTheme.english(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isPlayingAudio ? AppColors.alertSoftRed : AppColors.primaryDark,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _isUrdu
                            ? "رپورٹ واٹس ایپ شیئرنگ کے لیے تیار ہے 📲"
                            : "Report ready to share on WhatsApp 📲",
                        style: _isUrdu
                            ? AppTheme.urdu(fontSize: 12, color: Colors.white)
                            : AppTheme.english(fontSize: 12, color: Colors.white),
                      ),
                      backgroundColor: AppColors.successGreen,
                    ),
                  );
                },
                icon: const Icon(Icons.share_rounded, color: AppColors.primaryDark, size: 18),
                label: Text(
                  _isUrdu ? "شیئر کریں" : "Share",
                  style: _isUrdu
                      ? AppTheme.urdu(color: AppColors.primaryDark, fontSize: 11, fontWeight: FontWeight.w700)
                      : AppTheme.english(color: AppColors.primaryDark, fontSize: 12, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  // Weather Spray Advisory Card
  Widget _buildWeatherSprayCard(SprayAdvisory advisory, bool isHealthy) {
    Color cardColor;
    Color badgeColor;
    IconData statusIcon;
    String statusTitle;

    switch (advisory.status) {
      case SprayStatus.optimal:
        cardColor = const Color(0xFFE8F5E9);
        badgeColor = AppColors.successGreen;
        statusIcon = Icons.check_circle_rounded;
        statusTitle = _resultInUrdu ? "اسپرے کے لیے موزوں" : "Optimal for Spraying";
        break;
      case SprayStatus.caution:
        cardColor = const Color(0xFFFFF8E1);
        badgeColor = const Color(0xFFF57F17);
        statusIcon = Icons.warning_amber_rounded;
        statusTitle = _resultInUrdu ? "احتیاط کے ساتھ اسپرے کریں" : "Spray with Caution";
        break;
      case SprayStatus.notRecommended:
        cardColor = const Color(0xFFFFEBEE);
        badgeColor = AppColors.alertSoftRed;
        statusIcon = Icons.cancel_rounded;
        statusTitle = _resultInUrdu ? "آج اسپرے ہرگز نہ کریں" : "Do Not Spray Today";
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor.withValues(alpha: 0.35), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: badgeColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _resultInUrdu ? "موسمی اسپرے مشورہ (لائیو الرٹ)" : "Live Weather Spray Advisory",
                  style: _resultInUrdu
                      ? AppTheme.urdu(fontSize: 12, fontWeight: FontWeight.w700, color: badgeColor)
                      : AppTheme.english(fontSize: 12, fontWeight: FontWeight.w700, color: badgeColor),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusTitle,
                  style: _resultInUrdu
                      ? AppTheme.urdu(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)
                      : AppTheme.english(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _resultInUrdu ? advisory.reasonUrdu : advisory.reasonEnglish,
            style: _resultInUrdu
                ? AppTheme.urdu(fontSize: 11, color: AppColors.textDark, height: 1.6)
                : AppTheme.english(fontSize: 11, color: AppColors.textDark, height: 1.4),
          ),
          if (advisory.bestWindowUrdu.isNotEmpty && !isHealthy) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.schedule_rounded, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _resultInUrdu
                        ? "تجویز کردہ وقت: ${advisory.bestWindowUrdu}"
                        : "Recommended window: ${advisory.bestWindowEnglish}",
                    style: _resultInUrdu
                        ? AppTheme.urdu(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primaryDark)
                        : AppTheme.english(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Photography Tips Card
  Widget _buildPhotographyTipsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline_rounded, color: AppColors.accentGold, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isUrdu ? "بہترین نتائج کے لیے مشورہ:" : "Photography Tip:",
                  style: _isUrdu
                      ? AppTheme.urdu(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        )
                      : AppTheme.english(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isUrdu
                      ? "کیمرہ پتے کے قریب رکھیں اور روشنی کے رخ تصویر لیں تاکہ جراثیم واضح نظر آئیں۔"
                      : "Hold the camera steady close to the leaf under good sunlight for sharp pathogen detection.",
                  style: _isUrdu
                      ? AppTheme.urdu(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        )
                      : AppTheme.english(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Recent Scan History Section
  Widget _buildRecentScansSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _isUrdu ? "پچھلی تشخیص" : "Recent Scans",
              style: _isUrdu
                  ? AppTheme.urdu(fontSize: 13, fontWeight: FontWeight.w700)
                  : AppTheme.english(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            Text(
              _isUrdu ? "تمام صاف کریں" : "Clear All",
              style: _isUrdu
                  ? AppTheme.urdu(fontSize: 10, color: AppColors.textMuted)
                  : AppTheme.english(fontSize: 10, color: AppColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 10),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildHistoryChip(
                _isUrdu ? "گندم کا کنگی روگ" : "Wheat Rust",
                _isUrdu ? "کل شام" : "Yesterday",
                true,
              ),
              const SizedBox(width: 8),
              _buildHistoryChip(
                _isUrdu ? "کماد کا کیڑا" : "Sugarcane Borer",
                _isUrdu ? "۳ دن پہلے" : "3 days ago",
                false,
              ),
              const SizedBox(width: 8),
              _buildHistoryChip(
                _isUrdu ? "ٹماٹر کا جھلسائو" : "Tomato Blight",
                _isUrdu ? "۵ دن پہلے" : "5 days ago",
                true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryChip(String title, String date, bool isTreated) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: _isUrdu
                ? AppTheme.urdu(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  )
                : AppTheme.english(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: _isUrdu
                ? AppTheme.urdu(
                    fontSize: 9,
                    color: AppColors.textMuted,
                  )
                : AppTheme.english(
                    fontSize: 9,
                    color: AppColors.textMuted,
                  ),
          ),
        ],
      ),
    );
  }
}
