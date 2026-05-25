import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_mt.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('mt')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Gozolt Driver'**
  String get appTitle;

  /// No description provided for @goPartner.
  ///
  /// In en, this message translates to:
  /// **'GO PARTNER'**
  String get goPartner;

  /// No description provided for @bornInMalta.
  ///
  /// In en, this message translates to:
  /// **'Born in Malta, Loved by Europe'**
  String get bornInMalta;

  /// No description provided for @poweredBy.
  ///
  /// In en, this message translates to:
  /// **'Powered By'**
  String get poweredBy;

  /// No description provided for @primooo.
  ///
  /// In en, this message translates to:
  /// **'PRIMOOO'**
  String get primooo;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get you on the road'**
  String get onboardingTitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Start earning now'**
  String get onboardingTitle2;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your journey'**
  String get signInSubtitle;

  /// No description provided for @driverIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Driver ID'**
  String get driverIdLabel;

  /// No description provided for @driverIdPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter your driver ID'**
  String get driverIdPlaceholder;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordPlaceholder;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @contactSupplier.
  ///
  /// In en, this message translates to:
  /// **'Contact Your Supplier'**
  String get contactSupplier;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid driver ID or password'**
  String get errorInvalidCredentials;

  /// No description provided for @errorNetworkFailure.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get errorNetworkFailure;

  /// No description provided for @errorServerFailure.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get errorServerFailure;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorUnknown;

  /// No description provided for @errorFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get errorFieldRequired;

  /// No description provided for @homeTab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// No description provided for @earningTab.
  ///
  /// In en, this message translates to:
  /// **'Earning'**
  String get earningTab;

  /// No description provided for @historyTab.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTab;

  /// No description provided for @accountTab.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTab;

  /// No description provided for @goOnline.
  ///
  /// In en, this message translates to:
  /// **'Go Online'**
  String get goOnline;

  /// No description provided for @findingRides.
  ///
  /// In en, this message translates to:
  /// **'Finding Rides'**
  String get findingRides;

  /// No description provided for @goOnlineConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to go Online?'**
  String get goOnlineConfirmTitle;

  /// No description provided for @goOfflineConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to go offline?'**
  String get goOfflineConfirmTitle;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @sosEmergency.
  ///
  /// In en, this message translates to:
  /// **'SOS / Emergency - Coming Soon'**
  String get sosEmergency;

  /// No description provided for @notificationsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Notifications - Coming Soon'**
  String get notificationsComingSoon;

  /// No description provided for @earningComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Earning - Coming Soon'**
  String get earningComingSoon;

  /// No description provided for @historyComingSoon.
  ///
  /// In en, this message translates to:
  /// **'History - Coming Soon'**
  String get historyComingSoon;

  /// No description provided for @accountComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Account - Coming Soon'**
  String get accountComingSoon;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @card.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get card;

  /// No description provided for @todayEarnings.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Earnings'**
  String get todayEarnings;
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
      <String>['en', 'mt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'mt':
      return AppLocalizationsMt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
