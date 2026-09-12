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
  String get splashTagline => 'మంచి ఆహారం ఎప్పటికీ కదులుతూనే ఉండాలి.';

  @override
  String get roleSelectTitle => 'మీరు Surplus → Served ని ఎలా ఉపయోగిస్తారు?';

  @override
  String get roleDonor => 'నా వద్ద ఆహారం ఉంది';

  @override
  String get roleDonorSubtitle => 'రెస్టారెంట్లు, క్యాటరర్లు, ఈవెంట్ కిచెన్‌లు';

  @override
  String get roleReceiver => 'నేను ధృవీకరించిన NGO నడుపుతున్నాను';

  @override
  String get roleReceiverSubtitle =>
      'అవసరమైన వారికి మిగులు ఆహారాన్ని సేకరించండి';

  @override
  String get authPhoneTitle => 'మీ ఫోన్ నంబర్ నమోదు చేయండి';

  @override
  String get authPhoneSubtitle =>
      'మీరేనని నిర్ధారించడానికి మేము మీకు వన్-టైమ్ కోడ్‌ను పంపుతాము.';

  @override
  String get authPhoneHint => '10-అంకెల మొబైల్ నంబర్';

  @override
  String get authPhoneError => 'కోడ్ పంపడం సాధ్యం కాలేదు. మళ్లీ ప్రయత్నించండి.';

  @override
  String get authSendCodeCta => 'కోడ్ పంపండి';

  @override
  String get authOtpTitle => 'మేము పంపిన కోడ్‌ను నమోదు చేయండి';

  @override
  String authOtpSubtitle(String phone) {
    return '$phoneకి పంపబడింది';
  }

  @override
  String get authOtpCodeLabel => '4-అంకెల కోడ్';

  @override
  String get authOtpError => 'ఆ కోడ్ పని చేయలేదు. మళ్లీ ప్రయత్నించండి.';

  @override
  String get authVerifyCta => 'ధృవీకరించండి';

  @override
  String commonError(String error) {
    return 'ఏదో తప్పు జరిగింది: $error';
  }

  @override
  String commonPortionsLabel(int count) {
    return '$count వంతులు';
  }

  @override
  String get commonPickupAddressLabel => 'పికప్ చిరునామా';

  @override
  String get commonLocality => 'ప్రాంతం';

  @override
  String timeLeftMinutes(int minutes) {
    return '$minutes నిమిషాలు మిగిలి ఉన్నాయి';
  }

  @override
  String timeLeftHours(int hours) {
    return '$hours గంటలు మిగిలి ఉన్నాయి';
  }

  @override
  String get donorDashboardTitle => 'మీ విరాళాలు';

  @override
  String get donorDashboardEmptyTitle => 'ఇంకా ఏమీ పోస్ట్ చేయలేదు';

  @override
  String donorDashboardEmptyMessage(String name) {
    return 'హాయ్ $name — మీ మొదటి మిగులు బ్యాచ్‌ను పోస్ట్ చేయండి, అది వెంటనే లైవ్ అవుతుంది.';
  }

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
  String get donorCreateFoodLabel => 'అది ఏమిటి?';

  @override
  String get donorCreateFoodHint => 'ఉదా. కూరగాయల బిర్యానీ, 40 వంతులు';

  @override
  String get donorCreateNotesLabel =>
      'NGO తెలుసుకోవలసినది ఏదైనా ఉందా? (ఐచ్ఛికం)';

  @override
  String get donorCreatePortionsMinusTooltip => 'వంతులు తగ్గించండి';

  @override
  String get donorCreatePortionsPlusTooltip => 'వంతులు పెంచండి';

  @override
  String get donorCreatePortionsUnit => 'వంతులు';

  @override
  String get donorCreateWindowSubtitle =>
      'NGO దీన్ని సురక్షితంగా ఎంత సేపు సేకరించగలదు?';

  @override
  String donorCreateWindowOption(num hours) {
    final intl.NumberFormat hoursNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String hoursString = hoursNumberFormat.format(hours);

    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hoursString గంటలు',
      one: '1 గంట',
    );
    return '$_temp0';
  }

  @override
  String get donorCreateAddressPrivacyNote =>
      'NGO సరిపోలిక అయ్యే వరకు ప్రాంతం మాత్రమే చూపబడుతుంది — ఖచ్చితమైన చిరునామా వారికి మాత్రమే పంచుకోబడుతుంది (§11).';

  @override
  String get donorCreateLocalityHint => 'ఉదా. జూబ్లీ హిల్స్, హైదరాబాద్';

  @override
  String get donorCreateReviewFoodLabel => 'ఆహారం';

  @override
  String get donorCreateReviewPortionsLabel => 'వంతులు';

  @override
  String get donorCreateReviewWindowLabel => 'పికప్ సమయం';

  @override
  String get donorCreateReviewLocalityLabel => 'ప్రాంతం';

  @override
  String donorCreateReviewWindowValue(int hours) {
    return 'పోస్ట్ చేసినప్పటి నుండి $hours గం';
  }

  @override
  String get donorCreateLiveAlert =>
      'ఇది వెంటనే లైవ్ అవుతుంది మరియు సమీపంలోని NGOలకు కనిపిస్తుంది.';

  @override
  String get donorLiveTitle => 'లైవ్ — సరిపోలిక కోసం వేచి ఉంది';

  @override
  String get donorLiveAlert =>
      'లైవ్ — సమీపంలోని NGOలకు కనిపిస్తుంది. ఎవరైనా అభ్యర్థించిన వెంటనే మేము మీకు తెలియజేస్తాము.';

  @override
  String donorAllocatedAlert(String ngoName) {
    return '$ngoName మార్గంలో ఉంది. అప్పగింత వద్ద ఈ కోడ్‌ను పంచుకోండి.';
  }

  @override
  String get donorPickupCodeLabel => 'పికప్ కోడ్';

  @override
  String get donorPickupCodeCaption =>
      'ఆహారాన్ని అందించే ముందు ఈ కోడ్‌ను అడగండి.';

  @override
  String donorCollectedByLabel(String ngoName) {
    return '$ngoName ద్వారా సేకరించబడింది';
  }

  @override
  String get donorCancelCta => 'విరాళాన్ని రద్దు చేయండి';

  @override
  String get receiverFeedTitle => 'సమీపంలోని మిగులు';

  @override
  String get receiverFeedEmptyTitle => 'ఇక్కడ ఇంకా ఏమీ లేదు';

  @override
  String get receiverFeedEmptyBody =>
      'సమీపంలోని కొత్త విరాళాలు లైవ్ అయిన వెంటనే ఇక్కడ కనిపిస్తాయి.';

  @override
  String receiverFromDonorLabel(String donorName) {
    return '$donorName నుండి';
  }

  @override
  String get receiverRequestCta => 'దీన్ని అభ్యర్థించండి';

  @override
  String get receiverAllocatedTitle => 'మీకు కేటాయించబడింది';

  @override
  String get receiverEnterCodeCta => 'పికప్ కోడ్ నమోదు చేయండి';

  @override
  String get receiverEnterCodeTitle => 'అప్పగింతను నిర్ధారించండి';

  @override
  String get receiverEnterCodeSubtitle =>
      'వారి స్క్రీన్‌పై చూపిన 4-అంకెల కోడ్ కోసం దాతను అడగండి.';

  @override
  String get receiverEnterCodeError =>
      'ఆ కోడ్ సరిపోలలేదు. దాతతో తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get receiverConfirmCollectedCta => 'సేకరించినట్లు నిర్ధారించండి';

  @override
  String get receiverCollectedTitle => 'సేకరించబడింది';

  @override
  String get receiverCollectedMessage =>
      'మంచి ఆహారం, కదులుతూనే ఉంది. ధన్యవాదాలు.';

  @override
  String get receiverBackToFeedCta => 'ఫీడ్‌కు తిరిగి వెళ్ళండి';

  @override
  String get receiverRequestsTitle => 'మీ అభ్యర్థనలు';

  @override
  String get receiverRequestsEmptyTitle => 'క్రియాశీల అభ్యర్థనలు లేవు';

  @override
  String get receiverRequestsEmptyMessage =>
      'ఫీడ్ నుండి ఒక విరాళాన్ని అభ్యర్థించండి, అది సరిపోలిన తర్వాత ఇక్కడ కనిపిస్తుంది.';

  @override
  String get receiverBrowseCta => 'సమీపంలోని మిగులును బ్రౌజ్ చేయండి';

  @override
  String receiverRequestSubtitle(String donorName, int count) {
    return '$donorName నుండి · $count వంతులు';
  }

  @override
  String get historyTitle => 'చరిత్ర';

  @override
  String get donorHistoryEmptyTitle => 'ఇంకా ఏమీ లేదు';

  @override
  String get donorHistoryEmptyMessage =>
      'విరాళాలు సేకరించిన, రద్దు చేసిన లేదా గడువు ముగిసిన తర్వాత ఇక్కడకు చేరతాయి.';

  @override
  String get receiverHistoryEmptyTitle => 'ఇంకా ఏమీ సేకరించలేదు';

  @override
  String get receiverHistoryEmptyMessage =>
      'మీరు సేకరించిన విరాళాలు ఇక్కడ కనిపిస్తాయి.';

  @override
  String historyDonorSubtitle(int count, int day, int month) {
    return '$count వంతులు · $day/$month';
  }

  @override
  String historyReceiverSubtitle(String donorName, int day, int month) {
    return '$donorName నుండి · $day/$month';
  }

  @override
  String get notificationsTitle => 'నోటిఫికేషన్‌లు';

  @override
  String get notificationsEmptyTitle => 'ఇంకా ఏమీ లేదు';

  @override
  String get notificationsEmptyMessage =>
      'ఏదైనా మీ దృష్టికి అవసరమైన వెంటనే మేము మీకు తెలియజేస్తాము.';

  @override
  String notifTimeMinutes(int minutes) {
    return '$minutes ని. క్రితం';
  }

  @override
  String notifTimeHours(int hours) {
    return '$hours గం. క్రితం';
  }

  @override
  String notifTimeDays(int days) {
    return '$days రోజుల క్రితం';
  }

  @override
  String get profileTitle => 'ప్రొఫైల్';

  @override
  String get profileTagDonor => 'దాత';

  @override
  String get profileTagVerifiedNgo => 'ధృవీకరించిన NGO';

  @override
  String get profileLanguageLabel => 'భాష';

  @override
  String get profileLanguageEnglish => 'ఇంగ్లీష్';

  @override
  String get profileHelpLabel => 'సహాయం & మద్దతు';

  @override
  String get profileSignOutCta => 'సైన్ అవుట్';

  @override
  String get recurringTitle => 'పునరావృత విరాళాలు';

  @override
  String get recurringEmptyTitle => 'ఇంకా పునరావృత విరాళాలు లేవు';

  @override
  String get recurringEmptyMessage =>
      'మీరు క్రమం తప్పకుండా ఇచ్చే ఆహారం కోసం ఒక టెంప్లేట్‌ను సెటప్ చేయండి — ప్రతిరోజూ నిర్ధారించమని లేదా దాటవేయమని మేము అడుగుతాము.';

  @override
  String get recurringSetupCta => 'టెంప్లేట్‌ను సెటప్ చేయండి';

  @override
  String get recurringPostedTodayTag => 'ఈరోజు పోస్ట్ చేయబడింది';

  @override
  String get recurringSkippedTodayTag => 'ఈరోజు దాటవేయబడింది';

  @override
  String recurringCardSubtitle(int count, int windowHours, String locality) {
    return '$count వంతులు · $windowHours గం విండో · $locality';
  }

  @override
  String get recurringSkipCta => 'ఈరోజు దాటవేయండి';

  @override
  String get recurringConfirmCta => 'ఈరోజు నిర్ధారించండి';

  @override
  String get recurringSheetTitle => 'కొత్త పునరావృత టెంప్లేట్';

  @override
  String get recurringFoodLabel => 'మీరు క్రమం తప్పకుండా ఏమి ఇస్తారు?';

  @override
  String get recurringFoodHint => 'ఉదా. మిగిలిన లంచ్ బఫే';

  @override
  String get recurringPortionsLabel => 'వంతులు';

  @override
  String get recurringWindowLabel => 'విండో';

  @override
  String recurringHoursShort(int hours) {
    return '$hours గం';
  }

  @override
  String get recurringSaveCta => 'టెంప్లేట్‌ను సేవ్ చేయండి';

  @override
  String get navHome => 'హోమ్';

  @override
  String get navRecurring => 'పునరావృతం';

  @override
  String get navHistory => 'చరిత్ర';

  @override
  String get navAlerts => 'అలర్ట్‌లు';

  @override
  String get navProfile => 'ప్రొఫైల్';

  @override
  String get navRequests => 'అభ్యర్థనలు';

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
