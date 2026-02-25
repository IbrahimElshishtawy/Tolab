import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:admin_web/core/theme/app_theme.dart';
import 'package:admin_web/core/network/api_client.dart';
import 'package:admin_web/core/network/secure_storage.dart';
import 'package:admin_web/core/ui/layout.dart';
import 'package:admin_web/features/students/presentation/screens/students_list_screen.dart';
import 'package:admin_web/features/students/presentation/screens/student_detail_screen.dart';
import 'package:admin_web/features/academic/presentation/screens/academic_structure_screen.dart';
import 'package:admin_web/features/staff/presentation/screens/staff_assignment_screen.dart';
import 'package:admin_web/features/schedule/presentation/screens/schedule_management_screen.dart';
import 'package:admin_web/features/settings/presentation/screens/system_settings_screen.dart';

// --- Auth State & Provider ---

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;
  final String? role;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
    this.role,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
    String? role,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
      role: role ?? this.role,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  static const String adminEmail = 'admin@tolab.com';
  static const String adminPassword = 'admin123';

  AuthNotifier(this._ref) : super(AuthState()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await _ref.read(secureStoreProvider).getToken();
    if (token != null) {
      state = state.copyWith(isAuthenticated: true);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (email == adminEmail && password == adminPassword) {
      await _ref.read(secureStoreProvider).saveToken('mock_admin_token');
      state = state.copyWith(isLoading: false, isAuthenticated: true, role: 'it');
    } else {
      state = state.copyWith(isLoading: false, error: 'Login failed: Incorrect email or password');
    }
  }

  Future<void> logout() async {
    await _ref.read(secureStoreProvider).deleteToken();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(ref));

// --- Router ---

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (!authState.isAuthenticated && state.uri.path != '/login') {
        return '/login';
      }
      if (authState.isAuthenticated && state.uri.path == '/login') {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Center(child: Text('Welcome to Tolab Admin Dashboard')),
          ),
          GoRoute(
            path: '/students',
            builder: (context, state) => const StudentsListScreen(),
          ),
          GoRoute(
            path: '/students/:id',
            builder: (context, state) {
              final id = state.pathParameters['id'];
              return StudentDetailScreen(studentId: id == 'new' ? null : int.parse(id!));
            },
          ),
          GoRoute(
            path: '/academic',
            builder: (context, state) => const AcademicStructureScreen(),
          ),
          GoRoute(
            path: '/staff',
            builder: (context, state) => const StaffAssignmentScreen(),
          ),
          GoRoute(
            path: '/schedule',
            builder: (context, state) => const ScheduleManagementScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SystemSettingsScreen(),
          ),
        ],
      ),
    ],
  );
});

// --- UI Components ---

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController(text: AuthNotifier.adminEmail);
  final _passwordController = TextEditingController(text: AuthNotifier.adminPassword);
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tolab Admin',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email / Username',
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                maxLength: 25,
              ),
              const SizedBox(height: 24),
              if (authState.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    authState.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: authState.isLoading
                      ? null
                      : () {
                          ref.read(authProvider.notifier).login(
                                _emailController.text,
                                _passwordController.text,
                              );
                        },
                  child: authState.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Main App ---

void main() {
  runApp(const ProviderScope(child: AdminApp()));
}

class AdminApp extends ConsumerWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Tolab Admin Panel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
