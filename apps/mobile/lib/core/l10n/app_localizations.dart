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

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Good food should keep moving.'**
  String get splashTagline;

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

  /// No description provided for @roleDonorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restaurants, caterers, event kitchens'**
  String get roleDonorSubtitle;

  /// No description provided for @roleReceiver.
  ///
  /// In en, this message translates to:
  /// **'I run a verified NGO'**
  String get roleReceiver;

  /// No description provided for @roleReceiverSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Collect surplus food for people who need it'**
  String get roleReceiverSubtitle;

  /// No description provided for @authPhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get authPhoneTitle;

  /// No description provided for @authPhoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll text you a one-time code to confirm it\'s you.'**
  String get authPhoneSubtitle;

  /// No description provided for @authPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'10-digit mobile number'**
  String get authPhoneHint;

  /// No description provided for @authPhoneError.
  ///
  /// In en, this message translates to:
  /// **'Could not send the code. Try again.'**
  String get authPhoneError;

  /// No description provided for @authSendCodeCta.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get authSendCodeCta;

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

  /// No description provided for @authOtpCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'4-digit code'**
  String get authOtpCodeLabel;

  /// No description provided for @authOtpError.
  ///
  /// In en, this message translates to:
  /// **'That code didn\'t work. Try again.'**
  String get authOtpError;

  /// No description provided for @authVerifyCta.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get authVerifyCta;

  /// No description provided for @commonErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get commonErrorTitle;

  /// No description provided for @commonErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load this. Check your connection and try again.'**
  String get commonErrorMessage;

  /// No description provided for @offlineBannerMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline — some information may be out of date.'**
  String get offlineBannerMessage;

  /// No description provided for @commonPortionsLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} portions'**
  String commonPortionsLabel(int count);

  /// No description provided for @commonPickupAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Pickup address'**
  String get commonPickupAddressLabel;

  /// No description provided for @commonLocality.
  ///
  /// In en, this message translates to:
  /// **'Locality'**
  String get commonLocality;

  /// No description provided for @timeLeftMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min left'**
  String timeLeftMinutes(int minutes);

  /// No description provided for @timeLeftHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} hr left'**
  String timeLeftHours(int hours);

  /// No description provided for @donorDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Your donations'**
  String get donorDashboardTitle;

  /// No description provided for @donorDashboardEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing posted yet'**
  String get donorDashboardEmptyTitle;

  /// No description provided for @donorDashboardEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Hi {name} — post your first surplus batch and it goes live instantly.'**
  String donorDashboardEmptyMessage(String name);

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

  /// No description provided for @donorCreateFoodLabel.
  ///
  /// In en, this message translates to:
  /// **'What is it?'**
  String get donorCreateFoodLabel;

  /// No description provided for @donorCreateFoodHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Vegetable biryani, 40 portions'**
  String get donorCreateFoodHint;

  /// No description provided for @donorCreateNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Anything an NGO should know? (optional)'**
  String get donorCreateNotesLabel;

  /// No description provided for @donorCreatePortionsMinusTooltip.
  ///
  /// In en, this message translates to:
  /// **'Fewer portions'**
  String get donorCreatePortionsMinusTooltip;

  /// No description provided for @donorCreatePortionsPlusTooltip.
  ///
  /// In en, this message translates to:
  /// **'More portions'**
  String get donorCreatePortionsPlusTooltip;

  /// No description provided for @donorCreatePortionsUnit.
  ///
  /// In en, this message translates to:
  /// **'portions'**
  String get donorCreatePortionsUnit;

  /// No description provided for @donorCreateWindowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How long can an NGO safely collect this for?'**
  String get donorCreateWindowSubtitle;

  /// No description provided for @donorCreateWindowOption.
  ///
  /// In en, this message translates to:
  /// **'{hours, plural, one {1 hour} other {{hours} hours}}'**
  String donorCreateWindowOption(num hours);

  /// No description provided for @donorCreateAddressPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Only the locality is shown until an NGO is matched — the exact address is shared with them alone (§11).'**
  String get donorCreateAddressPrivacyNote;

  /// No description provided for @donorCreateLocalityHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Jubilee Hills, Hyderabad'**
  String get donorCreateLocalityHint;

  /// No description provided for @donorCreateReviewFoodLabel.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get donorCreateReviewFoodLabel;

  /// No description provided for @donorCreateReviewPortionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Portions'**
  String get donorCreateReviewPortionsLabel;

  /// No description provided for @donorCreateReviewWindowLabel.
  ///
  /// In en, this message translates to:
  /// **'Pickup window'**
  String get donorCreateReviewWindowLabel;

  /// No description provided for @donorCreateReviewLocalityLabel.
  ///
  /// In en, this message translates to:
  /// **'Locality'**
  String get donorCreateReviewLocalityLabel;

  /// No description provided for @donorCreateReviewWindowValue.
  ///
  /// In en, this message translates to:
  /// **'{hours} hr from posting'**
  String donorCreateReviewWindowValue(int hours);

  /// No description provided for @donorCreateLiveAlert.
  ///
  /// In en, this message translates to:
  /// **'This goes live immediately and is visible to nearby NGOs.'**
  String get donorCreateLiveAlert;

  /// No description provided for @donorLiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Live — waiting for a match'**
  String get donorLiveTitle;

  /// No description provided for @donorLiveAlert.
  ///
  /// In en, this message translates to:
  /// **'Live — visible to nearby NGOs. We\'ll notify you the moment one requests it.'**
  String get donorLiveAlert;

  /// No description provided for @donorAllocatedAlert.
  ///
  /// In en, this message translates to:
  /// **'{ngoName} is on the way. Share this code at handover.'**
  String donorAllocatedAlert(String ngoName);

  /// No description provided for @donorPickupCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Pickup code'**
  String get donorPickupCodeLabel;

  /// No description provided for @donorPickupCodeCaption.
  ///
  /// In en, this message translates to:
  /// **'Ask for this code before handing over the food.'**
  String get donorPickupCodeCaption;

  /// No description provided for @donorCollectedByLabel.
  ///
  /// In en, this message translates to:
  /// **'Collected by {ngoName}'**
  String donorCollectedByLabel(String ngoName);

  /// No description provided for @donorCancelCta.
  ///
  /// In en, this message translates to:
  /// **'Cancel donation'**
  String get donorCancelCta;

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

  /// No description provided for @receiverFromDonorLabel.
  ///
  /// In en, this message translates to:
  /// **'From {donorName}'**
  String receiverFromDonorLabel(String donorName);

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

  /// No description provided for @receiverEnterCodeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask the donor for the 4-digit code shown on their screen.'**
  String get receiverEnterCodeSubtitle;

  /// No description provided for @receiverEnterCodeError.
  ///
  /// In en, this message translates to:
  /// **'That code doesn\'t match. Check with the donor and try again.'**
  String get receiverEnterCodeError;

  /// No description provided for @receiverConfirmCollectedCta.
  ///
  /// In en, this message translates to:
  /// **'Confirm collected'**
  String get receiverConfirmCollectedCta;

  /// No description provided for @receiverCollectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get receiverCollectedTitle;

  /// No description provided for @receiverCollectedMessage.
  ///
  /// In en, this message translates to:
  /// **'Good food, kept moving. Thank you.'**
  String get receiverCollectedMessage;

  /// No description provided for @receiverBackToFeedCta.
  ///
  /// In en, this message translates to:
  /// **'Back to feed'**
  String get receiverBackToFeedCta;

  /// No description provided for @receiverRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your requests'**
  String get receiverRequestsTitle;

  /// No description provided for @receiverRequestsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No active requests'**
  String get receiverRequestsEmptyTitle;

  /// No description provided for @receiverRequestsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Request a donation from the feed and it will show up here once matched.'**
  String get receiverRequestsEmptyMessage;

  /// No description provided for @receiverBrowseCta.
  ///
  /// In en, this message translates to:
  /// **'Browse nearby surplus'**
  String get receiverBrowseCta;

  /// No description provided for @receiverRequestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'From {donorName} · {count} portions'**
  String receiverRequestSubtitle(String donorName, int count);

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @donorHistoryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get donorHistoryEmptyTitle;

  /// No description provided for @donorHistoryEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Donations move here once they\'re collected, cancelled or expired.'**
  String get donorHistoryEmptyMessage;

  /// No description provided for @receiverHistoryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing collected yet'**
  String get receiverHistoryEmptyTitle;

  /// No description provided for @receiverHistoryEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Donations you\'ve collected will show up here.'**
  String get receiverHistoryEmptyMessage;

  /// No description provided for @historyDonorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} portions · {day}/{month}'**
  String historyDonorSubtitle(int count, int day, int month);

  /// No description provided for @historyReceiverSubtitle.
  ///
  /// In en, this message translates to:
  /// **'From {donorName} · {day}/{month}'**
  String historyReceiverSubtitle(String donorName, int day, int month);

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing yet'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'We\'ll let you know the moment something needs your attention.'**
  String get notificationsEmptyMessage;

  /// No description provided for @notifTimeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String notifTimeMinutes(int minutes);

  /// No description provided for @notifTimeHours.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String notifTimeHours(int hours);

  /// No description provided for @notifTimeDays.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String notifTimeDays(int days);

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileTagDonor.
  ///
  /// In en, this message translates to:
  /// **'Donor'**
  String get profileTagDonor;

  /// No description provided for @profileTagVerifiedNgo.
  ///
  /// In en, this message translates to:
  /// **'Verified NGO'**
  String get profileTagVerifiedNgo;

  /// No description provided for @profileLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguageLabel;

  /// No description provided for @profileLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get profileLanguageEnglish;

  /// No description provided for @profileHelpLabel.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get profileHelpLabel;

  /// No description provided for @profileSignOutCta.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOutCta;

  /// No description provided for @recurringTitle.
  ///
  /// In en, this message translates to:
  /// **'Recurring donations'**
  String get recurringTitle;

  /// No description provided for @recurringEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No recurring donations yet'**
  String get recurringEmptyTitle;

  /// No description provided for @recurringEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Set up a template for food you give away on a regular schedule — we\'ll ask you to confirm or skip each day.'**
  String get recurringEmptyMessage;

  /// No description provided for @recurringSetupCta.
  ///
  /// In en, this message translates to:
  /// **'Set up a template'**
  String get recurringSetupCta;

  /// No description provided for @recurringPostedTodayTag.
  ///
  /// In en, this message translates to:
  /// **'Posted today'**
  String get recurringPostedTodayTag;

  /// No description provided for @recurringSkippedTodayTag.
  ///
  /// In en, this message translates to:
  /// **'Skipped today'**
  String get recurringSkippedTodayTag;

  /// No description provided for @recurringCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} portions · {windowHours} hr window · {locality}'**
  String recurringCardSubtitle(int count, int windowHours, String locality);

  /// No description provided for @recurringSkipCta.
  ///
  /// In en, this message translates to:
  /// **'Skip today'**
  String get recurringSkipCta;

  /// No description provided for @recurringConfirmCta.
  ///
  /// In en, this message translates to:
  /// **'Confirm today'**
  String get recurringConfirmCta;

  /// No description provided for @recurringSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'New recurring template'**
  String get recurringSheetTitle;

  /// No description provided for @recurringFoodLabel.
  ///
  /// In en, this message translates to:
  /// **'What do you give away regularly?'**
  String get recurringFoodLabel;

  /// No description provided for @recurringFoodHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Leftover lunch buffet'**
  String get recurringFoodHint;

  /// No description provided for @recurringPortionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Portions'**
  String get recurringPortionsLabel;

  /// No description provided for @recurringWindowLabel.
  ///
  /// In en, this message translates to:
  /// **'Window'**
  String get recurringWindowLabel;

  /// No description provided for @recurringHoursShort.
  ///
  /// In en, this message translates to:
  /// **'{hours} hr'**
  String recurringHoursShort(int hours);

  /// No description provided for @recurringSaveCta.
  ///
  /// In en, this message translates to:
  /// **'Save template'**
  String get recurringSaveCta;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navRecurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get navRecurring;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get navAlerts;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get navRequests;

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
