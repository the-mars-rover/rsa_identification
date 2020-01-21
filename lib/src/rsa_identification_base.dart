import 'dart:convert';
import 'dart:typed_data';

import 'package:rsa_identification/src/utils.dart';

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

  /// The date on which this license was issued.
  final DateTime issueDate;

  const IdDocument(this.idNumber, this.firstNames, this.surname, this.gender,
      this.birthDate, this.issueDate);

  /// Returns an `IdDocument` instance from the bytes read from the
  /// barcode of the document.
  ///
  /// TODO: Implement the logic for this constructor.
  factory IdDocument.fromBytes(Uint8List bytes) {
    if (bytes.sublist(0, 4) == [1, 155, 9, 45]) {
      return DriversLicense.fromBytes(bytes);
    }

    return SmartId.fromBytes(bytes);
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

  const SmartId._SmartId(
      String idNumber,
      String firstNames,
      String surname,
      String gender,
      DateTime birthDate,
      DateTime issueDate,
      this.smartIdNumber,
      this.nationality,
      this.countryOfBirth,
      this.citizenshipStatus)
      : super(idNumber, firstNames, surname, gender, birthDate, issueDate);

  /// Returns a `SmartId` instance from the bytes read from the
  /// barcode of the ID.
  ///
  /// The bytes after being decoding using UTF-8 encoding, are expected to be in
  /// the following format:
  /// SURNAME|NAME|GENDER|NATIONALITY|ID NUMBER|BIRTH DATE|COUNTRY OF BIRTH|CITIZENSHIP STATUS|ISSUE DATE|23370|SMART ID NUMBER|1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
  ///
  /// If the format above is not adhered to an exception will be thrown.
  factory SmartId.fromBytes(Uint8List bytes) {
    try {
      var fields = utf8.decode(bytes).split('|');

      var surname = fields[0];
      var firstNames = fields[1];
      var gender = fields[2];
      var nationality = fields[3];
      var idNumber = fields[4];
      var birthDate = DateUtils().dateFromShortString(fields[5]);
      var countryOfBirth = fields[6];
      var citizenshipStatus = fields[7];
      var issueDate = DateUtils().dateFromShortString(fields[8]);
      var smartIdNumber = fields[10];

      return SmartId._SmartId(
        idNumber,
        firstNames,
        surname,
        gender,
        birthDate,
        issueDate,
        smartIdNumber,
        nationality,
        countryOfBirth,
        citizenshipStatus,
      );
    } catch (e) {
      throw FormatException('Could not instantiate Smart ID from bytes: $e');
    }
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
  final List<String> vehicleRestrictions;

  /// The type of the ID number. '02' represents a South African ID number.
  final String idNumberType;

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

  DriversLicense._DriversLicense(
      String idNumber,
      String firstNames,
      String surname,
      String gender,
      DateTime birthDate,
      DateTime issueDate,
      this.licenseNumber,
      this.vehicleCodes,
      this.prdpCode,
      this.idCountryOfIssue,
      this.licenseCountryOfIssue,
      this.vehicleRestrictions,
      this.idNumberType,
      this.driverRestrictions,
      this.prdpExpiry,
      this.licenseIssueNumber,
      this.validFrom,
      this.validTo,
      this.imageData)
      : super(idNumber, firstNames, surname, gender, birthDate, issueDate);

  /// Returns a `DriversLicense` instance from the bytes read from the
  /// barcode of the DriversLicense.
  ///
  /// See:
  /// - https://mybroadband.co.za/forum/threads/decode-drivers-licence-barcode.382187/
  /// - https://github.com/ugommirikwe/sa-license-decoder/blob/master/SPEC.md
  /// - https://stackoverflow.com/questions/17549231/decode-south-african-za-drivers-license
  ///
  /// TODO: Complete the rest of this section
  factory DriversLicense.fromBytes(Uint8List bytes) {
//    bytes = DriversLicenseDecoder().decodeDrivers(bytes);
    var section1 = bytes.sublist(10, 10 + bytes[5]);
    var section2 = bytes.sublist(10 + bytes[5], 10 + bytes[5] + bytes[7]);
    var section3 = bytes.sublist(
        10 + bytes[5] + bytes[7], 10 + bytes[5] + bytes[7] + bytes[9]);

    var section1Strings = _getSection1Strings(section1);
    var section2String = _getSection2AsString(section2);

    var idNumber = section1Strings[14];
    var firstNames = section1Strings[5];
    var surname = section1Strings[4];
    var gender;
    var birthDate;
    var issueDate;
    var licenseNumber = section1Strings[13];
    var vehicleCodes = section1Strings.sublist(0, 4);
    var prdpCode = section1Strings[6];
    var idCountryOfIssue = section1Strings[7];
    var licenseCountryOfIssue = section1Strings[8];
    var vehicleRestrictions = section1Strings.sublist(9, 13);
    var idNumberType;
    var driverRestrictions;
    var prdpExpiry;
    var licenseIssueNumber;
    var validFrom;
    var validTo;
    var imageData;

    return DriversLicense._DriversLicense(
        idNumber,
        firstNames,
        surname,
        gender,
        birthDate,
        issueDate,
        licenseNumber,
        vehicleCodes,
        prdpCode,
        idCountryOfIssue,
        licenseCountryOfIssue,
        vehicleRestrictions,
        idNumberType,
        driverRestrictions,
        prdpExpiry,
        licenseIssueNumber,
        validFrom,
        validTo,
        imageData);
  }

  static List<String> _getSection1Strings(Uint8List bytes) {
    var values = <String>[];
    var prevDeliminator;
    while (values.length < 14) {
      var index = bytes.indexWhere((i) => i == 224 || i == 225);

      if (prevDeliminator == 225) {
        values.add('');

        var value = String.fromCharCodes(bytes.sublist(0, index));
        if (value.isNotEmpty) {
          values.add(value);
        }
      } else {
        var value = String.fromCharCodes(bytes.sublist(0, index));
        values.add(value);
      }

      prevDeliminator = bytes[index];
      bytes = bytes.sublist(index + 1);
    }
    values.add(String.fromCharCodes(bytes));

    return values;
  }

  static String _getSection2AsString(Uint8List bytes) {
    var hexList = bytes.map((byte) => byte.toRadixString(16)).toList();
    var result = '';
    hexList.forEach((hex) => result = result + hex);
    return result;
  }
}

/// remaining=[43,31,e1,e1,e1,53,4d,49,54,48,e0,...] | values=[] | prevDeliminator = null
/// remaining=[e1,e1,53,4d,49,54,48,e0,...] | values=['C1'] | prevDeliminator = 225
/// remaining=[e1,53,4d,49,54,48,e0,...] | values=['C1', ''] | prevDeliminator = 225
/// remaining=[53,4d,49,54,48,e0,...] | values=['C1', '', ''] | prevDeliminator = 225
/// remaining=[...] | values=['C1', '', '', '', 'SMITH'] | prevDeliminator = 224
