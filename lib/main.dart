import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/splash_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://YOUR_SUPABASE_URL.supabase.co', // ← ضع رابط Supabase هنا
    anonKey: 'YOUR_SUPABASE_ANON_KEY',            // ← ضع المفتاح هنا
  );

  runApp(const TruckMarketApp());
}

class TruckMarketApp extends StatelessWidget {
  const TruckMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سوق الشاحنات',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: const Locale('ar', 'SA'),
      home: const SplashScreen(),
    );
  }
}
