import 'package:cuberto_bottom_bar/cuberto_bottom_bar.dart';
import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Define your tab data
    final List<TabData> tabs = [
      const TabData(
        key: Key('Home'),
        iconData: Icons.home,
        title: 'Home',
      ),
      const TabData(
        key: Key('Dashboard'),
        iconData: Icons.dashboard,
        title: 'Dashboard',
      ),
      const TabData(
        key: Key('Browse'),
        iconData: Icons.saved_search,
        title: 'Browse',
      ),
      const TabData(
        key: Key('Profile'),
        iconData: Icons.person,
        title: 'Profile',
      ),
    ];

    return Container(
      height: 70, // Increased height for the navbar
      color: const Color(0xFFFFF3E0), // Background color for the navbar
      child: CubertoBottomBar(
        key: const Key("BottomBar"),
        inactiveIconColor: const Color(0xFFC68181), // Darker inactive color
        tabStyle: CubertoTabStyle.styleNormal,
        selectedTab: currentIndex, // Current selected tab index
        tabs: tabs,
        onTabChangedListener: (position, title, color) {
          onTap(position); // Call the onTap function with the selected index
        },
        textColor: const Color(0xFFFFF3E0), // Darker text color for better contrast
        barBackgroundColor: const Color(0xFFFFF3E0), // A slightly darker shade for the bar background
      ),
    );
  }
}
