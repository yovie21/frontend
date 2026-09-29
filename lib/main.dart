import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/http_client.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/kasir_provider.dart';
import 'providers/gudang_provider.dart';
import 'ui/auth/login_page.dart';
import 'ui/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HttpClient.init();
  runApp(const WarungkuApp());
}

class WarungkuApp extends StatelessWidget {
  const WarungkuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => KasirProvider()),
        ChangeNotifierProvider(create: (_) => GudangProvider()),
      ],
      child: MaterialApp(
        title: 'Warungku',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final auth = context.read<AuthProvider>();
    await auth.checkAuth();
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF2D3A2B)),
        ),
      );
    }

    final auth = context.watch<AuthProvider>();
    return auth.isAuthenticated
        ? MainShell(user: auth.user)
        : const LoginPage();
  }
}
