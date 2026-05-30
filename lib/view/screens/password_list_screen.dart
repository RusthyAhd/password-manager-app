import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:secure_vault/controller/password_list_controller.dart';
import 'package:secure_vault/model/password_item.dart';
import 'package:secure_vault/view/theme/app_colors.dart';
import 'package:secure_vault/view/widgets/custom_bottom_nav_bar.dart';
import 'package:secure_vault/view/widgets/glassmorphism_card.dart';

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
              return GlassmorphismCard(
                icon: Icons.lock_outline,
                title: item.appName,
                description: item.username,
                onTap:
                    () => Navigator.of(
                      context,
                    ).pushNamed('/add-password', arguments: item),
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
                iconGradient: const LinearGradient(
                  colors: [Color(0xFF0088FF), Color(0xFF4DB8FF)],
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
