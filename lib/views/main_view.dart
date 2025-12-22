import 'package:flutter/material.dart';
import 'package:flutter_gap/flutter_gap.dart';

import '../core/core.dart';
import 'assets_search_view.dart';
import 'favorites_view.dart';
import 'home_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeView(),
    AssetsSearchView(),
    FavoritesView(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navItems = [
      _NavItem(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        label: 'home'.translate(),
      ),
      _NavItem(
        icon: Icons.search_outlined,
        selectedIcon: Icons.search,
        label: 'search'.translate(),
      ),
      _NavItem(
        icon: Icons.favorite_outline,
        selectedIcon: Icons.favorite,
        label: 'favorites'.translate(),
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.surfaceVariantDark, width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowDark.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                navItems.length,
                (index) => Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      child: _FloatingNavItem(
                        item: navItems[index],
                        isSelected: _currentIndex == index,
                        theme: theme,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class _FloatingNavItem extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final ThemeData theme;

  const _FloatingNavItem({
    required this.item,
    required this.isSelected,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? item.selectedIcon : item.icon,
            color: isSelected ? AppColors.primaryDark : AppColors.textTertiary,
            size: 24,
          ),
          const Gap(4),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color:
                  isSelected ? AppColors.primaryDark : AppColors.textTertiary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
