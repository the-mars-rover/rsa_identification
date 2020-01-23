import 'dart:typed_data';

import 'drivers_license.dart';
import 'smart_id.dart';

/// A South African identification document. This may be either a [SmartId] or
/// a [DriversLicense].
abstract class IdDocument {
  /// The ID Number of the person to whom this document belongs.
  final String idNumber;

  /// The first names of the person to whom this document belongs.
  ///
  /// May only contain initials if first names are not available.
  final String firstNames;

  /// The last name of the person to whom this document belongs.
  final String surname;

  /// The text representing gender of the person to whom this document belongs.
  ///
  /// 'M' and 'F' represent Male and Female.
  final String gender;

  /// The birth date of the person to whom this document belongs.
  final DateTime birthDate;

  const IdDocument(this.idNumber, this.firstNames, this.surname, this.gender,
      this.birthDate);

  /// Returns an `IdDocument` instance from the bytes read from the
  /// barcode of the document.
  factory IdDocument.fromBarcodeBytes(Uint8List bytes) {
    try {
      return DriversLicense.fromBarcodeBytes(bytes);
    } catch (e) {
      try {
        return SmartId.fromBarcodeBytes(bytes);
      } catch (e) {
        throw FormatException('License type is not supported.');
      }
    }
  }
}