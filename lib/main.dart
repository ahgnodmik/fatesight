import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'services/openai_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'providers/language_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fatesight/l10n/app_localizations.dart';
import 'services/admob_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load .env file safely
  try {
    await dotenv.load(fileName: 'assets/.env');
    print('✅ .env file loaded successfully');
    print('🔑 API Key exists: ${dotenv.env['OPENAI_API_KEY'] != null && dotenv.env['OPENAI_API_KEY']!.isNotEmpty}');
  } catch (e) {
    print('❌ Warning: Could not load .env file: $e');
  }
  
  // Initialize Firebase safely
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Warning: Firebase initialization failed: $e');
  }
  
  // Initialize AdMob safely
  try {
    await AdMobService.initialize();
  } catch (e) {
    print('Warning: AdMob initialization failed: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider(OpenAIService())),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: 'Fatesight',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              textTheme: GoogleFonts.notoSansTextTheme(
                Theme.of(context).textTheme,
              ),
            ),
            locale: languageProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('ko', ''),
            ],
            navigatorObservers: [
              if (Firebase.apps.isNotEmpty)
                FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
            ],
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}

