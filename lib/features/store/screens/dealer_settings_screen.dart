import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/controllers/user_session_controller.dart';
import '../../auth/screens/login_screen.dart';

/// Dedicated Dealer Settings & Account Screen.
/// Contains the dealer profile summary and direct logout action to LoginScreen.
class DealerSettingsScreen extends StatelessWidget {
  final bool isStandalone;
  final bool? isUrdu;

  const DealerSettingsScreen({
    super.key,
    this.isStandalone = false,
    this.isUrdu,
  });

  Future<void> _handleDirectLogout(BuildContext context) async {
    try {
      await AuthService.instance.signOut();
    } catch (_) {}
    UserSessionController.instance.clearSession();

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bodyContent = SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Dealer Profile Summary Card
          _buildDealerProfileCard(),

          const SizedBox(height: 18),

          // 2. Account & Security Section
          const Text(
            "Account",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textMuted,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),

          // 3. Direct Logout Button Card
          _buildLogoutCard(context),

          const SizedBox(height: 28),

          // 4. App Version / Footer
          Center(
            child: Column(
              children: [
                Text(
                  "SabzDost Agri Dealer",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "v1.0.0 (Official Build)",
                  style: TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textLight.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (isStandalone) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark, size: 21),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Settings",
            style: AppTheme.english(fontSize: 16.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
          ),
          centerTitle: true,
        ),
        body: SafeArea(child: bodyContent),
      );
    }

    return bodyContent;
  }

  Widget _buildDealerProfileCard() {
    final session = UserSessionController.instance;
    final storeName = session.businessOrFarmName.isNotEmpty
        ? session.businessOrFarmName
        : "Chaudhry Agri Store";
    final dealerName = session.userName.isNotEmpty && session.userName != 'کسان بھائی'
        ? session.userName
        : "Chaudhry Riaz";
    final phone = session.userPhone.isNotEmpty ? session.userPhone : "0300-8472910";
    final district = session.district.isNotEmpty ? session.district : "Multan";

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Store Icon Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.storefront_rounded,
                color: AppColors.primaryDark,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Store Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        storeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "Verified",
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  "$dealerName • $district",
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutCard(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleDirectLogout(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFECACA), width: 1.0),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.alertSoftRed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.logout_rounded,
                    color: AppColors.alertSoftRed,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Log Out",
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.alertSoftRed,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "End dealer session and return to login screen",
                      style: TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.alertSoftRed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
