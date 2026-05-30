import 'dart:ui';

import 'package:flutter/material.dart';

class GlassmorphismCard extends StatefulWidget {
  const GlassmorphismCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
    this.buttonLabel,
    this.onButtonPressed,
    this.child,
    this.trailing,
    this.padding = const EdgeInsets.all(18),
    this.blur = 18,
    this.borderRadius = 18,
    this.iconGradient,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;
  final Widget? child;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final double blur;
  final double borderRadius;
  final Gradient? iconGradient;

  @override
  State<GlassmorphismCard> createState() => _GlassmorphismCardState();
}

class _GlassmorphismCardState extends State<GlassmorphismCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final canShowButton =
      widget.buttonLabel != null && widget.onButtonPressed != null;
    final borderRadius = BorderRadius.circular(widget.borderRadius);

    return AnimatedScale(
      scale: _pressed ? 0.985 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                onHighlightChanged: (value) {
                  setState(() => _pressed = value);
                },
                borderRadius: borderRadius,
                splashColor: Colors.white.withValues(alpha: 0.18),
                highlightColor: Colors.white.withValues(alpha: 0.08),
                child: Container(
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: borderRadius,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: widget.iconGradient != null
                            ? ShaderMask(
                                shaderCallback: (bounds) =>
                                    widget.iconGradient!.createShader(bounds),
                                child: Icon(
                                  widget.icon,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              )
                            : Icon(widget.icon, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.description,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                            if (widget.child != null) ...[
                              const SizedBox(height: 12),
                              widget.child!,
                            ],
                            if (canShowButton) ...[
                              const SizedBox(height: 12),
                              FilledButton.tonal(
                                onPressed: widget.onButtonPressed,
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.22,
                                  ),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                                child: Text(widget.buttonLabel!),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (widget.trailing != null) ...[
                        const SizedBox(width: 8),
                        widget.trailing!,
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
