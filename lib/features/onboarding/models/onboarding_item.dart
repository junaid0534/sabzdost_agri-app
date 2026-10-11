import 'package:flutter/material.dart';

class OnboardingItem {
  final String tagEnglish;
  final String tagUrdu;
  final String titleEnglish;
  final String titleUrdu;
  final String subtitleEnglish;
  final String subtitleUrdu;
  final String badgeTextEnglish;
  final String badgeTextUrdu;
  final IconData icon;
  final Color badgeColor;

  const OnboardingItem({
    required this.tagEnglish,
    required this.tagUrdu,
    required this.titleEnglish,
    required this.titleUrdu,
    required this.subtitleEnglish,
    required this.subtitleUrdu,
    required this.badgeTextEnglish,
    required this.badgeTextUrdu,
    required this.icon,
    required this.badgeColor,
  });
}
