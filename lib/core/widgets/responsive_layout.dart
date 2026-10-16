import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Responsive wrapper that guarantees flawless rendering on both Mobile and Desktop viewports.
/// On desktop PC/Web with wide screens, it centers the view with max-width constraints.
/// On mobile phones and tablets (both Portrait & Landscape), it takes 100% full screen width seamlessly.
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
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;
    final isLandscape = media.orientation == Orientation.landscape;

    // Detect actual mobile device platform (Android / iOS)
    final isMobilePlatform = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);

    // If on a mobile device (Android/iOS phone or tablet), or in mobile landscape viewport (screenHeight < 550),
    // NEVER constrain to 520px: always take 100% full screen width!
    final isMobileLandscape = isLandscape && screenHeight < 550;
    final isDesktop = !isMobilePlatform && !isMobileLandscape && screenWidth > 768;

    return Container(
      color: backgroundColor ?? AppColors.background,
      alignment: Alignment.topCenter,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? maxWidth : double.infinity,
          ),
          child: Container(
            width: isDesktop ? null : double.infinity,
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
