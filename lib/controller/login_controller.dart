import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:secure_vault/data/vault_repository.dart';

class LoginController {
  final TextEditingController passwordController = TextEditingController();
  final VaultRepository _repository = VaultRepository.instance;
  final LocalAuthentication _auth = LocalAuthentication();

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

  // Biometric authentication
  Future<bool> canUseBiometrics() async {
    try {
      final canAuthWithBio = await _auth.canCheckBiometrics;
      return canAuthWithBio;
    } catch (e) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final isAuthenticated = await _auth.authenticate(
        localizedReason: 'Authenticate to unlock your vault',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          useErrorDialogs: false,
        ),
      );
      return isAuthenticated;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    passwordController.dispose();
  }
}
