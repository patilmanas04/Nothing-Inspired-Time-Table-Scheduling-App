import 'package:flutter/material.dart';
import '../theme/nothing_theme.dart';

class NothingBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NothingBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 32, left: 48, right: 48),
      height: 72,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : NothingTheme.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: NothingTheme.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildIcon(context, 0, Icons.check_box_outlined),
          _buildIcon(context, 1, Icons.calendar_view_week_outlined),
          _buildIcon(context, 2, Icons.view_timeline_outlined),
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context, int index, IconData icon) {
    final isSelected = currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedColor = isDark ? NothingTheme.white : NothingTheme.black;
    
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Icon(
          icon,
          color: isSelected ? NothingTheme.red : unselectedColor,
          size: 28,
        ),
      ),
    );
  }
}
