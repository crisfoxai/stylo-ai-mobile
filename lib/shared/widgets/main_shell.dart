import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'bottom_nav_bar.dart';

class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  static const List<String> _tabPaths = [
    '/home',
    '/wardrobe',
    '/scan',
    '/outfits',
    '/profile',
  ];

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (var i = 0; i < _tabPaths.length; i++) {
      if (location.startsWith(_tabPaths[i])) return i;
    }
    return 0;
  }

  void _onTabSelected(BuildContext context, int index) {
    context.go(_tabPaths[index]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = _selectedIndex(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: StyloBottomNavBar(
        selectedIndex: selectedIndex,
        onTabSelected: (index) => _onTabSelected(context, index),
      ),
    );
  }
}
