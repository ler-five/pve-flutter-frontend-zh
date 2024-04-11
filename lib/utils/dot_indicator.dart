import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class Dot extends StatelessWidget {
  final double? dotSpacing;
  final double? dotSize;
  final double? zoom;
  final double? shadowBlurRadius;
  final double? shadowSpreadRadius;
  final Color? color;
  final int? index;
  final void Function(int? index)? onTap;

  const Dot({
    super.key,
    this.dotSpacing,
    this.dotSize,
    this.zoom,
    this.shadowBlurRadius,
    this.shadowSpreadRadius,
    this.color,
    this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: dotSpacing,
      child: Center(
        child: Container(
          width: dotSize! * zoom!,
          height: dotSize! * zoom!,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Colors.white.withOpacity(0.72),
                  blurRadius: shadowBlurRadius!,
                  spreadRadius: shadowSpreadRadius!,
                  offset: const Offset(0.0, 0.0))
            ],
          ),
          child: GestureDetector(
            onTap: () => onTap!(index),
          ),
        ),
      ),
    );
  }
}

class DotIndicator extends AnimatedWidget {
  const DotIndicator({
    super.key,
    required this.controller,
    this.itemCount,
    this.onPageSelected,
    this.color = Colors.white,
    this.page,
    this.initialPage,
  }) : super(listenable: controller);

  final PageController controller;
  final double? page;
  final double? initialPage;

  final int? itemCount;

  final ValueChanged<int?>? onPageSelected;
  final Color color;

  static const double _dotSize = 8.0;
  static const double _maxZoom = 1.2;
  static const double _dotSpacing = 25.0;

  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((controller.page ?? controller.initialPage) - index).abs(),
      ),
    );
    double zoom = 1.0 + (_maxZoom - 1.0) * selectedness;
    double shadowBlurRadius = 4.0 * selectedness;
    double shadowSpreadRadius = 1.0 * selectedness;
    return Dot(
      color: color,
      shadowBlurRadius: shadowBlurRadius,
      shadowSpreadRadius: shadowSpreadRadius,
      dotSize: _dotSize,
      dotSpacing: _dotSpacing,
      zoom: zoom,
      index: index,
      onTap: onPageSelected,
    );
  }

  Widget build(BuildContext contect) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List<Widget>.generate(
          itemCount!,
          _buildDot,
        ));
  }
}
