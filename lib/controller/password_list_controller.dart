import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:secure_vault/data/vault_repository.dart';
import 'package:secure_vault/model/password_item.dart';

class PasswordListController {
  final VaultRepository _repository = VaultRepository.instance;

  ValueListenable<Box<PasswordItem>> listenable() {
    return _repository.listenable();
  }

  Future<void> deletePassword(String id) async {
    await _repository.deletePassword(id);
  }
}
