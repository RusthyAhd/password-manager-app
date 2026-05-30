import 'package:secure_vault/data/vault_repository.dart';

class SearchFilterController {
  final VaultRepository _repository = VaultRepository.instance;

  List<String> get categories {
    final items = _repository.getAllPasswords();
    final set = <String>{};
    for (final it in items) {
      set.add((it.category ?? 'Uncategorized').trim());
    }
    final list = set.toList()..sort();
    return ['All', ...list];
  }

  final List<String> filterTypes = const ['Website', 'Username', 'Category'];
}
