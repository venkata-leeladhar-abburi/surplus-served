/// Google Maps directions link for a pickup.
///
/// Uses the donor's pinned GPS point when there is one (exact), otherwise
/// the address text. Opens the Maps app if installed, else the browser.
/// Free to use: no API key needed.
Uri pickupDirectionsUri({
  required String address,
  double? latitude,
  double? longitude,
}) {
  final destination = latitude != null && longitude != null
      ? '$latitude,$longitude'
      : address;

  return Uri.https('www.google.com', '/maps/dir/', {
    'api': '1',
    'destination': destination,
  });
}
