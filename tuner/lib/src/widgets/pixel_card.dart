import 'package:flutter/widgets.dart';

/// Retro-raised container: 2px outer solid border + 1px inset top/left
/// highlight. Imitates NES.css raised-button feel without shadows.
class PixelCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const PixelCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border.fromBorderSide(
          BorderSide(color: Color(0xFF2A2A2A), width: 2),
        ),
      ),
      padding: const EdgeInsets.all(1),
      child: Container(
        padding: padding,
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          border: Border(
            top: BorderSide(color: Color(0x30FFFFFF), width: 1),
            left: BorderSide(color: Color(0x30FFFFFF), width: 1),
          ),
        ),
        child: child,
      ),
    );
  }
}
