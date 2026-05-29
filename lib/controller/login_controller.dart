import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:secure_vault/data/vault_repository.dart';

class LoginController {
  final TextEditingController passwordController = TextEditingController();
  final VaultRepository _repository = VaultRepository.instance;

  bool get hasMasterPassword => _repository.hasMasterPassword;

  String? get masterPasswordHash => _repository.masterPasswordHash;

  String hashPassword(String value) {
    return sha256.convert(utf8.encode(value)).toString();
  }

  Future<void> setMasterPassword(String password) async {
    await _repository.setMasterPasswordHash(hashPassword(password));
  }

  bool verifyPassword(String password) {
    final storedHash = masterPasswordHash;
    if (storedHash == null) return false;
    return storedHash == hashPassword(password);
  }

  void dispose() {
    passwordController.dispose();
  }
}
