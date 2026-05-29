import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:secure_vault/controller/password_list_controller.dart';
import 'package:secure_vault/model/password_item.dart';
import 'package:secure_vault/view/theme/app_colors.dart';
import 'package:secure_vault/view/widgets/custom_bottom_nav_bar.dart';

class PasswordListScreen extends StatelessWidget {
  PasswordListScreen({super.key});

  final PasswordListController controller = PasswordListController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Saved Passwords',
          style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.dark),
      ),
      body: ValueListenableBuilder<Box<PasswordItem>>(
        valueListenable: controller.listenable(),
        builder: (context, box, _) {
          final items =
              box.values.toList()
                ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

          if (items.isEmpty) {
            return const Center(
              child: Text(
                'No passwords yet',
                style: TextStyle(color: AppColors.muted),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return InkWell(
                onTap:
                    () => Navigator.of(
                      context,
                    ).pushNamed('/add-password', arguments: item),
                child: Container(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.appName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.username,
                              style: const TextStyle(color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
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
                        icon: const Icon(Icons.copy, color: AppColors.primary),
                      ),
                      IconButton(
                        onPressed:
                            () => Navigator.of(
                              context,
                            ).pushNamed('/add-password', arguments: item),
                        icon: const Icon(Icons.edit, color: AppColors.dark),
                      ),
                      IconButton(
                        onPressed: () async {
                          await controller.deletePassword(item.id);
                        },
                        icon: const Icon(Icons.delete, color: AppColors.danger),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        onHomePressed:
            () => Navigator.of(context).pushReplacementNamed('/dashboard'),
        onAddPressed: () => Navigator.of(context).pushNamed('/add-password'),
        onSearchPressed:
            () => Navigator.of(context).pushNamed('/search-filter'),
      ),
    );
  }
}
