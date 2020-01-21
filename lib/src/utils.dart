import 'dart:convert';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';

class DateUtils {
  /// Returns a `DateTime` from a `String` in the format dd MMM yyyy.
  ///
  /// Some acceptable strings:
  /// '12 Sep 2018', '2 JAN 1996', '27 feb 1887', etc.
  DateTime dateFromShortString(String shortString) {
    try {
      var day = int.parse(shortString.split(' ')[0]);
      var month = _monthNumber(shortString.split(' ')[1]);
      var year = int.parse(shortString.split(' ')[2]);

      return DateTime(year, month, day);
    } catch (e) {
      rethrow;
    }
  }

  /// A helper function for [dateFromShortString]. Returns the integer representation
  /// of the Month represented by [monthString].
  int _monthNumber(String monthString) {
    switch (monthString.toLowerCase().substring(0, 3)) {
      case 'jan':
        return 1;
      case 'feb':
        return 2;
      case 'mar':
        return 3;
      case 'apr':
        return 4;
      case 'may':
        return 5;
      case 'jun':
        return 6;
      case 'jul':
        return 7;
      case 'aug':
        return 8;
      case 'sep':
        return 9;
      case 'oct':
        return 10;
      case 'nov':
        return 11;
      case 'dec':
        return 12;
      default:
        throw FormatException('Not a valid Month string: \'$monthString\'');
    }
  }
}

class DriversLicenseDecoder {
  Uint8List decodeDrivers(Uint8List bytes) {
    var block1 = bytes.sublist(6, 134);
    var block2 = bytes.sublist(134, 262);
    var block3 = bytes.sublist(262, 390);
    var block4 = bytes.sublist(390, 518);
    var block5 = bytes.sublist(518, 646);
    var block6 = bytes.sublist(646, 720);

    var key = '''-----BEGIN RSA PUBLIC KEY-----
MIGWAoGBAMqfGO9sPz+kxaRh/qVKsZQGul7NdG1gonSS3KPXTjtcHTFfexA4MkGA
mwKeu9XeTRFgMMxX99WmyaFvNzuxSlCFI/foCkx0TZCFZjpKFHLXryxWrkG1Bl9+
+gKTvTJ4rWk1RvnxYhm3n/Rxo2NoJM/822Oo7YBZ5rmk8NuJU4HLAhAYcJLaZFTO
sYU+aRX4RmoF
-----END RSA PUBLIC KEY-----''';
    var rows = key.split(RegExp(r'\r\n?|\n'));
    var sequence = _parseSequence(rows);
    var modulus = (sequence.elements[0] as ASN1Integer).valueAsBigInteger;
    var exponent = (sequence.elements[1] as ASN1Integer).valueAsBigInteger;
    var decrypted = [];
    decrypted.addAll(_encryptValue(block1, exponent, modulus, 128));
    decrypted.addAll(_encryptValue(block2, exponent, modulus, 128));
    decrypted.addAll(_encryptValue(block3, exponent, modulus, 128));
    decrypted.addAll(_encryptValue(block4, exponent, modulus, 128));
    decrypted.addAll(_encryptValue(block5, exponent, modulus, 128));

    key = '''-----BEGIN RSA PUBLIC KEY-----
MF8CSwC0BKDfEdHKz/GhoEjU1XP5U6YsWD10klknVhpteh4rFAQlJq9wtVBUc5Dq
bsdI0w/bga20kODDahmGtASy9fae9dobZj5ZUJEw5wIQMJz+2XGf4qXiDJu0R2U4
Kw==
-----END RSA PUBLIC KEY-----''';
    rows = key.split(RegExp(r'\r\n?|\n'));
    sequence = _parseSequence(rows);
    modulus = (sequence.elements[0] as ASN1Integer).valueAsBigInteger;
    exponent = (sequence.elements[1] as ASN1Integer).valueAsBigInteger;
    decrypted.addAll(_encryptValue(block6, exponent, modulus, 74));

    return decrypted;
  }

  Uint8List _encryptValue(Uint8List rgb, BigInt e, BigInt n, int size) {
    var input = _decodeBigInt(rgb);
    var output = input.modPow(e, n);
    return _encodeBigInt(output);
  }

  ASN1Sequence _parseSequence(List<String> rows) {
    final keyText = rows
        .skipWhile((row) => row.startsWith('-----BEGIN'))
        .takeWhile((row) => !row.startsWith('-----END'))
        .map((row) => row.trim())
        .join('');

    final keyBytes = Uint8List.fromList(base64.decode(keyText));
    final asn1Parser = ASN1Parser(keyBytes);

    return asn1Parser.nextObject() as ASN1Sequence;
  }

  /// Decode a BigInt from bytes in big-endian encoding.
  BigInt _decodeBigInt(List<int> bytes) {
    var result = BigInt.from(0);
    for (var i = 0; i < bytes.length; i++) {
      result += BigInt.from(bytes[bytes.length - i - 1]) << (8 * i);
    }
    return result;
  }

  final _byteMask = BigInt.from(0xff);

  /// Encode a BigInt into bytes using big-endian encoding.
  Uint8List _encodeBigInt(BigInt number) {
    // Not handling negative numbers. Decide how you want to do that.
    var size = (number.bitLength + 7) >> 3;
    var result = Uint8List(size);
    for (var i = 0; i < size; i++) {
      result[size - i - 1] = (number & _byteMask).toInt();
      number = number >> 8;
    }
    return result;
  }
}
