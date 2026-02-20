import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import '../../../redux/app_state.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  const AppScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, String?>(
      converter: (store) => store.state.authState.role,
      builder: (context, role) {
        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _calculateSelectedIndex(context, role),
            onTap: (index) => _onItemTapped(index, context, role),
            items: _buildNavItems(role),
          ),
        );
      },
    );
  }

  int _calculateSelectedIndex(BuildContext context, String? role) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/subjects')) return 1;
    if (location.startsWith('/calendar')) return 2;
    if (location.startsWith('/community')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context, String? role) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/subjects');
        break;
      case 2:
        context.go('/calendar');
        break;
      case 3:
        context.go('/community');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  List<BottomNavigationBarItem> _buildNavItems(String? role) {
    return const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Subjects'),
      BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Schedule'),
      BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Community'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ];
  }
}
