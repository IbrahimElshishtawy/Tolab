import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../../../../redux/app_state.dart';
import '../../../../redux/state/admin_state.dart';
import '../../redux/admin_actions.dart';
import '../../../../core/ui/widgets/university_widgets.dart';
import '../../../../core/ui/widgets/app_scaffold.dart';
import '../../../../core/ui/tokens/spacing_tokens.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final store = StoreProvider.of<AppState>(context);
      if (!store.state.adminState.isLoading && store.state.adminState.hasMoreUsers) {
        store.dispatch(FetchUsersAction(page: store.state.adminState.userPage));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AdminState>(
      onInit: (store) => store.dispatch(FetchUsersAction(page: 1)),
      converter: (store) => store.state.adminState,
      builder: (context, state) {
        return AppScaffold(
          title: 'User Management',
          isLoading: state.isLoading && state.users.isEmpty,
          error: state.error,
          onRetry: () => StoreProvider.of<AppState>(context).dispatch(FetchUsersAction(page: 1)),
          actions: [
            IconButton(
              icon: const Icon(Icons.file_upload),
              onPressed: () => _showImportBottomSheet(context),
              tooltip: 'Import Bulk',
            ),
          ],
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppSpacing.l),
            itemCount: state.users.length + (state.hasMoreUsers ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == state.users.length) {
                return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
              }
              final user = state.users[index];
              return AppCard(
                margin: const EdgeInsets.only(bottom: AppSpacing.m),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(user['name'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(user['email'] ?? ''),
                  trailing: Switch(value: true, onChanged: (v) {}),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.person_add),
          ),
        );
      },
    );
  }

  void _showImportBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bulk Import Users', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.xxl),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.xxxl),
              onTap: () {},
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              child: Column(
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 48, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: AppSpacing.l),
                  const Text('Select CSV or Excel file'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(text: 'Process File', onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}
