import 'package:flutter/material.dart';

class CustomResetIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? backgroundColor;

  const CustomResetIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ?? Theme.of(context).iconTheme.color ?? Colors.black;
    final effectiveBackgroundColor = backgroundColor ?? Colors.grey.shade300;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Círculo de fondo
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: effectiveBackgroundColor,
              shape: BoxShape.circle,
            ),
          ),
          // Cuadrado central
          Container(
            width: size * 0.4, // 40% del tamaño total
            height: size * 0.4,
            decoration: BoxDecoration(
              color: effectiveColor,
              borderRadius: BorderRadius.circular(
                2,
              ), // Bordes ligeramente redondeados
            ),
          ),
        ],
      ),
    );
  }
}
