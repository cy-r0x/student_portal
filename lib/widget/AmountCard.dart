import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:ui';
import 'dart:math' as math;

String formatCurrency(double amount) {
  final format = NumberFormat.currency(locale: 'en_US', symbol: 'BDT ');
  return format.format(amount);
}

class AmountCard extends StatefulWidget {
  final String cardType;
  final double amountCredit;
  final Color bgColor;
  final bool isRefreshing;
  final IconData? icon;

  const AmountCard({
    Key? key,
    required this.cardType,
    required this.amountCredit,
    required this.bgColor,
    required this.isRefreshing,
    this.icon,
  }) : super(key: key);

  @override
  State<AmountCard> createState() => _AmountCardState();
}

class _AmountCardState extends State<AmountCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Generate a slightly darker shade for gradient
    final Color darkerShade = HSLColor.fromColor(widget.bgColor)
        .withLightness(math.max(0.0, HSLColor.fromColor(widget.bgColor).lightness - 0.15))
        .toColor();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: widget.bgColor.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.bgColor,
                  darkerShade,
                ],
                stops: const [0.3, 1.0],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Stack(
              children: [
                // Animated background patterns
                Positioned(
                  right: -40,
                  bottom: -40,
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + 0.1 * _animationController.value,
                        child: Opacity(
                          opacity: 0.15,
                          child: Container(
                            height: 160,
                            width: 160,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  left: -20,
                  top: -20,
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + 0.15 * _animationController.value,
                        child: Opacity(
                          opacity: 0.1,
                          child: Container(
                            height: 120,
                            width: 120,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Card Type Label
                            Row(
                              children: [
                                if (widget.icon != null) ...[
                                  Icon(
                                    widget.icon,
                                    color: Colors.white.withOpacity(0.9),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Text(
                                  widget.cardType,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Amount
                            widget.isRefreshing
                                ? Shimmer.fromColors(
                                    baseColor: Colors.white.withOpacity(0.4),
                                    highlightColor: Colors.white.withOpacity(0.8),
                                    child: Container(
                                      width: 220,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  )
                                : TweenAnimationBuilder<double>(
                                    duration: const Duration(milliseconds: 800),
                                    curve: Curves.easeOutCubic,
                                    tween: Tween(begin: 0.0, end: widget.amountCredit),
                                    builder: (context, value, child) {
                                      return Text(
                                        formatCurrency(value),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          height: 1.2,
                                          letterSpacing: 0.5,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black26,
                                              blurRadius: 8,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                            const SizedBox(height: 8),
                            // Additional info text
                            Text(
                              'Updated Today',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

