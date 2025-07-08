
import 'package:flutter/material.dart';

class TCirculerContainer extends StatelessWidget {
  const TCirculerContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.radius = 400,
    this.padding = 0,
    this.margin,
    this.backgroundColor = Colors.white,
  });

  final double? width;
  final double? height;
  final double radius;
  final double padding;
  final EdgeInsets? margin;
  final Widget? child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: backgroundColor,
      ),
      child: child,
    );
  }
}
