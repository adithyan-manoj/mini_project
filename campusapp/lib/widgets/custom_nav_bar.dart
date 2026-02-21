import 'package:campusapp/core/app_colors.dart';
import 'package:flutter/material.dart';

class CustomAiamtedNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  const CustomAiamtedNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double itemWidth = MediaQuery.of(context).size.width / 4;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: AppColors.background,
          //border: Border(top: BorderSide(color: AppColors.accentBorder, width: 0.5)),
        ),
        child: Stack(
          children: [
            // 1. The Animated Background Pill
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic, // Professional smooth curve
              left: itemWidth * currentIndex + (itemWidth * 0.1), // Centering logic
              top: 10,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 55,
                width: itemWidth * 0.8,
                
                decoration: BoxDecoration(
                  color: Colors.white10, // Subtle highlight
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
      
            // 2. The Icons Row
            Row(
              children: [
                _navItem(Icons.people_alt_outlined, 0, "Community"),
                _navItem(Icons.event_note, 1, "Events"),
                _navItem(Icons.search, 2, "Lost & Found"),
                _navItem(Icons.post_add_rounded, 3, "Report"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int index, String label) {
    bool isSelected = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white : Colors.white54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
