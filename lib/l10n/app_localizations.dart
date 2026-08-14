import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Fatesight'**
  String get appTitle;

  /// The title for fortune story feature
  ///
  /// In en, this message translates to:
  /// **'Fortune Story'**
  String get fortuneStory;

  /// Description of the service
  ///
  /// In en, this message translates to:
  /// **'Get personalized fortune stories based on your birth date and time using Korean astrology'**
  String get serviceDescription;

  /// Button text to listen to stories
  ///
  /// In en, this message translates to:
  /// **'Listen to Stories'**
  String get listenToStories;

  /// Title for recent story section
  ///
  /// In en, this message translates to:
  /// **'Recent Story'**
  String get recentStory;

  /// Button text to view story again
  ///
  /// In en, this message translates to:
  /// **'View Again'**
  String get viewAgain;

  /// Text shown while analyzing destiny
  ///
  /// In en, this message translates to:
  /// **'Analyzing Destiny'**
  String get analyzingDestiny;

  /// Text asking user to wait
  ///
  /// In en, this message translates to:
  /// **'Please wait while we analyze your destiny...'**
  String get pleaseWait;

  /// Label for name input field
  ///
  /// In en, this message translates to:
  /// **'Enter Name'**
  String get enterName;

  /// Label for birth date field
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDate;

  /// Label for birth time field
  ///
  /// In en, this message translates to:
  /// **'Birth Time'**
  String get birthTime;

  /// Label for question field
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get question;

  /// Hint text for name field
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get nameHint;

  /// Hint text for question field
  ///
  /// In en, this message translates to:
  /// **'What would you like to know?'**
  String get questionHint;

  /// Button text to get fortune story
  ///
  /// In en, this message translates to:
  /// **'Get Fortune Story'**
  String get getFortuneStory;

  /// Title for tarot screen
  ///
  /// In en, this message translates to:
  /// **'Tarot Cards'**
  String get tarotTitle;

  /// Instruction text for card selection
  ///
  /// In en, this message translates to:
  /// **'Drag to select a card'**
  String get dragToSelectCard;

  /// Button text to check fortune
  ///
  /// In en, this message translates to:
  /// **'Check Fortune'**
  String get checkFortune;

  /// Button text to select card
  ///
  /// In en, this message translates to:
  /// **'Select Card'**
  String get selectCard;

  /// Button text to draw again
  ///
  /// In en, this message translates to:
  /// **'Draw Again'**
  String get drawAgain;

  /// Button text for home
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Text when selection is complete
  ///
  /// In en, this message translates to:
  /// **'Selection Complete'**
  String get selectionComplete;

  /// Text for selected card
  ///
  /// In en, this message translates to:
  /// **'Selected Card'**
  String get selectedCard;

  /// Text to check fortune
  ///
  /// In en, this message translates to:
  /// **'Check your fortune'**
  String get checkFortuneText;

  /// Text to tap to confirm
  ///
  /// In en, this message translates to:
  /// **'Tap to confirm'**
  String get tapToConfirm;

  /// Card selection progress text
  ///
  /// In en, this message translates to:
  /// **'Card {current} of {total}'**
  String cardSelection(int current, int total);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
