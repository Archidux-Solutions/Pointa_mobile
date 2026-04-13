class PhoneCountryOption {
  const PhoneCountryOption({
    required this.country,
    required this.dialCode,
  });

  final String country;
  final String dialCode;
}

class PhoneInputValue {
  const PhoneInputValue({
    required this.dialCode,
    required this.localNumber,
  });

  final String dialCode;
  final String localNumber;
}

const defaultPhoneDialCode = '+226';

const supportedPhoneCountries = <PhoneCountryOption>[
  PhoneCountryOption(country: 'Burkina Faso', dialCode: '+226'),
  PhoneCountryOption(country: 'Côte d\'Ivoire', dialCode: '+225'),
  PhoneCountryOption(country: 'Bénin', dialCode: '+229'),
  PhoneCountryOption(country: 'Togo', dialCode: '+228'),
  PhoneCountryOption(country: 'Sénégal', dialCode: '+221'),
  PhoneCountryOption(country: 'Mali', dialCode: '+223'),
  PhoneCountryOption(country: 'Niger', dialCode: '+227'),
  PhoneCountryOption(country: 'Ghana', dialCode: '+233'),
  PhoneCountryOption(country: 'Nigeria', dialCode: '+234'),
  PhoneCountryOption(country: 'Cameroun', dialCode: '+237'),
  PhoneCountryOption(country: 'Maroc', dialCode: '+212'),
  PhoneCountryOption(country: 'Tunisie', dialCode: '+216'),
  PhoneCountryOption(country: 'RDC', dialCode: '+243'),
  PhoneCountryOption(country: 'France', dialCode: '+33'),
];

String normalizeDialCode(String? value) {
  final digits = digitsOnly(value ?? defaultPhoneDialCode);
  if (digits.isEmpty) {
    return defaultPhoneDialCode;
  }
  return '+$digits';
}

String digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

String normalizeStoredPhoneNumber(
  String value, {
  String fallbackDialCode = defaultPhoneDialCode,
}) {
  final trimmedValue = value.trim();
  if (trimmedValue.isEmpty) {
    return '';
  }

  final compactValue = trimmedValue.replaceAll(RegExp(r'[\s()-]'), '');
  if (compactValue.startsWith('00')) {
    return normalizeStoredPhoneNumber(
      '+${compactValue.substring(2)}',
      fallbackDialCode: fallbackDialCode,
    );
  }

  if (compactValue.startsWith('+')) {
    final digits = digitsOnly(compactValue);
    return digits.isEmpty ? '' : '+$digits';
  }

  final digits = digitsOnly(trimmedValue);
  if (digits.isEmpty) {
    return '';
  }

  final detectedDialCode = _detectDialCode(digits);
  if (detectedDialCode != null) {
    return '+$digits';
  }

  return '${normalizeDialCode(fallbackDialCode)}$digits';
}

String buildPhoneNumber(String dialCode, String localNumber) {
  final trimmedValue = localNumber.trim();
  if (trimmedValue.isEmpty) {
    return '';
  }

  if (trimmedValue.startsWith('+') || trimmedValue.startsWith('00')) {
    return normalizeStoredPhoneNumber(
      trimmedValue,
      fallbackDialCode: dialCode,
    );
  }

  final digits = digitsOnly(trimmedValue);
  if (digits.isEmpty) {
    return '';
  }

  final detectedDialCode = _detectDialCode(digits);
  if (detectedDialCode != null) {
    return '+$digits';
  }

  return '${normalizeDialCode(dialCode)}$digits';
}

PhoneInputValue splitPhoneNumber(
  String value, {
  String fallbackDialCode = defaultPhoneDialCode,
}) {
  final normalizedValue = normalizeStoredPhoneNumber(
    value,
    fallbackDialCode: fallbackDialCode,
  );
  if (normalizedValue.isEmpty) {
    return PhoneInputValue(
      dialCode: normalizeDialCode(fallbackDialCode),
      localNumber: '',
    );
  }

  for (final option in _sortedCountries) {
    if (normalizedValue.startsWith(option.dialCode)) {
      return PhoneInputValue(
        dialCode: option.dialCode,
        localNumber: normalizedValue.substring(option.dialCode.length),
      );
    }
  }

  return PhoneInputValue(
    dialCode: normalizeDialCode(fallbackDialCode),
    localNumber: normalizedValue.startsWith('+')
        ? normalizedValue.substring(1)
        : normalizedValue,
  );
}

String formatPhoneNumberDisplay(
  String value, {
  String fallbackDialCode = defaultPhoneDialCode,
}) {
  final phoneInput = splitPhoneNumber(
    value,
    fallbackDialCode: fallbackDialCode,
  );
  if (phoneInput.localNumber.isEmpty) {
    return phoneInput.dialCode;
  }

  final chunks = <String>[];
  for (var index = 0; index < phoneInput.localNumber.length; index += 2) {
    final nextIndex = index + 2;
    final end = nextIndex > phoneInput.localNumber.length
        ? phoneInput.localNumber.length
        : nextIndex;
    chunks.add(phoneInput.localNumber.substring(index, end));
  }

  return '${phoneInput.dialCode} ${chunks.join(' ')}'.trim();
}

String? _detectDialCode(String digits) {
  for (final option in _sortedCountries) {
    final dialDigits = option.dialCode.substring(1);
    if (digits.startsWith(dialDigits) && digits.length > dialDigits.length) {
      return option.dialCode;
    }
  }
  return null;
}

final List<PhoneCountryOption> _sortedCountries = [
  ...supportedPhoneCountries,
]..sort((left, right) => right.dialCode.length.compareTo(left.dialCode.length));
