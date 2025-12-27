import 'package:flutter/material.dart';
import '../theme/nothing_theme.dart';

class NothingCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderWidth;
  final Color? backgroundColor;

  const NothingCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderWidth = 2.0,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Use provided backgroundColor, or fallback to default logic
    final bgColor = backgroundColor ?? (isDark ? const Color(0xFF1A1A1A) : NothingTheme.white);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          border: borderWidth > 0 
              ? Border.all(
                  color: Theme.of(context).colorScheme.onSurface,
                  width: borderWidth,
                )
              : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      ),
    );
  }
}

class NothingCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final double borderWidth;

  const NothingCheckbox({super.key, required this.value, required this.onChanged, this.borderWidth = 2.0});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () => onChanged(!value),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: value
              ? NothingTheme.red
              : (isDark ? const Color(0xFF1A1A1A) : NothingTheme.white),
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurface,
            width: borderWidth,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: value
            ? const Icon(Icons.check, size: 16, color: NothingTheme.white)
            : null,
      ),
    );
  }
}

class NothingButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const NothingButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: NothingTheme.black,
        foregroundColor: NothingTheme.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}


class MatrixCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const MatrixCard({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white24 : NothingTheme.lightGrey;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : NothingTheme.white,
          border: Border.all(color: borderColor, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CustomPaint(
            painter: GridPainter(
              color: isDark ? Colors.white10 : NothingTheme.lightGrey.withOpacity(0.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final Color color;

  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const step = 20.0;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) => color != oldDelegate.color;
}
