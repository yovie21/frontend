import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/models.dart';
import '../../providers/auth_provider.dart';
import 'admin/product_page.dart';
import 'admin/category_page.dart';
import 'kasir/sales_page.dart';
import 'kasir/receipt_page.dart';
import 'gudang/stock_opname_page.dart';
import 'gudang/stock_report_page.dart';
import 'admin/menu_page.dart';
import 'auth/login_page.dart';

class MainShell extends StatefulWidget {
  final User? user;
  const MainShell({this.user, super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    if (_user == null) {
      _loadUser();
    }
  }

  Future<void> _loadUser() async {
    final auth = context.read<AuthProvider>();
    await auth.checkAuth();
    if (mounted) {
      setState(() => _user = auth.user);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = _user?.role ?? 'kasir';
    final pages = _buildPages(role);

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _index < pages.length ? _index : 0,
          children: pages,
        ),
      ),
      bottomNavigationBar: _buildNav(role),
    );
  }

  List<Widget> _buildPages(String role) {
    switch (role) {
      case 'admin':
        return [
          const ProductPage(),
          const CategoryPage(),
          const MenuPage(),
        ];
      case 'gudang':
        return [
          const StockOpnamePage(),
          const StockReportPage(),
          const MenuPage(),
        ];
      default:
        return [
          const SalesPage(),
          const ReceiptPage(),
          const MenuPage(),
        ];
    }
  }

  Widget _buildNav(String role) {
    List<BottomNavigationBarItem> items;
    switch (role) {
      case 'admin':
        items = const [
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'Produk'),
          BottomNavigationBarItem(icon: Icon(Icons.category_outlined), activeIcon: Icon(Icons.category), label: 'Kategori'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_outlined), activeIcon: Icon(Icons.menu), label: 'Menu'),
        ];
        break;
      case 'gudang':
        items = const [
          BottomNavigationBarItem(icon: Icon(Icons.warehouse_outlined), activeIcon: Icon(Icons.warehouse), label: 'Stok Opname'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), activeIcon: Icon(Icons.analytics), label: 'Laporan'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_outlined), activeIcon: Icon(Icons.menu), label: 'Menu'),
        ];
        break;
      default:
        items = const [
          BottomNavigationBarItem(icon: Icon(Icons.point_of_sale_outlined), activeIcon: Icon(Icons.point_of_sale), label: 'POS'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_outlined), activeIcon: Icon(Icons.menu), label: 'Menu'),
        ];
    }

    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        color: Colors.white,
      ),
      child: BottomNavigationBar(
        currentIndex: _index < items.length ? _index : 0,
        onTap: (i) => setState(() => _index = i),
        items: items,
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE7F0EA),
                child: Icon(Icons.person, color: Color(0xFF2D3A2B)),
              ),
              title: Text(auth.user?.username ?? 'Pengguna', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Role: ${auth.user?.role.toUpperCase() ?? '-'}'),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFD46B3D)),
              title: const Text('Keluar / Logout', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFD46B3D))),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Konfirmasi Logout'),
                    content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD46B3D)),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Keluar'),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await auth.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
