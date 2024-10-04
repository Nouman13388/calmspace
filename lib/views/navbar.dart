import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context); // Get the current theme

    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map), // Updated icon for chat
          label: 'Map', // Updated label
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_2_sharp),
          label: 'Profile',
        ),
      ],
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: theme.colorScheme.primary, // Use primary color from theme
      unselectedItemColor: theme.iconTheme.color?.withOpacity(0.6), // Slightly faded color for unselected
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      backgroundColor: theme.scaffoldBackgroundColor, // Use background color from theme
    );
  }
}
