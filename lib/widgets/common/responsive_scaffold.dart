import 'package:flutter/material.dart';
import '../../core/responsive/responsive_helper.dart';
import './custom_sidebar.dart';
import './custom_bottom_nav.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/analytics/analytics_screen.dart';
import '../../screens/settings/settings_screen.dart';

class ResponsiveScaffold extends StatefulWidget {
  const ResponsiveScaffold({super.key});

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            CustomSidebar(
              currentIndex: _currentIndex,
              onTap: _onTabChanged,
            ),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: _currentIndex,
          onTap: _onTabChanged,
        ),
      );
    }
  }
}
