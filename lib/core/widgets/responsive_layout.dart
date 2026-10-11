import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Responsive wrapper that guarantees flawless rendering on both Mobile and Desktop viewports.
/// On desktop, it centers the screen nicely with max-width constraints.
/// On mobile, it takes 100% of the viewport seamlessly.
class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final Color? backgroundColor;

  const ResponsiveLayout({
    super.key,
    required this.child,
    this.maxWidth = 520,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    return Container(
      color: backgroundColor ?? AppColors.background,
      alignment: Alignment.topCenter,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? maxWidth : double.infinity,
          ),
          child: Container(
            decoration: isDesktop
                ? BoxDecoration(
                    color: AppColors.background,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  )
                : null,
            child: child,
          ),
        ),
      ),
    );
  }
}
