import 'package:flutter/material.dart';
import '../localization/language_controller.dart';
import '../services/gemini_smart_input_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class GeminiInputAssistantSheet extends StatefulWidget {
  final String? initialText;
  final String title;
  final String hintText;
  final String? domainContext;
  final void Function(String correctedText, bool isUrdu) onSelected;

  const GeminiInputAssistantSheet({
    super.key,
    this.initialText,
    required this.title,
    required this.hintText,
    this.domainContext,
    required this.onSelected,
  });

  static Future<void> show({
    required BuildContext context,
    String? initialText,
    required String title,
    required String hintText,
    String? domainContext,
    required void Function(String correctedText, bool isUrdu) onSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GeminiInputAssistantSheet(
        initialText: initialText,
        title: title,
        hintText: hintText,
        domainContext: domainContext,
        onSelected: onSelected,
      ),
    );
  }

  @override
  State<GeminiInputAssistantSheet> createState() => _GeminiInputAssistantSheetState();
}

class _GeminiInputAssistantSheetState extends State<GeminiInputAssistantSheet> {
  late final TextEditingController _inputController;
  bool get _isUrdu => LanguageController.instance.isUrdu;
  bool _isLoading = false;
  SmartCorrectionResult? _result;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController(text: widget.initialText);
    if (widget.initialText != null && widget.initialText!.trim().isNotEmpty) {
      _processAi(widget.initialText!.trim());
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _processAi(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final res = await GeminiSmartInputService.correctAndTranslate(
      query,
      domainContext: widget.domainContext,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        _result = res;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomInset + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF257538),
                          const Color(0xFF4CAE5F),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textLight),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // User Input Box (supports Roman Urdu or broken input)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    style: const TextStyle(fontSize: 13.5, color: AppColors.textDark),
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textLight),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (val) => _processAi(val.trim()),
                  ),
                ),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () => _processAi(_inputController.text.trim()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _isUrdu ? "درست کریں" : "Fix with AI",
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // AI Results Section
          if (_result != null) ...[
            Text(
              _isUrdu ? "Gemini AI کی درست تجاویز:" : "Gemini AI Corrected Options:",
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryMedium,
              ),
            ),
            const SizedBox(height: 10),

            // 1. Urdu Option
            InkWell(
              onTap: () {
                widget.onSelected(_result!.correctedUrdu, true);
                Navigator.of(context).pop();
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF81C784)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E7D32),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "اردو (Urdu Nastaliq):",
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _result!.correctedUrdu,
                            style: AppTheme.urdu(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF1B5E20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _isUrdu ? "یہ منتخب کریں" : "Use Urdu",
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 2. English Option
            InkWell(
              onTap: () {
                widget.onSelected(_result!.correctedEnglish, false);
                Navigator.of(context).pop();
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF80CBC4)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF00796B),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "English (Corrected):",
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF004D40),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _result!.correctedEnglish,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF004D40),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00796B),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _isUrdu ? "انگلش منتخب کریں" : "Use English",
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
