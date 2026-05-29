class PasswordGeneratorOptions {
  PasswordGeneratorOptions({
    required this.length,
    required this.includeSymbols,
    required this.includeNumbers,
    required this.includeUppercase,
    required this.includeLowercase,
  });

  double length;
  bool includeSymbols;
  bool includeNumbers;
  bool includeUppercase;
  bool includeLowercase;
}
