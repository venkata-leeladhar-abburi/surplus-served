import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_te.dart';

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
    Locale('te'),
  ];

  /// App title, shown on splash and in the OS task switcher
  ///
  /// In en, this message translates to:
  /// **'Surplus → Served'**
  String get appTitle;

  /// No description provided for @roleSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'How will you use Surplus → Served?'**
  String get roleSelectTitle;

  /// No description provided for @roleDonor.
  ///
  /// In en, this message translates to:
  /// **'I have food to give'**
  String get roleDonor;

  /// No description provided for @roleReceiver.
  ///
  /// In en, this message translates to:
  /// **'I run a verified NGO'**
  String get roleReceiver;

  /// No description provided for @authPhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get authPhoneTitle;

  /// No description provided for @authPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'10-digit mobile number'**
  String get authPhoneHint;

  /// No description provided for @authOtpTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code we sent'**
  String get authOtpTitle;

  /// No description provided for @authOtpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sent to {phone}'**
  String authOtpSubtitle(String phone);

  /// No description provided for @donorDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Your donations'**
  String get donorDashboardTitle;

  /// No description provided for @donorCreateCta.
  ///
  /// In en, this message translates to:
  /// **'Post surplus food'**
  String get donorCreateCta;

  /// No description provided for @donorCreateStepDetails.
  ///
  /// In en, this message translates to:
  /// **'What\'s ready to go?'**
  String get donorCreateStepDetails;

  /// No description provided for @donorCreateStepPortions.
  ///
  /// In en, this message translates to:
  /// **'How many portions?'**
  String get donorCreateStepPortions;

  /// No description provided for @donorCreateStepWindow.
  ///
  /// In en, this message translates to:
  /// **'Pickup window'**
  String get donorCreateStepWindow;

  /// No description provided for @donorCreateStepAddress.
  ///
  /// In en, this message translates to:
  /// **'Pickup address'**
  String get donorCreateStepAddress;

  /// No description provided for @donorCreateStepReview.
  ///
  /// In en, this message translates to:
  /// **'Review and post'**
  String get donorCreateStepReview;

  /// No description provided for @donorLiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Live — waiting for a match'**
  String get donorLiveTitle;

  /// No description provided for @donorPickupCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Pickup code'**
  String get donorPickupCodeLabel;

  /// No description provided for @receiverFeedTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby surplus'**
  String get receiverFeedTitle;

  /// No description provided for @receiverFeedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get receiverFeedEmptyTitle;

  /// No description provided for @receiverFeedEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'New donations nearby will show up here the moment they go live.'**
  String get receiverFeedEmptyBody;

  /// No description provided for @receiverRequestCta.
  ///
  /// In en, this message translates to:
  /// **'Request this'**
  String get receiverRequestCta;

  /// No description provided for @receiverAllocatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Allocated to you'**
  String get receiverAllocatedTitle;

  /// No description provided for @receiverEnterCodeCta.
  ///
  /// In en, this message translates to:
  /// **'Enter pickup code'**
  String get receiverEnterCodeCta;

  /// No description provided for @receiverEnterCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm handover'**
  String get receiverEnterCodeTitle;

  /// No description provided for @receiverCollectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get receiverCollectedTitle;

  /// No description provided for @statusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// No description provided for @statusPendingCheck.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get statusPendingCheck;

  /// No description provided for @statusLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get statusLive;

  /// No description provided for @statusAllocated.
  ///
  /// In en, this message translates to:
  /// **'Allocated'**
  String get statusAllocated;

  /// No description provided for @statusCollected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get statusCollected;

  /// No description provided for @statusReallocated.
  ///
  /// In en, this message translates to:
  /// **'Reallocated'**
  String get statusReallocated;

  /// No description provided for @statusUnfulfilled.
  ///
  /// In en, this message translates to:
  /// **'Unfulfilled'**
  String get statusUnfulfilled;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get commonSubmit;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonRetry;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesShort(int minutes);
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
      <String>['en', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
