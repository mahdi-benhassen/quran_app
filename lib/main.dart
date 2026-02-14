import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_colors.dart';
import 'data/repositories/quran_repository.dart';
import 'data/services/api_service.dart';
import 'view_models/quran_view_model.dart';
import 'view_models/audio_view_model.dart';
import 'view_models/settings_view_model.dart';
import 'view_models/khatm_view_model.dart';
import 'ui/screens/splash_screen.dart';

void main() {
  runApp(const QuranApp());
}

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => ApiService()),
        ProxyProvider<ApiService, QuranRepository>(
          update: (_, apiService, __) => QuranRepository(apiService),
        ),
        ChangeNotifierProvider(
          create: (context) => QuranViewModel(context.read<QuranRepository>()),
        ),
        ChangeNotifierProvider(create: (_) => AudioViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => KhatmViewModel()),
      ],
      child: MaterialApp(
        title: 'Quran Reader',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            secondary: AppColors.secondary,
            background: AppColors.background,
            surface: AppColors.surface,
          ),
          textTheme: GoogleFonts.latoTextTheme(),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.background,
            elevation: 0,
            iconTheme: IconThemeData(color: AppColors.textPrimary),
            titleTextStyle: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
