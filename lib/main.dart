import 'package:flutter/material.dart';
import 'core/localization/language_controller.dart';
import 'core/services/firebase_service.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  runApp(const SabzDostApp());
}

class SabzDostApp extends StatelessWidget {
  const SabzDostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageController.instance,
      builder: (context, _) {
        final isUrdu = LanguageController.instance.isUrdu;
        return MaterialApp(
          title: 'SabzDost',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          locale: isUrdu ? const Locale('ur', 'PK') : const Locale('en', 'US'),
          home: const SplashScreen(),
        );
      },
    );
  }
}
