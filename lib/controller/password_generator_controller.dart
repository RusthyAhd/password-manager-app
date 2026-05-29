import 'dart:math';

import 'package:secure_vault/model/password_generator_options.dart';

class PasswordGeneratorController {
  PasswordGeneratorOptions options = PasswordGeneratorOptions(
    length: 16,
    includeSymbols: true,
    includeNumbers: true,
    includeUppercase: true,
    includeLowercase: true,
  );

  String samplePassword = 'P@ssw0rd!#A8k2L';

  String generate() {
    const symbols = '!@#\$%^&*()-_=+[]{}<>?/';
    const numbers = '0123456789';
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';

    final buffer = StringBuffer();
    final pool = StringBuffer();

    if (options.includeSymbols) pool.write(symbols);
    if (options.includeNumbers) pool.write(numbers);
    if (options.includeUppercase) pool.write(uppercase);
    if (options.includeLowercase) pool.write(lowercase);

    final poolString = pool.toString();
    if (poolString.isEmpty) return samplePassword;

    final rand = Random.secure();
    for (int i = 0; i < options.length.round(); i++) {
      buffer.write(poolString[rand.nextInt(poolString.length)]);
    }

    samplePassword = buffer.toString();
    return samplePassword;
  }
}
