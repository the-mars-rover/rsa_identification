import 'dart:typed_data';

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
  final String Surname;

  /// The text representing gender of the person to whom this document belongs.
  ///
  /// 'M' and 'F' represent Male and Female.
  final String gender;

  /// The birth date of the person to whom this document belongs.
  final DateTime birthDate;

  const IdDocument(this.idNumber, this.firstNames, this.Surname,
      this.gender, this.birthDate);

  /// Returns an `IdDocument` instance from the bytes read from the
  /// barcode of the document.
  ///
  /// TODO: Implement the logic for this constructor.
  factory IdDocument.fromBytes(Uint8List bytes){
    if ('a' == 'b') {
      return SmartId.fromBytes(bytes);
    } else {
      return DriversLicense.fromBytes(bytes);
    }
  }
}

class SmartId extends IdDocument {
  /// The number of this smart ID.
  final String smartIdNumber;

  /// The country code representing the nationality of the person to whom this
  /// document belongs.
  final String nationality;

  /// The country code representing the country of birth of the person to whom
  /// this document belongs.
  final String countryOfBirth;

  /// The citizenship status of the person to whom this document belongs.
  final String citizenshipStatus;

  const SmartId._SmartId(String idNumber,
      String firstNames,
      String Surname,
      String gender,
      DateTime birthDate,
      this.smartIdNumber,
      this.nationality,
      this.countryOfBirth,
      this.citizenshipStatus)
      : super(idNumber, firstNames, Surname, gender, birthDate);

  /// Returns a `SmartId` instance from the bytes read from the
  /// barcode of the ID.
  ///
  /// TODO: Implement the logic for this constructor.
  factory SmartId.fromBytes(Uint8List bytes) {
    return null;
  }
}

class DriversLicense extends IdDocument {
  /// The license number of this license.
  final String licenseNumber;

  /// The list of vehicle codes appearing on the license.
  final List<String> vehicleCodes;

  /// The PrDP Code appearing on the license.
  final String prdpCode;

  /// The country code representing the country in which the ID of the person
  /// to whom this document belongs was issued.
  final String idCountryOfIssue;

  /// The country code representing the country in which this license was issued.
  final String licenseCountryOfIssue;

  /// The vehicle restrictions placed on this license
  final List<int> vehicleRestrictions;

  /// The type of the ID number. '02' represents a South African ID number.
  final String idNumberType;

  /// The date on which this license was issued.
  final DateTime issueDate;

  /// The driver restriction codes placed on this license.
  final List<String> driverRestrictions;

  /// The expiry date of the PrDP Permit.
  final DateTime prdpExpiry;

  /// The issue number of this license.
  final String licenseIssueNumber;

  /// The date from which this license is valid.
  final DateTime validFrom;

  /// The date to which this license is valid.
  final DateTime validTo;

  /// The image data of the photo on this license in bytes.
  ///
  /// TODO: Determine how this data can be decoded to provide an actual image.
  final Uint8List imageData;

  DriversLicense._DriversLicense(String idNumber,
      String firstNames,
      String Surname,
      String gender,
      DateTime birthDate,
      this.licenseNumber,
      this.vehicleCodes,
      this.prdpCode,
      this.idCountryOfIssue,
      this.licenseCountryOfIssue,
      this.vehicleRestrictions,
      this.idNumberType,
      this.issueDate,
      this.driverRestrictions,
      this.prdpExpiry,
      this.licenseIssueNumber,
      this.validFrom,
      this.validTo,
      this.imageData)
      : super(idNumber, firstNames, Surname, gender, birthDate);

  /// Returns a `DriversLicense` instance from the bytes read from the
  /// barcode of the DriversLicense.
  ///
  /// TODO: Implement the logic for this constructor.
  factory DriversLicense.fromBytes(Uint8List bytes) {
    return null;
  }
}