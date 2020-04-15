/// A South African Smart ID Card. Includes all the details of the Smart ID.
class IdCard {
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

  const IdCard._IdCard(
      this.idNumber,
      this.firstNames,
      this.surname,
      this.gender,
      this.birthDate,
      this.issueDate,
      this.smartIdNumber,
      this.nationality,
      this.countryOfBirth,
      this.citizenshipStatus);

  /// Returns a `SmartId` instance from the String read from the
  /// barcode of the ID.
  ///
  /// The barcodeString is  expected to be in the following format:
  /// SURNAME|NAME|GENDER|NATIONALITY|ID NUMBER|BIRTH DATE|COUNTRY OF BIRTH|CITIZENSHIP STATUS|ISSUE DATE|23370|SMART ID NUMBER|1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
  ///
  /// If the format above is not adhered to an a [FormatException] will be thrown.
  factory IdCard.fromBarcodeString(String barcodeString) {
    try {
      var fields = barcodeString.split('|');

      var surname = fields[0];
      var firstNames = fields[1];
      var gender = fields[2];
      var nationality = fields[3];
      var idNumber = fields[4];
      var birthDate = _dateFromShortString(fields[5]);
      var countryOfBirth = fields[6];
      var citizenshipStatus = fields[7];
      var issueDate = _dateFromShortString(fields[8]);
      var smartIdNumber = fields[10];

      return IdCard._IdCard(
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
      throw FormatException('Could not instantiate Smart ID from given barcode String: $e');
    }
  }

  /// Returns a `DateTime` from a `String` in the format dd MMM yyyy.
  ///
  /// Some acceptable strings:
  /// '12 Sep 2018', '2 JAN 1996', '27 feb 1887', etc.
  static DateTime _dateFromShortString(String shortString) {
    try {
      var day = int.parse(shortString.split(' ')[0]);
      var month = _monthNumber(shortString.split(' ')[1]);
      var year = int.parse(shortString.split(' ')[2]);

      return DateTime(year, month, day);
    } catch (e) {
      rethrow;
    }
  }

  /// A helper function for [_dateFromShortString]. Returns the integer representation
  /// of the Month represented by [monthString].
  static int _monthNumber(String monthString) {
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
