import 'package:cuberto_bottom_bar/cuberto_bottom_bar.dart';
import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<TabData> tabs; // Accept tabs dynamically
  final Color? backgroundColor;
  final Color? inactiveColor;
  final Color? activeColor;
  final double height;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.tabs, // Add tabs as a required parameter
    this.backgroundColor = const Color(0xFFFFF3E0),
    this.inactiveColor = const Color(0xFFC68181),
    this.activeColor = Colors.white,
    this.height = 70,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: backgroundColor,
      child: CubertoBottomBar(
        key: const Key("BottomBar"),
        inactiveIconColor: inactiveColor,
        tabStyle: CubertoTabStyle.styleNormal,
        selectedTab: currentIndex,
        tabs: tabs,
        onTabChangedListener: (position, title, color) {
          onTap(position);
        },
        textColor: activeColor,
        barBackgroundColor: backgroundColor,
      ),
    );
  }
}
