import 'dart:convert';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:meta/meta.dart';

import '../rsa_identification.dart';

/// A South African Driver's License. Includes all the details of the license.
class RsaDriversLicense implements RsaIdDocument {
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
  /// '00' = none
  /// '10' = glasses
  /// '20' = artificial limb
  /// '12' = glasses and artificial limb
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
  final List<DateTime> issueDates;

  /// The image data of the photo on this license in bytes.
  ///
  /// TODO: Determine how this data can be decoded to provide an actual image.
  final Uint8List imageData;

  const RsaDriversLicense({
    @required this.idNumber,
    @required this.firstNames,
    @required this.surname,
    @required this.gender,
    @required this.birthDate,
    @required this.issueDates,
    @required this.licenseNumber,
    @required this.vehicleCodes,
    @required this.prdpCode,
    @required this.idCountryOfIssue,
    @required this.licenseCountryOfIssue,
    @required this.vehicleRestrictions,
    @required this.idNumberType,
    @required this.driverRestrictions,
    @required this.prdpExpiry,
    @required this.licenseIssueNumber,
    @required this.validFrom,
    @required this.validTo,
    @required this.imageData,
  });

  /// Returns a `DriversLicense` instance from the bytes read from the
  /// barcode of the DriversLicense.
  ///
  /// IMPORTANT: [bytes] is the RAW bytes from the barcode. Some barcode
  /// scanner plugins expose the String of the barcode which has been decoded using
  /// UTF encoding - this corrupts the raw bytes when encoding the string to bytes again.
  /// Try to use a barcode scanner which exposes the raw bytes directly (ie. before
  /// any encoding/decoding takes place).
  ///
  /// See:
  /// - https://mybroadband.co.za/forum/threads/decode-drivers-licence-barcode.382187/
  /// - https://github.com/ugommirikwe/sa-license-decoder/blob/master/SPEC.md
  /// - https://stackoverflow.com/questions/17549231/decode-south-african-za-drivers-license
  factory RsaDriversLicense.fromBarcodeBytes(Uint8List bytes) {
    try {
      bytes = _decodeDrivers(bytes);
      var section1 = bytes.sublist(10, 10 + bytes[5]);
      var section2 = bytes.sublist(10 + bytes[5], 10 + bytes[5] + bytes[7]);
      // TODO: Determine length of section 3 (Image Section) and extract image.
      var section3;

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

      return RsaDriversLicense(
        idNumber: idNumber,
        firstNames: firstNames,
        surname: surname,
        gender: gender,
        birthDate: birthDate,
        issueDates: issueDates,
        licenseNumber: licenseNumber,
        vehicleCodes: vehicleCodes,
        prdpCode: prdpCode,
        idCountryOfIssue: idCountryOfIssue,
        licenseCountryOfIssue: licenseCountryOfIssue,
        vehicleRestrictions: vehicleRestrictions,
        idNumberType: idNumberType,
        driverRestrictions: driverRestrictions,
        prdpExpiry: prdpExpiry,
        licenseIssueNumber: licenseIssueNumber,
        validFrom: validFrom,
        validTo: validTo,
        imageData: imageData,
      );
    } catch (e) {
      throw FormatException(
          'Could not instantiate Drivers License from bytes: $e');
    }
  }

  /// A helper function for [DriversLicense..fromBarcodeBytes]. Returns a list of the
  /// values in section 1 of the bytes.
  ///
  /// See:
  /// - https://github.com/ugommirikwe/sa-license-decoder/blob/master/SPEC.md
  static List<String> _getSection1Values(Uint8List bytes) {
    try {
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
    } catch (e) {
      rethrow;
    }
  }

  /// A helper function for [DriversLicense..fromBarcodeBytes]. Returns a list of the
  /// values in section 2 of the bytes.
  ///
  /// See:
  /// - https://github.com/ugommirikwe/sa-license-decoder/blob/master/SPEC.md
  static List<dynamic> _getSection2Values(Uint8List bytes) {
    try {
      // Convert bytes to a hex string so that each letter represents a single nibble.
      var hexList = bytes.map((byte) {
        var hex = byte.toRadixString(16);
        if (hex.length == 1) {
          hex = '0' + hex;
        }
        return hex;
      }).toList();
      var nibbleString = '';
      hexList.forEach((hex) => nibbleString = nibbleString + hex);

      return _getSection2ValuesFromNibbles(nibbleString);
    } catch (e) {
      rethrow;
    }
  }

  /// A helper function for [_getSection2Values]. Returns a list of the
  /// values from [nibbleString], which is a string in which each letter
  /// represents a single nibble.
  ///
  /// See:
  /// - https://github.com/ugommirikwe/sa-license-decoder/blob/master/SPEC.md
  static List<dynamic> _getSection2ValuesFromNibbles(String nibbleString) {
    try {
      var values = [];

      while (values.length < 12) {
        // If values.length is 0, 5, 7, or 8 - the next values is 2 nibbles (letters) long
        if (values.isEmpty ||
            values.length == 5 ||
            values.length == 7 ||
            values.length == 11) {
          //2 nibbles
          values.add(nibbleString.substring(0, 2));
          nibbleString = nibbleString.substring(2);
          continue;
        }

        // If values.length is 0, 5, 7, or 8 - the next values is a date, which can be
        // a single nibble or 8 nibbles long.
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
    } catch (e) {
      rethrow;
    }
  }

  /// A helper function for [DriversLicense..fromBarcodeBytes]. The bytes scanned from
  /// a driver's license need to decoded using a RSA encryption.
  ///
  /// See the following links on how to decode the license:
  /// - https://mybroadband.co.za/forum/threads/decode-drivers-licence-barcode.382187/
  /// - https://stackoverflow.com/questions/17549231/decode-south-african-za-drivers-license
  static Uint8List _decodeDrivers(Uint8List bytes) {
    var key128 = '''-----BEGIN RSA PUBLIC KEY-----
MIGWAoGBAMqfGO9sPz+kxaRh/qVKsZQGul7NdG1gonSS3KPXTjtcHTFfexA4MkGA
mwKeu9XeTRFgMMxX99WmyaFvNzuxSlCFI/foCkx0TZCFZjpKFHLXryxWrkG1Bl9+
+gKTvTJ4rWk1RvnxYhm3n/Rxo2NoJM/822Oo7YBZ5rmk8NuJU4HLAhAYcJLaZFTO
sYU+aRX4RmoF
-----END RSA PUBLIC KEY-----''';
    var key74 = '''-----BEGIN RSA PUBLIC KEY-----
MF8CSwC0BKDfEdHKz/GhoEjU1XP5U6YsWD10klknVhpteh4rFAQlJq9wtVBUc5Dq
bsdI0w/bga20kODDahmGtASy9fae9dobZj5ZUJEw5wIQMJz+2XGf4qXiDJu0R2U4
Kw==
-----END RSA PUBLIC KEY-----''';
    var decrypted = <int>[];

    try {
      // 5 blocks of 128, 1 block of 74
      var block1 = bytes.sublist(6, 134);
      var block2 = bytes.sublist(134, 262);
      var block3 = bytes.sublist(262, 390);
      var block4 = bytes.sublist(390, 518);
      var block5 = bytes.sublist(518, 646);
      var block6 = bytes.sublist(646, 720);

      // decode first 5 blocks and add to decrypted.
      var rows = key128.split(RegExp(r'\r\n?|\n'));
      var sequence = _parseSequence(rows);
      var modulus = (sequence.elements[0] as ASN1Integer).valueAsBigInteger;
      var exponent = (sequence.elements[1] as ASN1Integer).valueAsBigInteger;
      decrypted
          .addAll(_encryptValue(block1, exponent, modulus, 128).sublist(5));
      decrypted
          .addAll(_encryptValue(block2, exponent, modulus, 128).sublist(5));
      decrypted
          .addAll(_encryptValue(block3, exponent, modulus, 128).sublist(5));
      decrypted
          .addAll(_encryptValue(block4, exponent, modulus, 128).sublist(5));
      decrypted
          .addAll(_encryptValue(block5, exponent, modulus, 128).sublist(5));

      // decode last block of 74 and add to decrypted.
      rows = key74.split(RegExp(r'\r\n?|\n'));
      sequence = _parseSequence(rows);
      modulus = (sequence.elements[0] as ASN1Integer).valueAsBigInteger;
      exponent = (sequence.elements[1] as ASN1Integer).valueAsBigInteger;
      decrypted.addAll(_encryptValue(block6, exponent, modulus, 74));

      return Uint8List.fromList(decrypted);
    } catch (e) {
      rethrow;
    }
  }

  /// A helper function for [_decodeDrivers]. Helps to implement RSA Encryption
  /// manually since encryption packages don't seem to be working.
  static Uint8List _encryptValue(Uint8List rgb, BigInt e, BigInt n, int size) {
    try {
      var input = _decodeBigInt(rgb);
      var output = input.modPow(e, n);
      return _encodeBigInt(output);
    } catch (e) {
      rethrow;
    }
  }

  /// A helper function for [_decodeDrivers]. Helps to implement RSA Encryption
  /// manually since encryption packages don't seem to be working.
  static ASN1Sequence _parseSequence(List<String> rows) {
    try {
      final keyText = rows
          .skipWhile((row) => row.startsWith('-----BEGIN'))
          .takeWhile((row) => !row.startsWith('-----END'))
          .map((row) => row.trim())
          .join('');

      final keyBytes = Uint8List.fromList(base64.decode(keyText));
      final asn1Parser = ASN1Parser(keyBytes);

      return asn1Parser.nextObject() as ASN1Sequence;
    } catch (e) {
      rethrow;
    }
  }

  /// A helper function for [_encryptValue]. Helps to implement RSA Encryption
  /// manually since encryption packages don't seem to be working.
  /// Decodes a BigInt from bytes in big-endian encoding.
  static BigInt _decodeBigInt(List<int> bytes) {
    try {
      var result = BigInt.from(0);
      for (var i = 0; i < bytes.length; i++) {
        result += BigInt.from(bytes[bytes.length - i - 1]) << (8 * i);
      }
      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// A helper function for [_encryptValue]. Helps to implement RSA Encryption
  /// manually since encryption packages don't seem to be working.
  /// Encode a BigInt into bytes using big-endian encoding.
  static Uint8List _encodeBigInt(BigInt number) {
    try {
      var _byteMask = BigInt.from(0xff);
      var size = (number.bitLength + 7) >> 3;
      var result = Uint8List(size);
      for (var i = 0; i < size; i++) {
        result[size - i - 1] = (number & _byteMask).toInt();
        number = number >> 8;
      }
      return result;
    } catch (e) {
      rethrow;
    }
  }
}
