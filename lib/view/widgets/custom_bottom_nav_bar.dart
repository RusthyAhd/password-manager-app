import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:secure_vault/view/theme/app_colors.dart';

class CustomBottomNavBar extends StatefulWidget {
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
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  bool _addPressed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Glass background for nav bar
          Container(
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Home
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: widget.onHomePressed,
                          borderRadius: BorderRadius.circular(12),
                          splashColor: Colors.white.withValues(alpha: 0.18),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              Icons.home_outlined,
                              size: 28,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                      ),

                      // spacing for center button
                      const SizedBox(width: 60),

                      // Search
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: widget.onSearchPressed,
                          borderRadius: BorderRadius.circular(12),
                          splashColor: Colors.white.withValues(alpha: 0.18),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              Icons.search,
                              size: 28,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ===== ANIMATED FLOATING ADD BUTTON =====
          Positioned(
            top: -15,
            child: AnimatedScale(
              scale: _addPressed ? 0.9 : 1.0,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              child: GestureDetector(
                onTapDown: (_) => setState(() => _addPressed = true),
                onTapUp: (_) {
                  setState(() => _addPressed = false);
                  widget.onAddPressed();
                },
                onTapCancel: () => setState(() => _addPressed = false),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF0088FF),
                        const Color(0xFF4DB8FF),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0088FF).withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 36),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
