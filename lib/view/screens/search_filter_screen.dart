import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:secure_vault/controller/search_filter_controller.dart';
import 'package:secure_vault/data/vault_repository.dart';
import 'package:secure_vault/model/password_item.dart';
import 'package:secure_vault/view/theme/app_colors.dart';
import 'package:secure_vault/view/widgets/custom_bottom_nav_bar.dart';
import 'package:secure_vault/view/widgets/glassmorphism_card.dart';
import 'package:secure_vault/view/widgets/section_header.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  final SearchFilterController _controller = SearchFilterController();
  final TextEditingController _searchController = TextEditingController();
  final VaultRepository _repository = VaultRepository.instance;
  final Set<String> _activeFilters = {'Website'};
  String _category = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Search & Filter',
          style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.dark),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search by website, username, or category',
              prefixIcon: const Icon(Icons.search, color: AppColors.muted),
              filled: true,
              fillColor: AppColors.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Search By'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children:
                _controller.filterTypes.map((filter) {
                  final bool isActive = _activeFilters.contains(filter);
                  return FilterChip(
                    label: Text(filter),
                    selected: isActive,
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          _activeFilters.add(filter);
                        } else {
                          _activeFilters.remove(filter);
                        }
                      });
                    },
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Category'),
          const SizedBox(height: 10),
          ValueListenableBuilder<Box<PasswordItem>>(
            valueListenable: _repository.listenable(),
            builder: (context, box, _) {
              final items = box.values.toList();
              final set = <String>{};
              for (final it in items) {
                set.add((it.category ?? 'Uncategorized').trim());
              }
              final categories = ['All', ...set.toList()..sort()];

              return DropdownButtonFormField<String>(
                value: categories.contains(_category) ? _category : 'All',
                items: categories
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _category = value);
                  }
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Results'),
          const SizedBox(height: 8),
          ValueListenableBuilder<Box<PasswordItem>>(
            valueListenable: _repository.listenable(),
            builder: (context, box, _) {
              return _buildResults(box.values.toList());
            },
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        onHomePressed:
            () => Navigator.of(context).pushReplacementNamed('/dashboard'),
        onAddPressed: () => Navigator.of(context).pushNamed('/add-password'),
        onSearchPressed: () {},
      ),
    );
  }

  Widget _buildResults(List<PasswordItem> items) {
    final query = _searchController.text.trim().toLowerCase();
    final filters =
        _activeFilters.isEmpty
            ? _controller.filterTypes.toSet()
            : _activeFilters;
    final filtered =
        items.where((item) {
          final matchCategory =
              _category == 'All' || item.category == _category;
          if (!matchCategory) return false;

          if (query.isEmpty) return true;

          final matchesWebsite =
              filters.contains('Website') &&
              item.appName.toLowerCase().contains(query);
          final matchesUsername =
              filters.contains('Username') &&
              item.username.toLowerCase().contains(query);
          final matchesCategory =
              filters.contains('Category') &&
              item.category.toLowerCase().contains(query);

          return matchesWebsite || matchesUsername || matchesCategory;
        }).toList();

    if (filtered.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text('No results', style: TextStyle(color: AppColors.muted)),
      );
    }

    return Column(children: filtered.map(_buildResultTile).toList());
  }

  Widget _buildResultTile(PasswordItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassmorphismCard(
        icon: Icons.key,
        title: item.appName,
        description: item.username,
        onTap: () =>
            Navigator.of(context).pushNamed('/add-password', arguments: item),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(text: item.password),
                );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password copied')),
                );
              },
              icon: const Icon(Icons.content_copy, color: Colors.white),
            ),
            const Icon(Icons.chevron_right, color: Colors.white70),
          ],
        ),
        padding: const EdgeInsets.all(14),
        borderRadius: 14,
        iconGradient: const LinearGradient(
          colors: [
            Color(0xFF0088FF),
            Color(0xFF4DB8FF),
          ],
        ),
      ),
    );
  }
}
