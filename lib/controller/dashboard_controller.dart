import 'package:flutter/material.dart';
import 'package:secure_vault/data/vault_repository.dart';
import 'package:secure_vault/model/category_item.dart';
import 'package:secure_vault/model/password_item.dart';

class DashboardController {
  final VaultRepository _repository = VaultRepository.instance;

  List<CategoryItem> get categories {
    final items = _repository.getAllPasswords();
    final Map<String, int> counts = {};
    for (final it in items) {
      final key = (it.category ?? 'Uncategorized').trim();
      counts[key] = (counts[key] ?? 0) + 1;
    }

    final unique = counts.keys.toList()..sort();

    return unique
        .map((name) => CategoryItem(name: name, icon: iconForCategory(name)))
        .toList();
  }

  int get totalSaved => _repository.getAllPasswords().length;

  List<PasswordItem> getRecent({int limit = 4}) {
    final items = _repository.getAllPasswords();
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items.take(limit).toList();
  }

  IconData iconForCategory(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('social')) return Icons.people_alt_outlined;
    if (lower.contains('finance') || lower.contains('bank'))
      return Icons.account_balance_outlined;
    if (lower.contains('work') || lower.contains('business'))
      return Icons.work_outline;
    if (lower.contains('shop') || lower.contains('shopping'))
      return Icons.shopping_bag_outlined;
    if (lower.contains('entertain') || lower.contains('media'))
      return Icons.movie_outlined;
    return Icons.category;
  }
}
