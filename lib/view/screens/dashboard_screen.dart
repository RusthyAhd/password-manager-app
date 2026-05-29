import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:secure_vault/controller/dashboard_controller.dart';
import 'package:secure_vault/data/vault_repository.dart';
import 'package:secure_vault/model/password_item.dart';
import 'package:secure_vault/view/theme/app_colors.dart';
import 'package:secure_vault/view/widgets/custom_bottom_nav_bar.dart';
import 'package:secure_vault/view/widgets/section_header.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final DashboardController controller = DashboardController();
  final VaultRepository repository = VaultRepository.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: const Text(
          'Dashboard',
          style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.w700),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        onHomePressed: () {},
        onAddPressed: () => Navigator.of(context).pushNamed('/add-password'),
        onSearchPressed:
            () => Navigator.of(context).pushNamed('/search-filter'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
      
          ValueListenableBuilder<Box<PasswordItem>>(
            valueListenable: repository.listenable(),
            builder: (context, box, _) {
              return _buildStatsCard(box.values.length);
            },
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Recently Added'),
          const SizedBox(height: 12),
          ValueListenableBuilder<Box<PasswordItem>>(
            valueListenable: repository.listenable(),
            builder: (context, box, _) {
              final items = box.values.toList()
                ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
              return _buildRecentList(items.take(4).toList());
            },
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Categories'),
          const SizedBox(height: 12),
          _buildCategories(),
        ],
      ),
    );
  }

  

  Widget _buildStatsCard(int totalSaved) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lock, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Saved Passwords',
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 4),
              Text(
                totalSaved.toString(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentList(List<PasswordItem> items) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text('No recent items', style: TextStyle(color: AppColors.muted)),
      );
    }

    return Column(
      children:
          items
              .map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.12,
                        ),
                        child: Text(
                          item.appName.isNotEmpty
                              ? item.appName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.appName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.muted),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildCategories() {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children:
          controller.categories
              .map(
                (category) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.12,
                        ),
                        child: Icon(category.icon, color: AppColors.primary),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        category.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '24 items',
                        style: TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }
}
