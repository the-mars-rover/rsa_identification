//TODO: Add passport implementation
class Passport {
  /// Returns a `Passport` instance from the String read from the machine-readable zone
  /// of a Passport.
  ///
  /// The mrzText is expected to be in the standard machine-readable zone text format,
  /// see https://en.wikipedia.org/wiki/Machine-readable_passport#Nationality_codes_and_checksum_calculation
  ///
  /// If the format above is not adhered to an a [FormatException] will be thrown.
  factory Passport.fromMachineReadableZone(String mrzText) {
    try {
      return null;
    } catch (e) {
      throw FormatException(
          'Could not instantiate Smart ID from given barcode String: $e');
    }
  }
}