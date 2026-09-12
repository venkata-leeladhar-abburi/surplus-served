// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get appTitle => 'మిగులు → వడ్డించబడింది';

  @override
  String get roleSelectTitle => 'మీరు Surplus → Served ని ఎలా ఉపయోగిస్తారు?';

  @override
  String get roleDonor => 'నా వద్ద ఆహారం ఉంది';

  @override
  String get roleReceiver => 'నేను ధృవీకరించిన NGO నడుపుతున్నాను';

  @override
  String get authPhoneTitle => 'మీ ఫోన్ నంబర్ నమోదు చేయండి';

  @override
  String get authPhoneHint => '10-అంకెల మొబైల్ నంబర్';

  @override
  String get authOtpTitle => 'మేము పంపిన కోడ్‌ను నమోదు చేయండి';

  @override
  String authOtpSubtitle(String phone) {
    return '$phoneకి పంపబడింది';
  }

  @override
  String get donorDashboardTitle => 'మీ విరాళాలు';

  @override
  String get donorCreateCta => 'మిగులు ఆహారాన్ని పోస్ట్ చేయండి';

  @override
  String get donorCreateStepDetails => 'ఏది సిద్ధంగా ఉంది?';

  @override
  String get donorCreateStepPortions => 'ఎన్ని వంతులు?';

  @override
  String get donorCreateStepWindow => 'పికప్ సమయం';

  @override
  String get donorCreateStepAddress => 'పికప్ చిరునామా';

  @override
  String get donorCreateStepReview => 'సమీక్షించి పోస్ట్ చేయండి';

  @override
  String get donorLiveTitle => 'లైవ్ — సరిపోలిక కోసం వేచి ఉంది';

  @override
  String get donorPickupCodeLabel => 'పికప్ కోడ్';

  @override
  String get receiverFeedTitle => 'సమీపంలోని మిగులు';

  @override
  String get receiverFeedEmptyTitle => 'ఇక్కడ ఇంకా ఏమీ లేదు';

  @override
  String get receiverFeedEmptyBody =>
      'సమీపంలోని కొత్త విరాళాలు లైవ్ అయిన వెంటనే ఇక్కడ కనిపిస్తాయి.';

  @override
  String get receiverRequestCta => 'దీన్ని అభ్యర్థించండి';

  @override
  String get receiverAllocatedTitle => 'మీకు కేటాయించబడింది';

  @override
  String get receiverEnterCodeCta => 'పికప్ కోడ్ నమోదు చేయండి';

  @override
  String get receiverEnterCodeTitle => 'అప్పగింతను నిర్ధారించండి';

  @override
  String get receiverCollectedTitle => 'సేకరించబడింది';

  @override
  String get statusDraft => 'డ్రాఫ్ట్';

  @override
  String get statusPendingCheck => 'సమీక్షలో ఉంది';

  @override
  String get statusLive => 'లైవ్';

  @override
  String get statusAllocated => 'కేటాయించబడింది';

  @override
  String get statusCollected => 'సేకరించబడింది';

  @override
  String get statusReallocated => 'తిరిగి కేటాయించబడింది';

  @override
  String get statusUnfulfilled => 'నెరవేరలేదు';

  @override
  String get statusCancelled => 'రద్దు చేయబడింది';

  @override
  String get statusRejected => 'తిరస్కరించబడింది';

  @override
  String get commonCancel => 'రద్దు చేయండి';

  @override
  String get commonBack => 'వెనుకకు';

  @override
  String get commonNext => 'తదుపరి';

  @override
  String get commonSubmit => 'సమర్పించండి';

  @override
  String get commonRetry => 'మళ్లీ ప్రయత్నించండి';

  @override
  String minutesShort(int minutes) {
    return '$minutes నిమి';
  }
}
