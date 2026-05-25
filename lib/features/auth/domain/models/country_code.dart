class CountryCode {
  final String name;
  final String code;
  final String dialCode;
  final String flag;

  const CountryCode({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
  });
}

const List<CountryCode> supportedCountryCodes = [
  CountryCode(name: 'Malta', code: 'MT', dialCode: '+356', flag: '🇲🇹'),
  CountryCode(name: 'India', code: 'IN', dialCode: '+91', flag: '🇮🇳'),
  CountryCode(name: 'Pakistan', code: 'PK', dialCode: '+92', flag: '🇵🇰'),
  CountryCode(name: 'Bangladesh', code: 'BD', dialCode: '+880', flag: '🇧🇩'),
  CountryCode(name: 'Sri Lanka', code: 'LK', dialCode: '+94', flag: '🇱🇰'),
  CountryCode(name: 'United Kingdom', code: 'GB', dialCode: '+44', flag: '🇬🇧'),
  CountryCode(name: 'United States', code: 'US', dialCode: '+1', flag: '🇺🇸'),
  CountryCode(name: 'UAE', code: 'AE', dialCode: '+971', flag: '🇦🇪'),
];
