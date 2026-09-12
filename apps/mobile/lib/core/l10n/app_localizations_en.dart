// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Surplus → Served';

  @override
  String get splashTagline => 'Good food should keep moving.';

  @override
  String get roleSelectTitle => 'How will you use Surplus → Served?';

  @override
  String get roleDonor => 'I have food to give';

  @override
  String get roleDonorSubtitle => 'Restaurants, caterers, event kitchens';

  @override
  String get roleReceiver => 'I run a verified NGO';

  @override
  String get roleReceiverSubtitle =>
      'Collect surplus food for people who need it';

  @override
  String get authPhoneTitle => 'Enter your phone number';

  @override
  String get authPhoneSubtitle =>
      'We\'ll text you a one-time code to confirm it\'s you.';

  @override
  String get authPhoneHint => '10-digit mobile number';

  @override
  String get authPhoneError => 'Could not send the code. Try again.';

  @override
  String get authSendCodeCta => 'Send code';

  @override
  String get authOtpTitle => 'Enter the code we sent';

  @override
  String authOtpSubtitle(String phone) {
    return 'Sent to $phone';
  }

  @override
  String get authOtpCodeLabel => '4-digit code';

  @override
  String get authOtpError => 'That code didn\'t work. Try again.';

  @override
  String get authVerifyCta => 'Verify';

  @override
  String commonError(String error) {
    return 'Something went wrong: $error';
  }

  @override
  String commonPortionsLabel(int count) {
    return '$count portions';
  }

  @override
  String get commonPickupAddressLabel => 'Pickup address';

  @override
  String get commonLocality => 'Locality';

  @override
  String timeLeftMinutes(int minutes) {
    return '$minutes min left';
  }

  @override
  String timeLeftHours(int hours) {
    return '$hours hr left';
  }

  @override
  String get donorDashboardTitle => 'Your donations';

  @override
  String get donorDashboardEmptyTitle => 'Nothing posted yet';

  @override
  String donorDashboardEmptyMessage(String name) {
    return 'Hi $name — post your first surplus batch and it goes live instantly.';
  }

  @override
  String get donorCreateCta => 'Post surplus food';

  @override
  String get donorCreateStepDetails => 'What\'s ready to go?';

  @override
  String get donorCreateStepPortions => 'How many portions?';

  @override
  String get donorCreateStepWindow => 'Pickup window';

  @override
  String get donorCreateStepAddress => 'Pickup address';

  @override
  String get donorCreateStepReview => 'Review and post';

  @override
  String get donorCreateFoodLabel => 'What is it?';

  @override
  String get donorCreateFoodHint => 'e.g. Vegetable biryani, 40 portions';

  @override
  String get donorCreateNotesLabel => 'Anything an NGO should know? (optional)';

  @override
  String get donorCreatePortionsMinusTooltip => 'Fewer portions';

  @override
  String get donorCreatePortionsPlusTooltip => 'More portions';

  @override
  String get donorCreatePortionsUnit => 'portions';

  @override
  String get donorCreateWindowSubtitle =>
      'How long can an NGO safely collect this for?';

  @override
  String donorCreateWindowOption(num hours) {
    final intl.NumberFormat hoursNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String hoursString = hoursNumberFormat.format(hours);

    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hoursString hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String get donorCreateAddressPrivacyNote =>
      'Only the locality is shown until an NGO is matched — the exact address is shared with them alone (§11).';

  @override
  String get donorCreateLocalityHint => 'e.g. Jubilee Hills, Hyderabad';

  @override
  String get donorCreateReviewFoodLabel => 'Food';

  @override
  String get donorCreateReviewPortionsLabel => 'Portions';

  @override
  String get donorCreateReviewWindowLabel => 'Pickup window';

  @override
  String get donorCreateReviewLocalityLabel => 'Locality';

  @override
  String donorCreateReviewWindowValue(int hours) {
    return '$hours hr from posting';
  }

  @override
  String get donorCreateLiveAlert =>
      'This goes live immediately and is visible to nearby NGOs.';

  @override
  String get donorLiveTitle => 'Live — waiting for a match';

  @override
  String get donorLiveAlert =>
      'Live — visible to nearby NGOs. We\'ll notify you the moment one requests it.';

  @override
  String donorAllocatedAlert(String ngoName) {
    return '$ngoName is on the way. Share this code at handover.';
  }

  @override
  String get donorPickupCodeLabel => 'Pickup code';

  @override
  String get donorPickupCodeCaption =>
      'Ask for this code before handing over the food.';

  @override
  String donorCollectedByLabel(String ngoName) {
    return 'Collected by $ngoName';
  }

  @override
  String get donorCancelCta => 'Cancel donation';

  @override
  String get receiverFeedTitle => 'Nearby surplus';

  @override
  String get receiverFeedEmptyTitle => 'Nothing here yet';

  @override
  String get receiverFeedEmptyBody =>
      'New donations nearby will show up here the moment they go live.';

  @override
  String receiverFromDonorLabel(String donorName) {
    return 'From $donorName';
  }

  @override
  String get receiverRequestCta => 'Request this';

  @override
  String get receiverAllocatedTitle => 'Allocated to you';

  @override
  String get receiverEnterCodeCta => 'Enter pickup code';

  @override
  String get receiverEnterCodeTitle => 'Confirm handover';

  @override
  String get receiverEnterCodeSubtitle =>
      'Ask the donor for the 4-digit code shown on their screen.';

  @override
  String get receiverEnterCodeError =>
      'That code doesn\'t match. Check with the donor and try again.';

  @override
  String get receiverConfirmCollectedCta => 'Confirm collected';

  @override
  String get receiverCollectedTitle => 'Collected';

  @override
  String get receiverCollectedMessage => 'Good food, kept moving. Thank you.';

  @override
  String get receiverBackToFeedCta => 'Back to feed';

  @override
  String get receiverRequestsTitle => 'Your requests';

  @override
  String get receiverRequestsEmptyTitle => 'No active requests';

  @override
  String get receiverRequestsEmptyMessage =>
      'Request a donation from the feed and it will show up here once matched.';

  @override
  String get receiverBrowseCta => 'Browse nearby surplus';

  @override
  String receiverRequestSubtitle(String donorName, int count) {
    return 'From $donorName · $count portions';
  }

  @override
  String get historyTitle => 'History';

  @override
  String get donorHistoryEmptyTitle => 'Nothing here yet';

  @override
  String get donorHistoryEmptyMessage =>
      'Donations move here once they\'re collected, cancelled or expired.';

  @override
  String get receiverHistoryEmptyTitle => 'Nothing collected yet';

  @override
  String get receiverHistoryEmptyMessage =>
      'Donations you\'ve collected will show up here.';

  @override
  String historyDonorSubtitle(int count, int day, int month) {
    return '$count portions · $day/$month';
  }

  @override
  String historyReceiverSubtitle(String donorName, int day, int month) {
    return 'From $donorName · $day/$month';
  }

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmptyTitle => 'Nothing yet';

  @override
  String get notificationsEmptyMessage =>
      'We\'ll let you know the moment something needs your attention.';

  @override
  String notifTimeMinutes(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String notifTimeHours(int hours) {
    return '${hours}h ago';
  }

  @override
  String notifTimeDays(int days) {
    return '${days}d ago';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileTagDonor => 'Donor';

  @override
  String get profileTagVerifiedNgo => 'Verified NGO';

  @override
  String get profileLanguageLabel => 'Language';

  @override
  String get profileLanguageEnglish => 'English';

  @override
  String get profileHelpLabel => 'Help & support';

  @override
  String get profileSignOutCta => 'Sign out';

  @override
  String get recurringTitle => 'Recurring donations';

  @override
  String get recurringEmptyTitle => 'No recurring donations yet';

  @override
  String get recurringEmptyMessage =>
      'Set up a template for food you give away on a regular schedule — we\'ll ask you to confirm or skip each day.';

  @override
  String get recurringSetupCta => 'Set up a template';

  @override
  String get recurringPostedTodayTag => 'Posted today';

  @override
  String get recurringSkippedTodayTag => 'Skipped today';

  @override
  String recurringCardSubtitle(int count, int windowHours, String locality) {
    return '$count portions · $windowHours hr window · $locality';
  }

  @override
  String get recurringSkipCta => 'Skip today';

  @override
  String get recurringConfirmCta => 'Confirm today';

  @override
  String get recurringSheetTitle => 'New recurring template';

  @override
  String get recurringFoodLabel => 'What do you give away regularly?';

  @override
  String get recurringFoodHint => 'e.g. Leftover lunch buffet';

  @override
  String get recurringPortionsLabel => 'Portions';

  @override
  String get recurringWindowLabel => 'Window';

  @override
  String recurringHoursShort(int hours) {
    return '$hours hr';
  }

  @override
  String get recurringSaveCta => 'Save template';

  @override
  String get navHome => 'Home';

  @override
  String get navRecurring => 'Recurring';

  @override
  String get navHistory => 'History';

  @override
  String get navAlerts => 'Alerts';

  @override
  String get navProfile => 'Profile';

  @override
  String get navRequests => 'Requests';

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusPendingCheck => 'Under review';

  @override
  String get statusLive => 'Live';

  @override
  String get statusAllocated => 'Allocated';

  @override
  String get statusCollected => 'Collected';

  @override
  String get statusReallocated => 'Reallocated';

  @override
  String get statusUnfulfilled => 'Unfulfilled';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonBack => 'Back';

  @override
  String get commonNext => 'Next';

  @override
  String get commonSubmit => 'Submit';

  @override
  String get commonRetry => 'Try again';

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }
}
