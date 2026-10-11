import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/localization/language_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
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
  XFile? _selectedImage;
  bool _isAnalyzing = false;
  String _analysisStep = "";
  DiagnosticResult? _result;
  bool _isPlayingAudio = false;
  bool _resultInUrdu = true;

  late AnimationController _scanController;
  late Animation<double> _scanAnimation;

  bool get _isUrdu => widget.isUrdu ?? LanguageController.instance.isUrdu;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.1, end: 0.9).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
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
      _analysisStep = _isUrdu
          ? "پتے کی ساخت اور بیماری کا تفصیلی معائنہ جاری ہے..."
          : "Analyzing leaf structure with Gemini AI...";
    });

    try {
      final result = await CropDiseaseService.analyzeCropImage(_selectedImage!);
      if (!mounted) return;

      setState(() {
        _isAnalyzing = false;
        _result = result;
      });

      if (!result.isPlantOrCrop) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isUrdu
                  ? (result.nonCropMessage ?? "تصویر میں کوئی فصل یا پودا ظاہر نہیں ہوا۔ پتے کی صاف تصویر لیں۔")
                  : "No crop or plant leaf detected. Please take a clear close-up of a leaf.",
              style: _isUrdu
                  ? AppTheme.urdu(color: Colors.white, fontSize: 12)
                  : AppTheme.english(color: Colors.white, fontSize: 12),
            ),
            backgroundColor: AppColors.alertSoftRed,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isUrdu
                ? "تجزیہ مکمل نہ ہو سکا۔ انٹرنیٹ کنکشن چیک کر کے دوبارہ کوشش کریں۔"
                : "Could not complete AI scan. Check internet and retry.",
            style: _isUrdu
                ? AppTheme.urdu(color: Colors.white, fontSize: 12)
                : AppTheme.english(color: Colors.white, fontSize: 12),
          ),
          backgroundColor: AppColors.alertSoftRed,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _toggleAudio() {
    setState(() {
      _isPlayingAudio = !_isPlayingAudio;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isPlayingAudio
              ? (_isUrdu
                  ? "اردو صوتی رہنمائی جاری ہے 🔊"
                  : "Audio guidance playing 🔊")
              : (_isUrdu ? "آڈیو روک دی گئی ہے" : "Audio paused"),
          style: _isUrdu
              ? AppTheme.urdu(fontSize: 12, color: Colors.white)
              : AppTheme.english(fontSize: 12, color: Colors.white),
        ),
        backgroundColor: AppColors.primaryDark,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                _isUrdu ? "اے آئی فصل ڈاکٹر" : "AI Crop Doctor",
                style: _isUrdu
                    ? AppTheme.urdu(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      )
                    : AppTheme.english(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
              ),
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.accentLime,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    _isUrdu
                        ? "ویژن اے آئی • ۹۸.۴٪ درستگی • فوری علاج"
                        : "Vision AI 2.0 • 98.4% Accuracy • Instant Remedy",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _isUrdu
                        ? AppTheme.urdu(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          )
                        : AppTheme.english(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                const Icon(Icons.mic_none_rounded, size: 14, color: AppColors.primaryDark),
                const SizedBox(width: 4),
                Text(
                  _isUrdu ? "صوتی رہنمائی" : "Voice AI",
                  style: _isUrdu
                      ? AppTheme.urdu(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        )
                      : AppTheme.english(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Camera Viewfinder Zone
            _buildViewfinderZone(),
            const SizedBox(height: 18),

            // Voice Question Mic Bar ("بول کر مسئلہ پوچھیں")
            _buildVoiceQuestionBar(),
            const SizedBox(height: 20),

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
    );
  }

  // Camera Viewfinder Zone
  Widget _buildViewfinderZone() {
    return Container(
      width: double.infinity,
      height: 330,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // If Image is Picked, Show preview
          if (_selectedImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
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
            )
          else
            // Empty State Viewfinder Graphic
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.background,
                        border: Border.all(
                          color: AppColors.primaryMedium.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                    ),
                    Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.greenGradient,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  _isUrdu ? "بیمار پتے یا پودے کی واضح تصویر لیں" : "Point Camera at Diseased Leaf",
                  style: _isUrdu
                      ? AppTheme.urdu(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        )
                      : AppTheme.english(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isUrdu ? "فوری اسکین اور تصدیق شدہ علاج حاصل کریں" : "Snap a photo for instant AI pest & remedy scan",
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
              ],
            ),

          // Laser Scanning Line Animation when analyzing
          if (_isAnalyzing)
            AnimatedBuilder(
              animation: _scanAnimation,
              builder: (context, child) {
                return Positioned(
                  top: _scanAnimation.value * 300,
                  left: 20,
                  right: 20,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.accentLime,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentLime.withValues(alpha: 0.8),
                          blurRadius: 12,
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
              bottom: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
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
                    const SizedBox(width: 8),
                    Text(
                      _analysisStep,
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
                  ],
                ),
              ),
            ),

          // Camera & Gallery Action Buttons at bottom
          if (!_isAnalyzing)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.white),
                      label: Text(
                        _isUrdu ? "کیمرہ کھولیں" : "Open Camera",
                        style: _isUrdu
                            ? AppTheme.urdu(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)
                            : AppTheme.english(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
                        _isUrdu ? "گیلری سے چنیں" : "Upload Gallery",
                        style: _isUrdu
                            ? AppTheme.urdu(color: AppColors.primaryDark, fontSize: 12, fontWeight: FontWeight.w700)
                            : AppTheme.english(color: AppColors.primaryDark, fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        side: const BorderSide(color: AppColors.primaryDark, width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
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

  // Voice Question Bar
  Widget _buildVoiceQuestionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mic_rounded,
                  color: AppColors.primaryDark,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isUrdu ? "بول کر مسئلہ پوچھیں" : "Ask by Voice",
                      style: _isUrdu
                          ? AppTheme.urdu(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            )
                          : AppTheme.english(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _isUrdu
                          ? "مائیک دبا کر اپنی زبان میں فصل کا مسئلہ بتائیں"
                          : "Tap microphone and speak your crop issue",
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
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _isUrdu
                            ? "مائیک آن ہے، بولیں 🎙️"
                            : "Microphone active... Speak now 🎙️",
                        style: _isUrdu
                            ? AppTheme.urdu(fontSize: 12, color: Colors.white)
                            : AppTheme.english(fontSize: 12, color: Colors.white),
                      ),
                      backgroundColor: AppColors.primaryDark,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _isUrdu ? "بولیں" : "Speak",
                    style: _isUrdu
                        ? AppTheme.urdu(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          )
                        : AppTheme.english(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Suggested quick question chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPromptChip(
                  _isUrdu ? "گندم کا پتہ پیلا کیوں ہو رہا ہے؟" : "Why are wheat leaves turning yellow?",
                ),
                const SizedBox(width: 8),
                _buildPromptChip(
                  _isUrdu ? "کپاس پر سفید مکھی کا سستا اسپرے" : "Best spray for cotton whitefly",
                ),
                const SizedBox(width: 8),
                _buildPromptChip(
                  _isUrdu ? "مکئی کے کیڑے کا علاج" : "Corn stem borer control",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Text(
        text,
        style: AppTheme.urdu(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryMedium,
        ),
      ),
    );
  }

  // Diagnostic Result Card
  Widget _buildResultCard(DiagnosticResult res) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryMedium.withValues(alpha: 0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.08),
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
                  color: AppColors.alertSoftRed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _resultInUrdu ? res.severityLevel : "High Risk",
                  style: _resultInUrdu
                      ? AppTheme.urdu(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.alertSoftRed,
                        )
                      : AppTheme.english(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.alertSoftRed,
                        ),
                ),
              ),

              // Language Switcher Pill (Urdu / English)
              Container(
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
            ],
          ),
          const SizedBox(height: 14),

          // Disease Name
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
                ? "متاثرہ فصل: ${res.cropUrdu.isNotEmpty ? res.cropUrdu : res.cropEnglish}${res.cropEnglish.isNotEmpty ? ' (${res.cropEnglish})' : ''}"
                : "Affected Crop: ${res.cropEnglish}${res.cropUrdu.isNotEmpty ? ' (${res.cropUrdu})' : ''}",
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
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textDark),
                    const SizedBox(width: 5),
                    Text(
                      _resultInUrdu ? "علامات:" : "Symptoms:",
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

          // Treatment Box
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
                      _resultInUrdu ? "مستند اسپرے علاج" : "Recommended Treatment",
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
                    const Icon(Icons.medical_services_rounded, color: AppColors.accentLime, size: 16),
                  ],
                ),
                if (res.chemicalName.isNotEmpty && res.chemicalName != "N/A") ...[
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
                if (res.dosageUrdu.isNotEmpty || res.dosageEnglish.isNotEmpty) ...[
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

          // Action Buttons: Listen Audio & Share WhatsApp
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _toggleAudio,
                  icon: Icon(
                    _isPlayingAudio ? Icons.pause_rounded : Icons.volume_up_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: Text(
                    _isPlayingAudio
                        ? (_isUrdu ? "آڈیو روکیں" : "Pause Audio")
                        : (_isUrdu ? "رہنمائی سنیں" : "Listen Audio"),
                    style: _isUrdu
                        ? AppTheme.urdu(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)
                        : AppTheme.english(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
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
