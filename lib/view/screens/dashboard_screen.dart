import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:secure_vault/controller/dashboard_controller.dart';
import 'package:secure_vault/data/vault_repository.dart';
import 'package:secure_vault/model/password_item.dart';
import 'package:secure_vault/view/theme/app_colors.dart';
import 'package:secure_vault/view/widgets/custom_bottom_nav_bar.dart';
import 'package:secure_vault/view/widgets/glassmorphism_card.dart';
import 'package:secure_vault/view/widgets/section_header.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  final DashboardController controller = DashboardController();
  final VaultRepository repository = VaultRepository.instance;
  late AnimationController _statsAnimController;

  @override
  void initState() {
    super.initState();
    _statsAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _statsAnimController.dispose();
    super.dispose();
  }

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
              final items =
                  box.values.toList()
                    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
              return _buildRecentList(context, items.take(4).toList());
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
    const gradient = LinearGradient(
      colors: [
        Color(0xFF0088FF),
        Color(0xFF4DB8FF),
      ],
    );
    return GlassmorphismCard(
      icon: Icons.lock_outline,
      title: 'Total Saved Passwords',
      description: '$totalSaved stored securely in your vault',
      onTap: () => Navigator.of(context).pushNamed('/password-list'),
      buttonLabel: 'View All',
      onButtonPressed: () => Navigator.of(context).pushNamed('/password-list'),
      iconGradient: gradient,
    );
  }

  Widget _buildRecentList(BuildContext context, List<PasswordItem> items) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'No recent items',
          style: TextStyle(color: AppColors.muted),
        ),
      );
    }

    return Column(
      children:
          items.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            return _InteractiveRecentItem(
              item: item,
              delay: Duration(milliseconds: idx * 50),
              onTap:
                  () => Navigator.of(
                    context,
                  ).pushNamed('/add-password', arguments: item),
            );
          }).toList(),
    );
  }

  Widget _buildCategories() {
    return ValueListenableBuilder<Box<PasswordItem>>(
      valueListenable: repository.listenable(),
      builder: (context, box, _) {
        final items = box.values.toList();
        final Map<String, int> counts = {};
        for (final it in items) {
          final key = (it.category ?? 'Uncategorized').trim();
          counts[key] = (counts[key] ?? 0) + 1;
        }

        final categories = counts.keys.toList()..sort();

        if (categories.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'No categories yet',
              style: TextStyle(color: AppColors.muted),
            ),
          );
        }

        return GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children:
              categories.map((name) {
                final icon = controller.iconForCategory(name);
                final count = counts[name] ?? 0;
                const gradient = LinearGradient(
                  colors: [
                    Color(0xFF0088FF),
                    Color(0xFF4DB8FF),
                  ],
                );
                return GlassmorphismCard(
                  icon: icon,
                  title: name,
                  description: '$count items',
                  padding: const EdgeInsets.all(14),
                  borderRadius:12,
                  iconGradient: gradient,
                );
              }).toList(),
        );
      },
    );
  }
}

class _InteractiveRecentItem extends StatefulWidget {
  final PasswordItem item;
  final VoidCallback onTap;
  final Duration delay;

  const _InteractiveRecentItem({
    required this.item,
    required this.onTap,
    required this.delay,
  });

  @override
  State<_InteractiveRecentItem> createState() => _InteractiveRecentItemState();
}

class _InteractiveRecentItemState extends State<_InteractiveRecentItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GlassmorphismCard(
          icon: Icons.vpn_key,
          title: widget.item.appName,
          description: widget.item.username,
          onTap: widget.onTap,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: widget.item.password),
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
            colors: [
              Color(0xFF0088FF),
              Color(0xFF4DB8FF),
            ],
          ),
        ),
      ),
    );
  }
}
