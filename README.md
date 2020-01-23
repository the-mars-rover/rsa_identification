A Dart Library for decoding and providing South African identification details from documents
such as Driver's licenses and Smart ID's.

Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

## Usage

A simple usage example:

```dart
import 'package:rsa_identification/rsa_identification.dart';

main() {
  var awesome = new Awesome();
}import 'dart:convert';
 
 import 'package:rsa_identification/rsa_identification.dart';
 
 void main() {
   // These bytes would be scanned using a barcode scanner.
   var scannedBytes = utf8.encode(
       'SURNAME|NAME|GENDER|NATIONALITY|ID NUMBER|29 Jul 2000|COUNTRY OF BIRTH|CITIZENSHIP STATUS|26 Jan 2017|23370|SMART ID NUMBER|1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890');
 
   var idDocument = IdDocument.fromBarcodeBytes(scannedBytes);
   print('First Names: ${idDocument.firstNames}');
   print('Last Name: ${idDocument.surname}');
   print('ID Number: ${idDocument.idNumber}');
 }
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker](https://github.com/marcus-bornman/rsa_identification/issues).