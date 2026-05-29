import 'package:flutter/material.dart';
import 'package:secure_vault/data/vault_repository.dart';
import 'package:secure_vault/model/category_item.dart';
import 'package:secure_vault/model/password_item.dart';

class DashboardController {
  final VaultRepository _repository = VaultRepository.instance;

  final List<CategoryItem> categories = const [
    CategoryItem(name: 'Social', icon: Icons.people_alt_outlined),
    CategoryItem(name: 'Finance', icon: Icons.account_balance_outlined),
    CategoryItem(name: 'Work', icon: Icons.work_outline),
    CategoryItem(name: 'Shopping', icon: Icons.shopping_bag_outlined),
  ];

  int get totalSaved => _repository.getAllPasswords().length;

  List<PasswordItem> getRecent({int limit = 4}) {
    final items = _repository.getAllPasswords();
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items.take(limit).toList();
  }
}
