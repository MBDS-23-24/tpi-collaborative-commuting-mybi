import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemSelected;
  final PageType currentPageType;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onItemSelected,
    required this.currentPageType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildBottomNavItem(
            icon: Icons.home,
            label: 'Home',
            index: 0,
            context: context,
            pageType: PageType.Home,
          ),
          _buildBottomNavItem(
            icon: MaterialCommunityIcons.compass_outline,
            label: 'Navigation',
            index: 1,
            context: context,
            pageType: PageType.Navigation,
          ),
          _buildBottomNavItem(
            icon: Icons.message,
            label: 'Messages',
            index: 2,
            context: context,
            pageType: PageType.Messages,
          ),
          _buildBottomNavItem(
            icon: Icons.more_vert,
            label: 'More',
            index: 3,
            context: context,
            pageType: PageType.More,
          ),
          _buildBottomNavItem( // Nouvelle icône ajoutée
            icon: Icons.travel_explore, // Changez selon l'icône que vous souhaitez
            label: 'Voyages',
            index: 4, // Nouvel index pour le nouveau bouton
            context: context,
            pageType: PageType.Voyages,
          ),
        ],
      ),
    );

  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required int index,
    required BuildContext context,
    required PageType pageType,
  }) {
    bool isSelected = currentIndex == index;
    Color iconColor = isSelected ? Theme.of(context).primaryColor : Colors.grey;
    Color textColor = isSelected ? Theme.of(context).primaryColor : Colors.grey;

    // Customize appearance based on page type
    if (pageType == currentPageType) {
      // Apply specific styling for the current page type
      iconColor = Colors.blue; // Change to the desired color
      textColor = Colors.transparent; // Change to the desired color
    }

    return InkWell(
      onTap: () => onItemSelected(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, color: iconColor),
          Text(
            label,
            style: TextStyle(
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

enum PageType {
  Home,
  Navigation,
  Messages,
  More,
  Voyages, // Nouvelle page ajoutée

}
