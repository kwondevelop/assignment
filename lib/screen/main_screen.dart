import 'package:flutter/material.dart';

import '../state/favorite_store.dart';
import '../theme/theme.dart';
import 'favorite_screen.dart';
import 'search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final FavoriteStore _favoriteStore = FavoriteStore();

  late final List<Widget> _screens = [
    FavoriteScreen(favoriteStore: _favoriteStore),
    SearchScreen(favoriteStore: _favoriteStore),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _favoriteStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surfaceRaised,
          border: Border(
            top: BorderSide(
              color: context.colors.borderSubtle,
              width: context.dimens.borderHairline,
            ),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: context.colors.surfaceRaised,
          elevation: 0,
          selectedItemColor: context.colors.navActive,
          unselectedItemColor: context.colors.navInactive,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(
            fontWeight: AppTypography.regular,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: AppTypography.regular,
          ),
          iconSize: context.dimens.iconMd,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.star_border),
              activeIcon: Icon(Icons.star),
              label: '관심',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: '검색'),
          ],
        ),
      ),
    );
  }
}
