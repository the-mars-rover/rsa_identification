<!-- PROJECT LOGO -->
<p align="right">
<a href="https://pub.dev">
<img src="https://raw.githubusercontent.com/born-ideas/rsa_identification/master/assets/project_badge.png" height="100" alt="Flutter">
</a>
</p>
<p align="center">
<img src="https://raw.githubusercontent.com/born-ideas/rsa_identification/master/assets/project_logo.png" height="100" alt="Masterpass Example" />
</p>

<!-- PROJECT SHIELDS -->
<p align="center">
<a href="https://pub.dev/packages/rsa_identification"><img src="https://img.shields.io/pub/v/rsa_identification" alt="pub"></a>
<a href="https://github.com/born-ideas/rsa_identification/issues"><img src="https://img.shields.io/github/issues/born-ideas/rsa_identification" alt="issues"></a>
<a href="https://github.com/born-ideas/rsa_identification/network"><img src="https://img.shields.io/github/forks/born-ideas/rsa_identification" alt="forks"></a>
<a href="https://github.com/born-ideas/rsa_identification/stargazers"><img src="https://img.shields.io/github/stars/born-ideas/rsa_identification" alt="stars"></a>
<a href="https://dart.dev/guides/language/effective-dart/style"><img src="https://img.shields.io/badge/style-effective_dart-40c4ff.svg" alt="style"></a>
<a href="https://github.com/born-ideas/rsa_identification/blob/master/LICENSE"><img src="https://img.shields.io/github/license/born-ideas/rsa_identification" alt="license"></a>
</p>

---

<!-- TABLE OF CONTENTS -->
## Table of Contents
* [About the Project](#about-the-project)
* [Getting Started](#getting-started)
* [Usage](#usage)
* [Roadmap](#roadmap)
* [Contributing](#contributing)
* [License](#license)
* [Contact](#contact)
* [Acknowledgements](#acknowledgements)



<!-- ABOUT THE PROJECT -->
## About The Project
<p align="center">
<img src="https://raw.githubusercontent.com/born-ideas/rsa_identification/master/assets/screenshot_1.gif" width="600" alt="Screenshot 1" />
</p>

South African Identification documents have barcodes which provide specific data about their owners. This project provides 
a [Dart Library](https://pub.dev/packages/rsa_identification) for decoding and working with the details from these barcodes.
Supported documents include:
* [x] Driver's Licenses
* [x] Smart ID Documents
* [x] Old ID Books

### Built With
* [Dart](https://dart.dev/)



<!-- GETTING STARTED -->
## Getting Started
### Prerequisites
This package can only be used by other dart projects. If this is your first dart project, see the following pages to help you get started:                   
- [Codelabs: Guided, hands-on coding experience](https://dart.dev/codelabs)
- [Tutorials: Teaching you how to use Dart](https://dart.dev/tutorials)

### Installation
Add `rsa_identification` as a [dependency in your pubspec.yaml file](https://dart.dev/guides/packages).



<!-- USAGE EXAMPLES -->
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



<!-- ROADMAP -->
## Roadmap

See the [open issues](https://github.com/othneildrew/Best-README-Template/issues) for a list of proposed features (and known issues).



<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request



<!-- LICENSE -->
## License

Distributed under the MIT License. See [LICENSE](LICENSE) for more information.



<!-- CONTACT -->
## Contact

BornIdeas - [born.dev](https://www.born.dev) - [info@born.dev](mailto:support@born.dev)

Project Link: [https://github.com/born-ideas/rsa_identification](https://github.com/born-ideas/rsa_identification)



<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements
* [This helpful MyBroadband Forum](https://mybroadband.co.za/forum/threads/decode-drivers-licence-barcode.382187/)
* [asn1lib](https://pub.dev/packages/asn1lib)
* [Shields IO](https://shields.io)
* [Open Source Licenses](https://choosealicense.com)