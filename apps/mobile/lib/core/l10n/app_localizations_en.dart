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
  String get roleSelectTitle => 'How will you use Surplus → Served?';

  @override
  String get roleDonor => 'I have food to give';

  @override
  String get roleReceiver => 'I run a verified NGO';

  @override
  String get authPhoneTitle => 'Enter your phone number';

  @override
  String get authPhoneHint => '10-digit mobile number';

  @override
  String get authOtpTitle => 'Enter the code we sent';

  @override
  String authOtpSubtitle(String phone) {
    return 'Sent to $phone';
  }

  @override
  String get donorDashboardTitle => 'Your donations';

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
  String get donorLiveTitle => 'Live — waiting for a match';

  @override
  String get donorPickupCodeLabel => 'Pickup code';

  @override
  String get receiverFeedTitle => 'Nearby surplus';

  @override
  String get receiverFeedEmptyTitle => 'Nothing here yet';

  @override
  String get receiverFeedEmptyBody =>
      'New donations nearby will show up here the moment they go live.';

  @override
  String get receiverRequestCta => 'Request this';

  @override
  String get receiverAllocatedTitle => 'Allocated to you';

  @override
  String get receiverEnterCodeCta => 'Enter pickup code';

  @override
  String get receiverEnterCodeTitle => 'Confirm handover';

  @override
  String get receiverCollectedTitle => 'Collected';

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
