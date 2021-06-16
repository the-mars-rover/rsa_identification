import 'dart:convert';
import 'dart:typed_data';

import 'package:rsa_identification/rsa_identification.dart';
import 'package:test/test.dart';

void main() {
  group('IdCard', () {
    test(
        'fromBarcodeString instantiates object accurately when passing valid barcodeString',
        () {
      final barcodeString =
          'SURNAME|NAME|GENDER|NATIONALITY|ID NUMBER|29 Jul 2000|COUNTRY OF BIRTH|CITIZENSHIP STATUS|26 Jan 2017|23370|SMART ID NUMBER|1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890';
      var smartId = RsaIdCard.fromBarcodeString(barcodeString);

      expect(smartId.surname, 'SURNAME');
      expect(smartId.firstNames, 'NAME');
      expect(smartId.gender, 'GENDER');
      expect(smartId.nationality, 'NATIONALITY');
      expect(smartId.idNumber, 'ID NUMBER');
      expect(smartId.birthDate, DateTime(2000, 7, 29));
      expect(smartId.countryOfBirth, 'COUNTRY OF BIRTH');
      expect(smartId.citizenshipStatus, 'CITIZENSHIP STATUS');
      expect(smartId.issueDate, DateTime(2017, 1, 26));
      expect(smartId.smartIdNumber, 'SMART ID NUMBER');
    });

    test(
        'fromBarcodeString throws FormatException when passing invalid barcodeString',
        () {
      final barcodeString = 'some invalid bytes';
      try {
        RsaIdCard.fromBarcodeString(barcodeString);
      } catch (e) {
        expect(e, isFormatException);
      }
    });
  });

  group('IdBook', () {
    test(
        'fromIdNumber instantiates object accurately when passing a valid ID Number',
        () {
      final barcodeString = '8208114800080';
      var idBook = RsaIdBook.fromIdNumber(barcodeString);

      expect(idBook.idNumber, '8208114800080');
      expect(idBook.birthDate, DateTime(1982, 8, 11));
      expect(idBook.gender, 'F');
      expect(idBook.citizenshipStatus, 'SA Citizen');
    });

    test(
        'fromIdNumber throws FormatException when passing an invalid ID Number',
        () {
      final barcodeString = '8208114800081'; // check digit is invalid
      try {
        RsaIdBook.fromIdNumber(barcodeString);
      } catch (e) {
        expect(e, isFormatException);
      }
    });
  });

  group('DriversLicense', () {
    test('fromBytes throws FormatException when passing invalid bytes', () {
      var invalidBytes = Uint8List.fromList(utf8.encode('some invalid bytes'));
      try {
        RsaDriversLicense.fromBarcodeBytes(invalidBytes);
      } catch (e) {
        expect(e, isFormatException);
      }
    });
  });
}
