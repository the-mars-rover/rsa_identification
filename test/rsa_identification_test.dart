import 'dart:convert';
import 'dart:typed_data';

import 'package:rsa_identification/rsa_identification.dart';
import 'package:test/test.dart';

void main() {
  group('IdDocument', () {
    test(
        'fromBytes instantiates a SmartId object accurately when passing valid smart ID bytes',
        () {
      Uint8List validBytes = utf8.encode(
          'SURNAME|NAME|GENDER|NATIONALITY|ID NUMBER|29 Jul 2000|COUNTRY OF BIRTH|CITIZENSHIP STATUS|26 Jan 2017|23370|SMART ID NUMBER|1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890');
      var smartId = IdDocument.fromBarcodeBytes(validBytes);

      expect(smartId is SmartId, true);
      expect(smartId.surname, 'SURNAME');
      expect(smartId.firstNames, 'NAME');
      expect(smartId.gender, 'GENDER');
      expect(smartId.idNumber, 'ID NUMBER');
      expect(smartId.birthDate, DateTime(2000, 7, 29));
    });

    test('fromBytes throws FormatException when passing invalid bytes', () {
      Uint8List invalidBytes = utf8.encode('some invalid bytes');
      try {
        IdDocument.fromBarcodeBytes(invalidBytes);
      } catch (e) {
        expect(e, isFormatException);
        expect(e.message, 'License type is not supported.');
      }
    });
  });

  group('SmartId', () {
    test('fromBytes instantiates object accurately when passing valid bytes',
        () {
      Uint8List validBytes = utf8.encode(
          'SURNAME|NAME|GENDER|NATIONALITY|ID NUMBER|29 Jul 2000|COUNTRY OF BIRTH|CITIZENSHIP STATUS|26 Jan 2017|23370|SMART ID NUMBER|1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890');
      var smartId = SmartId.fromBarcodeBytes(validBytes);

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

    test('fromBytes throws FormatException when passing invalid bytes', () {
      Uint8List invalidBytes = utf8.encode('some invalid bytes');
      try {
        SmartId.fromBarcodeBytes(invalidBytes);
      } catch (e) {
        expect(e, isFormatException);
        expect(
          e.message.startsWith('Could not instantiate Smart ID from bytes'),
          isTrue,
        );
      }
    });
  });

  group('DriversLicense', () {
    test('fromBytes throws FormatException when passing invalid bytes', () {
      Uint8List invalidBytes = utf8.encode('some invalid bytes');
      try {
        DriversLicense.fromBarcodeBytes(invalidBytes);
      } catch (e) {
        expect(e, isFormatException);
        expect(
          e.message.startsWith('Could not instantiate Drivers License from bytes'),
          isTrue,
        );
      }
    });
  });
}
