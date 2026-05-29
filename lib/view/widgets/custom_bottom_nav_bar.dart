import 'package:flutter/material.dart';
import 'package:secure_vault/view/theme/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    super.key,
    required this.onHomePressed,
    required this.onAddPressed,
    required this.onSearchPressed,
  });

  final VoidCallback onHomePressed;
  final VoidCallback onAddPressed;
  final VoidCallback onSearchPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Stack(
        clipBehavior: Clip.none, 
        alignment: Alignment.center,
        children: [
       
          Container(
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Home
                GestureDetector(
                  onTap: onHomePressed,
                  child: const Icon(
                    Icons.home_outlined,
                    size: 28,
                    color: Color(0xFF6B7280),
                  ),
                ),

                // spacing for center button
                const SizedBox(width: 60),

                // Search
                GestureDetector(
                  onTap: onSearchPressed,
                  child: const Icon(
                    Icons.search,
                    size: 28,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          // ===== FLOATING ADD BUTTON (ON TOP LAYER) =====
          Positioned(
            top: -15, // 👈 pushes it above navbar
            child: GestureDetector(
              onTap: onAddPressed,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF0088FF),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0088FF).withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}