import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:secure_vault/model/password_item.dart';

class VaultRepository {
  VaultRepository._();

  static final VaultRepository instance = VaultRepository._();

  static const String passwordsBoxName = 'passwords';
  static const String settingsBoxName = 'settings';
  static const String masterPasswordKey = 'master_password_hash';

  late Box<PasswordItem> _passwordBox;
  late Box _settingsBox;

  Future<void> init() async {
    _passwordBox = await Hive.openBox<PasswordItem>(passwordsBoxName);
    _settingsBox = await Hive.openBox(settingsBoxName);
  }

  bool get hasMasterPassword => _settingsBox.containsKey(masterPasswordKey);

  String? get masterPasswordHash =>
      _settingsBox.get(masterPasswordKey) as String?;

  Future<void> setMasterPasswordHash(String hash) async {
    await _settingsBox.put(masterPasswordKey, hash);
  }

  List<PasswordItem> getAllPasswords() {
    return _passwordBox.values.toList();
  }

  ValueListenable<Box<PasswordItem>> listenable() {
    return _passwordBox.listenable();
  }

  PasswordItem? getById(String id) {
    return _passwordBox.get(id);
  }

  Future<void> savePassword(PasswordItem item) async {
    await _passwordBox.put(item.id, item);
  }

  Future<void> deletePassword(String id) async {
    await _passwordBox.delete(id);
  }
}
