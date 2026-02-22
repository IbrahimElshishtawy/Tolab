import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import '../../../../redux/app_state.dart';
import '../../../auth/redux/auth_actions.dart';
import '../../../../core/localization/localization_manager.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('more_nav'.tr())),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          _buildMoreItem(context, 'profile'.tr(), Icons.person_outline, '/profile'),
          _buildMoreItem(context, 'results'.tr(), Icons.grade_outlined, '/results'),
          _buildMoreItem(context, 'language'.tr(), Icons.language_outlined, '/language'),
          _buildMoreItem(context, 'notif_settings'.tr(), Icons.notifications_active_outlined, '/notification-settings'),
          const Divider(height: 40),
          _buildMoreItem(context, 'logout'.tr(), Icons.logout, null, isLogout: true),
        ],
      ),
    );
  }

  Widget _buildMoreItem(BuildContext context, String label, IconData icon, String? route, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : Colors.blue),
      title: Text(label, style: TextStyle(color: isLogout ? Colors.red : Colors.black87, fontWeight: FontWeight.w500)),
      trailing: isLogout ? null : const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        if (isLogout) {
          StoreProvider.of<AppState>(context).dispatch(LogoutAction());
          context.go('/login');
        } else if (route != null) {
          context.push(route);
        }
      },
    );
  }
}
