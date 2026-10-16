import 'dart:async';
import 'package:flutter/material.dart';
import '../localization/language_controller.dart';
import '../services/gemini_smart_input_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class GeminiSmartSearchBar extends StatefulWidget {
  final String? initialValue;
  final String? hintText;
  final String? domainContext;
  final ValueChanged<String>? onChanged;
  final void Function(String query, SmartCorrectionResult? aiResult)? onSearchChanged;
  final void Function(String query, SmartCorrectionResult? aiResult)? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;

  const GeminiSmartSearchBar({
    super.key,
    this.initialValue,
    this.hintText,
    this.domainContext,
    this.onChanged,
    this.onSearchChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
  });

  @override
  State<GeminiSmartSearchBar> createState() => _GeminiSmartSearchBarState();
}

class _GeminiSmartSearchBarState extends State<GeminiSmartSearchBar> {
  late final TextEditingController _controller;
  bool get _isUrdu => LanguageController.instance.isUrdu;

  Timer? _debounceTimer;
  bool _isLoadingAi = false;
  SmartCorrectionResult? _aiResult;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    widget.onChanged?.call(value);

    // Instant heuristic fallback so filtering responds with 0ms delay
    SmartCorrectionResult? instantAi;
    final trimmed = value.trim();
    if (trimmed.length >= 2) {
      instantAi = SmartCorrectionResult.fallback(trimmed);
      _aiResult = instantAi;
    } else {
      _aiResult = null;
    }
    widget.onSearchChanged?.call(value, _aiResult);

    // Debounced call to Gemini 2.5 Flash-Lite API for deep semantic expansion
    _debounceTimer?.cancel();
    if (trimmed.length >= 2) {
      _debounceTimer = Timer(const Duration(milliseconds: 400), () {
        _triggerAiCorrection(trimmed);
      });
    } else {
      if (mounted && _isLoadingAi) {
        setState(() {
          _isLoadingAi = false;
        });
      }
    }
  }

  Future<void> _triggerAiCorrection(String query) async {
    if (query.trim().isEmpty) return;

    if (mounted) {
      setState(() {
        _isLoadingAi = true;
      });
    }

    try {
      final result = await GeminiSmartInputService.correctAndTranslate(
        query,
        domainContext: widget.domainContext,
      );

      if (mounted) {
        setState(() {
          _isLoadingAi = false;
          _aiResult = result;
        });
        // Seamlessly update parent search filter with full Gemini AI expansion
        widget.onSearchChanged?.call(_controller.text, result);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingAi = false;
        });
      }
    }
  }

  void _submit() {
    final text = _controller.text;
    final fallbackAi = text.trim().length >= 2 ? SmartCorrectionResult.fallback(text.trim()) : null;
    widget.onSubmitted?.call(text, _aiResult ?? fallbackAi);
  }

  @override
  Widget build(BuildContext context) {
    final defaultHint = _isUrdu ? "یہاں تلاش کریں..." : "Search here...";
    final displayHint = widget.hintText ?? defaultHint;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _isLoadingAi ? AppColors.primaryMedium.withValues(alpha: 0.8) : AppColors.borderLight,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(
            Icons.search_rounded,
            color: AppColors.primaryMedium,
            size: 20,
          ),
          const SizedBox(width: 8),

          // Search Text Input
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: widget.autofocus,
              onChanged: _onTextChanged,
              onSubmitted: (_) => _submit(),
              textInputAction: TextInputAction.search,
              style: _isUrdu
                  ? AppTheme.urdu(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    )
                  : AppTheme.english(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
              decoration: InputDecoration(
                hintText: displayHint,
                hintStyle: _isUrdu
                    ? AppTheme.urdu(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textLight,
                      )
                    : AppTheme.english(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textLight,
                      ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          // Clear Button
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textLight),
              splashRadius: 18,
              onPressed: () {
                _controller.clear();
                _debounceTimer?.cancel();
                setState(() {
                  _isLoadingAi = false;
                  _aiResult = null;
                });
                widget.onClear?.call();
                widget.onChanged?.call("");
                widget.onSearchChanged?.call("", null);
              },
            ),

          // Gemini AI subtle indicator badge
          Padding(
            padding: const EdgeInsets.only(right: 6, left: 2),
            child: InkWell(
              onTap: () {
                if (_controller.text.trim().isNotEmpty) {
                  _triggerAiCorrection(_controller.text.trim());
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isLoadingAi ? AppColors.primaryMedium : const Color(0xFFA5D6A7),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isLoadingAi)
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryDark),
                        ),
                      )
                    else
                      const Icon(
                        Icons.auto_awesome,
                        color: Color(0xFF2E7D32),
                        size: 13,
                      ),
                    const SizedBox(width: 4),
                    Text(
                      "AI",
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1B5E20),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
