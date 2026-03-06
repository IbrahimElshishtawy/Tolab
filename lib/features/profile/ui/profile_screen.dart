import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:go_router/go_router.dart';
import '../../../redux/app_state.dart';
import '../../auth/redux/auth_actions.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: _ViewModel.fromStore,
      builder: (context, vm) {
        return Scaffold(
          appBar: AppBar(title: const Text('Profile')),
          body: ListView(
            children: [
              _buildHeader(vm),
              const Divider(),
              _buildSectionTitle('Settings'),
              SwitchListTile(
                title: const Text('Notifications'),
                subtitle: const Text('Receive alerts about tasks and materials'),
                value: _notificationsEnabled,
                onChanged: (val) => setState(() => _notificationsEnabled = val),
                secondary: const Icon(Icons.notifications),
              ),
              ListTile(
                title: const Text('Language'),
                subtitle: Text(_selectedLanguage),
                leading: const Icon(Icons.language),
                onTap: _showLanguagePicker,
              ),
              const Divider(),
              _buildSectionTitle('Account'),
              ListTile(
                title: const Text('Help & Support'),
                leading: const Icon(Icons.help),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Privacy Policy'),
                leading: const Icon(Icons.privacy_tip),
                onTap: () {},
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    StoreProvider.of<AppState>(context).dispatch(LogoutAction());
                    context.go('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Logout'),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(_ViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          const SizedBox(height: 16),
          Text(vm.email ?? 'User Name', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(vm.role?.toUpperCase() ?? 'STUDENT', style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue[800])),
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', 'Arabic', 'French'].map((lang) {
            return ListTile(
              title: Text(lang),
              trailing: lang == _selectedLanguage ? const Icon(Icons.check, color: Colors.blue) : null,
              onTap: () {
                setState(() => _selectedLanguage = lang);
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }
}

class _ViewModel {
  final String? email;
  final String? role;

  _ViewModel({this.email, this.role});

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      email: store.state.authState.email,
      role: store.state.authState.role,
    );
  }
}
