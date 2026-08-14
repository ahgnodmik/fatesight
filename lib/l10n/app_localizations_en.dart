// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Fatesight';

  @override
  String get fortuneStory => 'Fortune Story';

  @override
  String get serviceDescription =>
      'Get personalized fortune stories based on your birth date and time using Korean astrology';

  @override
  String get listenToStories => 'Listen to Stories';

  @override
  String get recentStory => 'Recent Story';

  @override
  String get viewAgain => 'View Again';

  @override
  String get analyzingDestiny => 'Analyzing Destiny';

  @override
  String get pleaseWait => 'Please wait while we analyze your destiny...';

  @override
  String get enterName => 'Enter Name';

  @override
  String get birthDate => 'Birth Date';

  @override
  String get birthTime => 'Birth Time';

  @override
  String get question => 'Question';

  @override
  String get nameHint => 'Your name';

  @override
  String get questionHint => 'What would you like to know?';

  @override
  String get getFortuneStory => 'Get Fortune Story';

  @override
  String get tarotTitle => 'Tarot Cards';

  @override
  String get dragToSelectCard => 'Drag to select a card';

  @override
  String get checkFortune => 'Check Fortune';

  @override
  String get selectCard => 'Select Card';

  @override
  String get drawAgain => 'Draw Again';

  @override
  String get home => 'Home';

  @override
  String get selectionComplete => 'Selection Complete';

  @override
  String get selectedCard => 'Selected Card';

  @override
  String get checkFortuneText => 'Check your fortune';

  @override
  String get tapToConfirm => 'Tap to confirm';

  @override
  String cardSelection(int current, int total) {
    return 'Card $current of $total';
  }
}
