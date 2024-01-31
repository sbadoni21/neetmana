import 'package:flutter/material.dart';
import 'package:matrimonial/utils/static.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.people, 'People', 0),
          _buildNavItem(Icons.bookmark_add, 'Saved', 1),
          _buildNavItem(Icons.person, 'Profile', 2),
          _buildNavItem(Icons.chat, 'Chats', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: currentIndex == index ? Colors.white : Colors.white54,
            size: currentIndex == index ? 32 : 24,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: currentIndex == index ? 14 : 10,
              color: currentIndex == index ? Colors.white : Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}
