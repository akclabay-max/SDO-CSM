import 'package:flutter/material.dart';

class SimpleTiledBackground extends StatelessWidget {
  final Widget child;
  final String pngPath;

  const SimpleTiledBackground({
    super.key,
    required this.child,
    required this.pngPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(pngPath),
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: child,
    );
  }
}