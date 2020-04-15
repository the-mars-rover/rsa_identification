class IdBook {
  /// The ID Number of the person to whom this document belongs.
  final String idNumber;

  /// The birth date of the person to whom this document belongs.
  final DateTime birthDate;

  /// The text representing gender of the person to whom this document belongs.
  ///
  /// 'M' and 'F' represent Male and Female.
  final String gender;

  /// The citizenship status of the owner of this document.
  ///
  /// Will be either 'SA Citizen' or 'Permanent Resident'.
  final String citizenshipStatus;

  const IdBook._IdBook(
      this.idNumber, this.gender, this.birthDate, this.citizenshipStatus);

  /// Returns an `IdBook` instance from the ID Number of an ID Book, which can be read from
  /// the barcode of the ID Book.
  ///
  /// The ID Number is  expected to be in the format of a South African ID Number,
  /// See https://mybroadband.co.za/news/government/176895-what-your-south-african-id-number-reveals-about-you.html.
  ///
  /// If the format above is not adhered to a [FormatException] will be thrown.
  factory IdBook.fromIdNumber(String idNumber) {
    try {
      _validateIdNumber(idNumber);
      final dateOfBirth = _dateOfBirth(idNumber);
      final gender = _gender(idNumber);
      final citizenshipStatus = _citizenshipStatus(idNumber);

      return IdBook._IdBook(idNumber, gender, dateOfBirth, citizenshipStatus);
    } catch (e) {
      throw FormatException(
          'Could not instantiate ID Book from given ID Number: $e');
    }
  }

  /// A helper method for [IdBook.fromIdNumber] - validates the given ID number
  /// and throws a [FormatException] if the ID number is not valid.
  ///
  /// See http://geekswithblogs.net/willemf/archive/2005/10/30/58561.aspx
  static void _validateIdNumber(String idNumber) {
    final checkDigit = int.parse(idNumber.substring(12, 13));

    // Add all the digits in the odd positions (excluding last digit) [1]
    var oddSum = 0;
    for (var i = 0; i < idNumber.length - 1; i += 2) {
      oddSum += int.parse(idNumber.substring(i, i + 1));
    }

    // Move the even positions into a field and multiply the number by 2 [2]
    var evenString = '';
    for (var i = 1; i < idNumber.length; i += 2) {
      evenString += idNumber.substring(i, i + 1);
    }
    final evenProduct = (int.parse(evenString) * 2).toString();

    // Add the digits of [2]'s result [3]
    var evenProductSum = 0;
    for (var i = 0; i < evenProduct.length; i++) {
      evenProductSum += int.parse(evenProduct.substring(i, i + 1));
    }

    // Add the answer in [1] to the answer in [4].
    final sum = oddSum + evenProductSum;

    // Subtract the second digit of the answer in [4] from 10.
    final calculatedDigit = sum % 10 == 0 ? 0 : 10 - sum % 10;

    // Check calculated digit against check digit
    if (calculatedDigit != checkDigit) {
      throw FormatException('ID Number is not valid.');
    }
  }

  /// A helper method for [IdBook.fromIdNumber] - returns the birth date associated
  /// with the given ID number.
  static DateTime _dateOfBirth(String idNumber) {
    final yy = idNumber.substring(0, 2);
    final mm = idNumber.substring(2, 4);
    final dd = idNumber.substring(4, 6);

    final currentCentury = (DateTime.now().year / 100).floor();
    final currentYear = DateTime.now().year % 100;
    final yearPrefix = int.parse(yy) < currentYear
        ? currentCentury.toString()
        : (currentCentury - 1).toString();

    return DateTime.parse(yearPrefix + yy + mm + dd);
  }

  /// A helper method for [IdBook.fromIdNumber] - returns the gender associated
  /// with the given ID number.
  static String _gender(String idNumber) {
    final genderFlag = int.parse(idNumber.substring(6, 7));

    return genderFlag < 5 ? 'F' : 'M';
  }

  /// A helper method for [IdBook.fromIdNumber] - returns the citizenship associated
  /// with the given ID number.
  static String _citizenshipStatus(String idNumber) {
    final residentFlag = int.parse(idNumber.substring(10, 11));

    return residentFlag == 0 ? 'SA Citizen' : 'Permanent Resident';
  }
}
