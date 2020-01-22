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

  const IdDocument(this.idNumber, this.firstNames, this.surname, this.gender,
      this.birthDate);

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

  /// The date on which this license was issued.
  final DateTime issueDate;

  const SmartId._SmartId(
      String idNumber,
      String firstNames,
      String surname,
      String gender,
      DateTime birthDate,
      this.issueDate,
      this.smartIdNumber,
      this.nationality,
      this.countryOfBirth,
      this.citizenshipStatus)
      : super(idNumber, firstNames, surname, gender, birthDate);

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

  /// A string representing driver restriction codes placed on this license.
  ///
  /// 00 = none
  /// 10 = glasses
  /// 20 = artificial limb
  /// 12 = glasses and artificial limb
  final String driverRestrictions;

  /// The expiry date of the PrDP Permit.
  final DateTime prdpExpiry;

  /// The issue number of this license.
  final String licenseIssueNumber;

  /// The date from which this license is valid.
  final DateTime validFrom;

  /// The date to which this license is valid.
  final DateTime validTo;

  /// The issue date for each license code. Normally contains a date for each
  /// vehicleCode in [vehicleCodes].
  List<DateTime> issueDates;

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
      this.issueDates,
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
      : super(idNumber, firstNames, surname, gender, birthDate);

  /// Returns a `DriversLicense` instance from the bytes read from the
  /// barcode of the DriversLicense.
  ///
  /// See:
  /// - https://mybroadband.co.za/forum/threads/decode-drivers-licence-barcode.382187/
  /// - https://github.com/ugommirikwe/sa-license-decoder/blob/master/SPEC.md
  /// - https://stackoverflow.com/questions/17549231/decode-south-african-za-drivers-license
  factory DriversLicense.fromBytes(Uint8List bytes) {
//    bytes = DriversLicenseDecoder().decodeDrivers(bytes);
    var section1 = bytes.sublist(10, 10 + bytes[5]);
    var section2 = bytes.sublist(10 + bytes[5], 10 + bytes[5] + bytes[7]);
    var section3 = bytes.sublist(
        10 + bytes[5] + bytes[7], 10 + bytes[5] + bytes[7] + bytes[9]);

    var section1Values = _getSection1Values(section1);
    var section2Values = _getSection2Values(section2);

    var idNumber = section1Values[14];
    var firstNames = section1Values[5];
    var surname = section1Values[4];
    var gender;
    section2Values[11] == '01' ? gender = 'M' : gender = 'F';
    var birthDate = section2Values[8];
    var issueDates = List<DateTime>.from(section2Values.sublist(1, 5));
    issueDates.removeWhere((date) => date == null);
    var licenseNumber = section1Values[13];
    var vehicleCodes = section1Values.sublist(0, 4);
    vehicleCodes.removeWhere((code) => code.isEmpty);
    var prdpCode = section1Values[6];
    var idCountryOfIssue = section1Values[7];
    var licenseCountryOfIssue = section1Values[8];
    var vehicleRestrictions = section1Values.sublist(9, 13);
    vehicleRestrictions.removeWhere((code) => code.isEmpty);
    var idNumberType = section2Values[0];
    var driverRestrictions = section2Values[5];
    var prdpExpiry = section2Values[6];
    var licenseIssueNumber = section2Values[7];
    var validFrom = section2Values[9];
    var validTo = section2Values[10];
    var imageData = section3;

    return DriversLicense._DriversLicense(
        idNumber,
        firstNames,
        surname,
        gender,
        birthDate,
        issueDates,
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

  static List<String> _getSection1Values(Uint8List bytes) {
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

  static List<dynamic> _getSection2Values(Uint8List bytes) {
    var hexList = bytes.map((byte) {
      var hex = byte.toRadixString(16);
      if (hex.length == 1) {
        hex = '0' + hex;
      }
      return hex;
    }).toList();
    var nibbleString = '';
    hexList.forEach((hex) => nibbleString = nibbleString + hex);

    var values = [];
    while (values.length < 12) {
      if (values.isEmpty ||
          values.length == 5 ||
          values.length == 7 ||
          values.length == 11) {
        //2 nibbles
        values.add(nibbleString.substring(0, 2));
        nibbleString = nibbleString.substring(2);
        continue;
      }

      if (values.length == 1 ||
          values.length == 2 ||
          values.length == 3 ||
          values.length == 4 ||
          values.length == 6 ||
          values.length == 8 ||
          values.length == 9 ||
          values.length == 10) {
        if (nibbleString.substring(0, 1) == 'a') {
          // 1 nibble
          values.add(null);
          nibbleString = nibbleString.substring(1);
        } else {
          // 8 nibbles
          var year = int.parse(nibbleString.substring(0, 4));
          var month = int.parse(nibbleString.substring(4, 6));
          var day = int.parse(nibbleString.substring(6, 8));
          values.add(DateTime(year, month, day));
          nibbleString = nibbleString.substring(8);
        }
        continue;
      }
    }

    return values;
  }
}
