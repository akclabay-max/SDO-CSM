import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color? backgroundColor;
  final List<Widget>? actions;
  final Widget? leading;
  final double height;
  final Gradient? gradient;
  final BoxShadow? boxShadow;

  const CustomAppBar({
    super.key,
    required this.title,
    this.backgroundColor = Colors.white,
    this.actions,
    this.leading,
    this.height = 56,
    this.gradient,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive font size for title
    double titleFontSize;
    if (screenWidth < 480) {
      titleFontSize = 14;
    } else if (screenWidth < 768) {
      titleFontSize = 18;
    } else {
      titleFontSize = 22;
    }
    
    // Responsive padding
    double horizontalPadding;
    if (screenWidth < 480) {
      horizontalPadding = 8;
    } else if (screenWidth < 768) {
      horizontalPadding = 12;
    } else {
      horizontalPadding = 16;
    }
    
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: gradient == null ? backgroundColor : null,
        gradient: gradient,
        boxShadow: boxShadow != null
            ? [boxShadow!]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          // Leading widget (like back button or logo)
          if (leading != null)
            Padding(
              padding: EdgeInsets.only(left: horizontalPadding),
              child: leading,
            ),
          
          // Title
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: Colors.black,
                  fontFamily: 'Roboto',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          
          // Action buttons
          if (actions != null)
            Row(
              children: actions!,
            ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}