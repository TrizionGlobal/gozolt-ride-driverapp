import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      // Background color fills the entire area
      color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              child: BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: onTap,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
                unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
                selectedFontSize: 12,
                unselectedFontSize: 12,
                elevation: 0,
                items: [
                  _buildItem(Icons.home_rounded, 'Home', 0),
                  _buildItem(
                      Icons.account_balance_wallet_rounded, 'Earning', 1),
                  _buildItem(Icons.history_rounded, 'History', 2),
                  _buildItem(Icons.person_rounded, 'Account', 3),
                ],
              ),
            ),
          ),
          if (bottomPadding > 0)
            Container(
              color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
              height: bottomPadding,
            ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildItem(IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 26),
          const SizedBox(height: 4),
          if (currentIndex == index)
            Container(
              width: 32,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.primaryGold,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
        ],
      ),
      label: label,
    );
  }
}

