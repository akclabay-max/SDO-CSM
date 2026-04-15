import 'package:flutter/material.dart';

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final double? minWidth;
  final EdgeInsets? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 800,
    this.minWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Determine responsive padding based on screen size
    EdgeInsets responsivePadding;
    if (screenWidth < 480) {
      responsivePadding = const EdgeInsets.all(12.0);
    } else if (screenWidth < 768) {
      responsivePadding = const EdgeInsets.all(16.0);
    } else if (screenWidth < 1024) {
      responsivePadding = const EdgeInsets.all(20.0);
    } else {
      responsivePadding = const EdgeInsets.all(24.0);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Clamp width to reasonable container size
        double containerWidth;
        if (screenWidth < 480) {
          // Mobile: use full width minus padding
          containerWidth = screenWidth - (responsivePadding.left + responsivePadding.right);
        } else if (screenWidth < 768) {
          // Small tablet: use full width with more margin
          containerWidth = screenWidth - 32;
        } else {
          // Larger screens: respect maxWidth
          containerWidth = constraints.maxWidth > maxWidth 
            ? maxWidth 
            : constraints.maxWidth - (responsivePadding.left + responsivePadding.right);
        }

        return Center(
          child: Container(
            width: containerWidth,
            padding: padding ?? responsivePadding,
            child: child,
          ),
        );
      },
    );
  }
}