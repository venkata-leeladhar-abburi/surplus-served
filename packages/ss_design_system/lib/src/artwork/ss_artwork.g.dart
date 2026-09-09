// GENERATED FILE — DO NOT EDIT.
// Source: design/assets/manifest.json (see design/tools/extract_artwork.py)
// Regenerate: python3 design/tools/extract_artwork.py && node design/tools/generate-artwork.mjs

import 'ss_artwork.dart';

/// The illustration set from §09 of the design document.
///
/// 40 illustrations, cropped from the document itself. Render with
/// [SsIllustration]:
///
/// ```dart
/// SsIllustration(SsIllustrations.noFoodAvailable, width: 160)
/// ```
///
/// Each entry carries its native pixel size. Going much beyond
/// [SsArtwork.nativeWidth] will look soft — the document is a flattened
/// raster and that is the resolution ceiling it contains.
abstract final class SsIllustrations {
  /// Download the app — be part of the change
  static const appPromotion = SsArtwork(
    name: 'appPromotion',
    asset: 'assets/illustrations/appPromotion.png',
    caption: "Download the app — be part of the change",
    nativeWidth: 122,
    nativeHeight: 141,
    set: 'promo',
  );

  /// A cleaner, greener planet
  static const cleanerPlanet = SsArtwork(
    name: 'cleanerPlanet',
    asset: 'assets/illustrations/cleanerPlanet.png',
    caption: "A cleaner, greener planet",
    nativeWidth: 158,
    nativeHeight: 86,
    set: 'community',
  );

  /// Community you can trust
  static const communityTrust = SsArtwork(
    name: 'communityTrust',
    asset: 'assets/illustrations/communityTrust.png',
    caption: "Community you can trust",
    nativeWidth: 120,
    nativeHeight: 72,
    set: 'trust',
  );

  /// Delivery completed — great job!
  static const deliveryCompleted = SsArtwork(
    name: 'deliveryCompleted',
    asset: 'assets/illustrations/deliveryCompleted.png',
    caption: "Delivery completed — great job!",
    nativeWidth: 110,
    nativeHeight: 88,
    set: 'success',
  );

  /// Food received — thank you!
  static const foodReceived = SsArtwork(
    name: 'foodReceived',
    asset: 'assets/illustrations/foodReceived.png',
    caption: "Food received — thank you!",
    nativeWidth: 127,
    nativeHeight: 90,
    set: 'success',
  );

  /// Food safety matters
  static const foodSafety = SsArtwork(
    name: 'foodSafety',
    asset: 'assets/illustrations/foodSafety.png',
    caption: "Food safety matters",
    nativeWidth: 117,
    nativeHeight: 87,
    set: 'trust',
  );

  /// Good food should be shared
  static const goodFoodShared = SsArtwork(
    name: 'goodFoodShared',
    asset: 'assets/illustrations/goodFoodShared.png',
    caption: "Good food should be shared",
    nativeWidth: 103,
    nativeHeight: 108,
    set: 'sustainability',
  );

  /// A healthier planet
  static const healthierPlanet = SsArtwork(
    name: 'healthierPlanet',
    asset: 'assets/illustrations/healthierPlanet.png',
    caption: "A healthier planet",
    nativeWidth: 111,
    nativeHeight: 129,
    set: 'onboarding',
  );

  /// Impact unlocked — you're making a difference
  static const impactUnlocked = SsArtwork(
    name: 'impactUnlocked',
    asset: 'assets/illustrations/impactUnlocked.png',
    caption: "Impact unlocked — you're making a difference",
    nativeWidth: 117,
    nativeHeight: 87,
    set: 'success',
  );

  /// Leaf motif
  static const leafMotif = SsArtwork(
    name: 'leafMotif',
    asset: 'assets/illustrations/leafMotif.png',
    caption: "Leaf motif",
    nativeWidth: 51,
    nativeHeight: 69,
    set: 'brand',
  );

  /// Less food waste
  static const lessFoodWaste = SsArtwork(
    name: 'lessFoodWaste',
    asset: 'assets/illustrations/lessFoodWaste.png',
    caption: "Less food waste",
    nativeWidth: 110,
    nativeHeight: 114,
    set: 'onboarding',
  );

  /// Let's get started
  static const letsGetStarted = SsArtwork(
    name: 'letsGetStarted',
    asset: 'assets/illustrations/letsGetStarted.png',
    caption: "Let's get started",
    nativeWidth: 99,
    nativeHeight: 132,
    set: 'onboarding',
  );

  /// Meals that matter
  static const mealsThatMatter = SsArtwork(
    name: 'mealsThatMatter',
    asset: 'assets/illustrations/mealsThatMatter.png',
    caption: "Meals that matter",
    nativeWidth: 180,
    nativeHeight: 84,
    set: 'community',
  );

  /// No food available — check back later
  static const noFoodAvailable = SsArtwork(
    name: 'noFoodAvailable',
    asset: 'assets/illustrations/noFoodAvailable.png',
    caption: "No food available — check back later",
    nativeWidth: 118,
    nativeHeight: 93,
    set: 'empty',
  );

  /// No requests yet — be the first to request
  static const noRequestsYet = SsArtwork(
    name: 'noRequestsYet',
    asset: 'assets/illustrations/noRequestsYet.png',
    caption: "No requests yet — be the first to request",
    nativeWidth: 110,
    nativeHeight: 100,
    set: 'empty',
  );

  /// No results found — try a different location or search
  static const noResultsFound = SsArtwork(
    name: 'noResultsFound',
    asset: 'assets/illustrations/noResultsFound.png',
    caption: "No results found — try a different location or search",
    nativeWidth: 94,
    nativeHeight: 91,
    set: 'empty',
  );

  /// Nothing here yet — good things come soon
  static const nothingHereYet = SsArtwork(
    name: 'nothingHereYet',
    asset: 'assets/illustrations/nothingHereYet.png',
    caption: "Nothing here yet — good things come soon",
    nativeWidth: 138,
    nativeHeight: 122,
    set: 'empty',
  );

  /// Nourish people
  static const nourishPeople = SsArtwork(
    name: 'nourishPeople',
    asset: 'assets/illustrations/nourishPeople.png',
    caption: "Nourish people",
    nativeWidth: 94,
    nativeHeight: 102,
    set: 'sustainability',
  );

  /// You're offline — check your connection
  static const offline = SsArtwork(
    name: 'offline',
    asset: 'assets/illustrations/offline.png',
    caption: "You're offline — check your connection",
    nativeWidth: 137,
    nativeHeight: 80,
    set: 'error',
  );

  /// Welcome to a kinder tomorrow
  static const onboardingWelcome = SsArtwork(
    name: 'onboardingWelcome',
    asset: 'assets/illustrations/onboardingWelcome.png',
    caption: "Welcome to a kinder tomorrow",
    nativeWidth: 129,
    nativeHeight: 129,
    set: 'onboarding',
  );

  /// Allocated
  static const progressAllocated = SsArtwork(
    name: 'progressAllocated',
    asset: 'assets/illustrations/progressAllocated.png',
    caption: "Allocated",
    nativeWidth: 81,
    nativeHeight: 77,
    set: 'progress',
  );

  /// Collected
  static const progressCollected = SsArtwork(
    name: 'progressCollected',
    asset: 'assets/illustrations/progressCollected.png',
    caption: "Collected",
    nativeWidth: 87,
    nativeHeight: 80,
    set: 'progress',
  );

  /// In transit
  static const progressInTransit = SsArtwork(
    name: 'progressInTransit',
    asset: 'assets/illustrations/progressInTransit.png',
    caption: "In transit",
    nativeWidth: 78,
    nativeHeight: 75,
    set: 'progress',
  );

  /// Submitted
  static const progressSubmitted = SsArtwork(
    name: 'progressSubmitted',
    asset: 'assets/illustrations/progressSubmitted.png',
    caption: "Submitted",
    nativeWidth: 64,
    nativeHeight: 75,
    set: 'progress',
  );

  /// Under review
  static const progressUnderReview = SsArtwork(
    name: 'progressUnderReview',
    asset: 'assets/illustrations/progressUnderReview.png',
    caption: "Under review",
    nativeWidth: 63,
    nativeHeight: 80,
    set: 'progress',
  );

  /// Protect our planet
  static const protectPlanet = SsArtwork(
    name: 'protectPlanet',
    asset: 'assets/illustrations/protectPlanet.png',
    caption: "Protect our planet",
    nativeWidth: 110,
    nativeHeight: 108,
    set: 'sustainability',
  );

  /// Real people. Real change.
  static const realPeople = SsArtwork(
    name: 'realPeople',
    asset: 'assets/illustrations/realPeople.png',
    caption: "Real people. Real change.",
    nativeWidth: 168,
    nativeHeight: 87,
    set: 'community',
  );

  /// Reduce food waste
  static const reduceFoodWaste = SsArtwork(
    name: 'reduceFoodWaste',
    asset: 'assets/illustrations/reduceFoodWaste.png',
    caption: "Reduce food waste",
    nativeWidth: 98,
    nativeHeight: 116,
    set: 'sustainability',
  );

  /// Request submitted — we'll keep you updated
  static const requestSubmitted = SsArtwork(
    name: 'requestSubmitted',
    asset: 'assets/illustrations/requestSubmitted.png',
    caption: "Request submitted — we'll keep you updated",
    nativeWidth: 90,
    nativeHeight: 83,
    set: 'success',
  );

  /// I'm an admin — manage and monitor
  static const roleAdmin = SsArtwork(
    name: 'roleAdmin',
    asset: 'assets/illustrations/roleAdmin.png',
    caption: "I'm an admin — manage and monitor",
    nativeWidth: 129,
    nativeHeight: 126,
    set: 'role',
  );

  /// I'm a donor — share surplus food
  static const roleDonor = SsArtwork(
    name: 'roleDonor',
    asset: 'assets/illustrations/roleDonor.png',
    caption: "I'm a donor — share surplus food",
    nativeWidth: 132,
    nativeHeight: 132,
    set: 'role',
  );

  /// I'm a receiver — get food support
  static const roleReceiver = SsArtwork(
    name: 'roleReceiver',
    asset: 'assets/illustrations/roleReceiver.png',
    caption: "I'm a receiver — get food support",
    nativeWidth: 129,
    nativeHeight: 126,
    set: 'role',
  );

  /// I'm a volunteer — deliver hope
  static const roleVolunteer = SsArtwork(
    name: 'roleVolunteer',
    asset: 'assets/illustrations/roleVolunteer.png',
    caption: "I'm a volunteer — deliver hope",
    nativeWidth: 135,
    nativeHeight: 129,
    set: 'role',
  );

  /// Safe food, healthy people
  static const safeFood = SsArtwork(
    name: 'safeFood',
    asset: 'assets/illustrations/safeFood.png',
    caption: "Safe food, healthy people",
    nativeWidth: 115,
    nativeHeight: 75,
    set: 'trust',
  );

  /// Small actions. Big impact.
  static const smallActionsBigImpact = SsArtwork(
    name: 'smallActionsBigImpact',
    asset: 'assets/illustrations/smallActionsBigImpact.png',
    caption: "Small actions. Big impact.",
    nativeWidth: 182,
    nativeHeight: 94,
    set: 'community',
  );

  /// Something went wrong — please try again
  static const somethingWentWrong = SsArtwork(
    name: 'somethingWentWrong',
    asset: 'assets/illustrations/somethingWentWrong.png',
    caption: "Something went wrong — please try again",
    nativeWidth: 138,
    nativeHeight: 85,
    set: 'error',
  );

  /// Stronger communities
  static const strongerCommunities = SsArtwork(
    name: 'strongerCommunities',
    asset: 'assets/illustrations/strongerCommunities.png',
    caption: "Stronger communities",
    nativeWidth: 120,
    nativeHeight: 120,
    set: 'onboarding',
  );

  /// Today's surplus. Tomorrow's hope.
  static const todaysSurplus = SsArtwork(
    name: 'todaysSurplus',
    asset: 'assets/illustrations/todaysSurplus.png',
    caption: "Today's surplus. Tomorrow's hope.",
    nativeWidth: 189,
    nativeHeight: 84,
    set: 'community',
  );

  /// Together for stronger communities
  static const togetherCommunities = SsArtwork(
    name: 'togetherCommunities',
    asset: 'assets/illustrations/togetherCommunities.png',
    caption: "Together for stronger communities",
    nativeWidth: 184,
    nativeHeight: 78,
    set: 'community',
  );

  /// Verified donor, trusted food
  static const verifiedDonor = SsArtwork(
    name: 'verifiedDonor',
    asset: 'assets/illustrations/verifiedDonor.png',
    caption: "Verified donor, trusted food",
    nativeWidth: 118,
    nativeHeight: 90,
    set: 'trust',
  );

  static const Map<String, SsArtwork> all = <String, SsArtwork>{
    'appPromotion': appPromotion,
    'cleanerPlanet': cleanerPlanet,
    'communityTrust': communityTrust,
    'deliveryCompleted': deliveryCompleted,
    'foodReceived': foodReceived,
    'foodSafety': foodSafety,
    'goodFoodShared': goodFoodShared,
    'healthierPlanet': healthierPlanet,
    'impactUnlocked': impactUnlocked,
    'leafMotif': leafMotif,
    'lessFoodWaste': lessFoodWaste,
    'letsGetStarted': letsGetStarted,
    'mealsThatMatter': mealsThatMatter,
    'noFoodAvailable': noFoodAvailable,
    'noRequestsYet': noRequestsYet,
    'noResultsFound': noResultsFound,
    'nothingHereYet': nothingHereYet,
    'nourishPeople': nourishPeople,
    'offline': offline,
    'onboardingWelcome': onboardingWelcome,
    'progressAllocated': progressAllocated,
    'progressCollected': progressCollected,
    'progressInTransit': progressInTransit,
    'progressSubmitted': progressSubmitted,
    'progressUnderReview': progressUnderReview,
    'protectPlanet': protectPlanet,
    'realPeople': realPeople,
    'reduceFoodWaste': reduceFoodWaste,
    'requestSubmitted': requestSubmitted,
    'roleAdmin': roleAdmin,
    'roleDonor': roleDonor,
    'roleReceiver': roleReceiver,
    'roleVolunteer': roleVolunteer,
    'safeFood': safeFood,
    'smallActionsBigImpact': smallActionsBigImpact,
    'somethingWentWrong': somethingWentWrong,
    'strongerCommunities': strongerCommunities,
    'todaysSurplus': todaysSurplus,
    'togetherCommunities': togetherCommunities,
    'verifiedDonor': verifiedDonor,
  };

  /// Illustrations grouped by the section of §09 they came from.
  static const Map<String, List<SsArtwork>> bySet = <String, List<SsArtwork>>{
    'promo': <SsArtwork>[appPromotion],
    'community': <SsArtwork>[cleanerPlanet, mealsThatMatter, realPeople, smallActionsBigImpact, todaysSurplus, togetherCommunities],
    'trust': <SsArtwork>[communityTrust, foodSafety, safeFood, verifiedDonor],
    'success': <SsArtwork>[deliveryCompleted, foodReceived, impactUnlocked, requestSubmitted],
    'sustainability': <SsArtwork>[goodFoodShared, nourishPeople, protectPlanet, reduceFoodWaste],
    'onboarding': <SsArtwork>[healthierPlanet, lessFoodWaste, letsGetStarted, onboardingWelcome, strongerCommunities],
    'brand': <SsArtwork>[leafMotif],
    'empty': <SsArtwork>[noFoodAvailable, noRequestsYet, noResultsFound, nothingHereYet],
    'error': <SsArtwork>[offline, somethingWentWrong],
    'progress': <SsArtwork>[progressAllocated, progressCollected, progressInTransit, progressSubmitted, progressUnderReview],
    'role': <SsArtwork>[roleAdmin, roleDonor, roleReceiver, roleVolunteer],
  };
}

/// The logo and brand marks from §02 of the design document.
abstract final class SsBrandArt {
  /// Surplus → Served — primary horizontal logo
  static const logoHorizontal = SsArtwork(
    name: 'logoHorizontal',
    asset: 'assets/brand/logoHorizontal.png',
    caption: "Surplus → Served — primary horizontal logo",
    nativeWidth: 255,
    nativeHeight: 54,
  );

  /// Surplus → Served — stacked logo
  static const logoStacked = SsArtwork(
    name: 'logoStacked',
    asset: 'assets/brand/logoStacked.png',
    caption: "Surplus → Served — stacked logo",
    nativeWidth: 115,
    nativeHeight: 115,
  );

  /// Surplus → Served — icon only
  static const logoIcon = SsArtwork(
    name: 'logoIcon',
    asset: 'assets/brand/logoIcon.png',
    caption: "Surplus → Served — icon only",
    nativeWidth: 87,
    nativeHeight: 84,
  );

  /// Leaf mark
  static const leafMark = SsArtwork(
    name: 'leafMark',
    asset: 'assets/brand/leafMark.png',
    caption: "Leaf mark",
    nativeWidth: 78,
    nativeHeight: 86,
  );

  /// Movement thread — the arrow that shows food in motion
  static const movementArrow = SsArtwork(
    name: 'movementArrow',
    asset: 'assets/brand/movementArrow.png',
    caption: "Movement thread — the arrow that shows food in motion",
    nativeWidth: 81,
    nativeHeight: 70,
  );

  static const Map<String, SsArtwork> all = <String, SsArtwork>{
    'logoHorizontal': logoHorizontal,
    'logoStacked': logoStacked,
    'logoIcon': logoIcon,
    'leafMark': leafMark,
    'movementArrow': movementArrow,
  };
}
