import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../view_models/quran_view_model.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Pre-fetch data while splash is showing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuranViewModel>().fetchSurahs();
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo or Icon
            const Icon(
                  Icons.book, // Placeholder for Quran Icon
                  size: 100,
                  color: AppColors.accent,
                )
                .animate()
                .scale(duration: 800.ms, curve: Curves.easeOutBack)
                .fade(),

            const SizedBox(height: 20),

            const Text(
              'Quran Reader',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily:
                    'Amiri', // Use Arabic font style for title if available or fallback
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.5, end: 0),

            const SizedBox(height: 10),

            const Text(
              'Read, Listen, Reflect',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ).animate().fadeIn(delay: 1000.ms),
          ],
        ),
      ),
    );
  }
}
