![Dart CI](https://github.com/Born-Pty-Ltd/rsa_identification/workflows/Dart%20CI/badge.svg)

A Dart Library for decoding and providing South African identification details from documents
such as Driver's licenses and Smart ID's.

## Supported Documents
* [x] Driver's Licenses
* [x] Smart ID Documents
* [x] Old ID Books

## Usage

A simple usage example:

```dart
import 'dart:convert';

import 'package:rsa_identification/rsa_identification.dart';

void main() {
  final idCardBarcode =
      'SURNAME|NAME|GENDER|NATIONALITY|ID NUMBER|29 Jul 2000|COUNTRY OF BIRTH|CITIZENSHIP STATUS|26 Jan 2017|23370|SMART ID NUMBER|1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890';
  final idCard = IdCard.fromBarcodeString(idCardBarcode);
  print('ID Card - First Names: ${idCard.firstNames}');
  print('ID Card - Last Name: ${idCard.surname}');
  print('ID Card - ID Number: ${idCard.idNumber}');

  final idBookBarcode = '7310095800088';
  final idBook = IdBook.fromIdNumber(idBookBarcode);
  print('ID Book - Date of Birth: ${idBook.birthDate}');
  print('ID Book - Gender: ${idBook.gender}');
  print('ID Book - Citizenship: ${idBook.citizenshipStatus}');
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker](https://github.com/marcus-bornman/rsa_identification/issues).