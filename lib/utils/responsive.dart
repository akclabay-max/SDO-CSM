import 'package:flutter/material.dart';

/// Responsive design utility class providing adaptive values based on screen size
class Responsive {
  static const double mobileBreakpoint = 480;
  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1024;

  /// Check if device is in mobile view
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < tabletBreakpoint;

  /// Check if device is in tablet view
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint &&
      MediaQuery.of(context).size.width < desktopBreakpoint;

  /// Check if device is in desktop view
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  /// Get responsive font size
  static double fontSize(
    BuildContext context, {
    double mobile = 14,
    double tablet = 16,
    double desktop = 18,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width < tabletBreakpoint) return mobile;
    if (width < desktopBreakpoint) return tablet;
    return desktop;
  }

  /// Get responsive padding
  static double padding(
    BuildContext context, {
    double mobile = 8,
    double tablet = 12,
    double desktop = 16,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width < tabletBreakpoint) return mobile;
    if (width < desktopBreakpoint) return tablet;
    return desktop;
  }

  /// Get responsive width (useful for clamping content)
  static double containerWidth(
    BuildContext context, {
    double maxWidth = 1200,
    double mobileMargin = 12,
    double tabletMargin = 24,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < tabletBreakpoint) {
      return screenWidth - (mobileMargin * 2);
    } else if (screenWidth < desktopBreakpoint) {
      return screenWidth - (tabletMargin * 2);
    }
    return maxWidth;
  }

  /// Get responsive grid columns
  static int gridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < tabletBreakpoint) return 1;
    if (width < desktopBreakpoint) return 2;
    return 4;
  }

  /// Get responsive card spacing
  static double cardSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < tabletBreakpoint) return 8;
    if (width < desktopBreakpoint) return 12;
    return 16;
  }

  /// Get responsive chart height
  static double chartHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < tabletBreakpoint) return 250;
    if (width < desktopBreakpoint) return 300;
    return 350;
  }
}
