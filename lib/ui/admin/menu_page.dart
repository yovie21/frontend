import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../auth/login_page.dart';
import 'uom_page.dart';
import 'user_page.dart';
import 'supplier_page.dart';
import 'po_page.dart';
import 'report_page.dart';
import 'debt_page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = (auth.user?.role ?? 'kasir').trim().toLowerCase();
    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '${auth.user?.username ?? ''} · ${role.toUpperCase()}',
              style: const TextStyle(fontSize: 13, color: Color(0xFF5A5A5A)),
            ),
          ),
          if (role == 'admin') ...[
            _tile(context, Icons.straighten, 'Satuan (UOM)', const UomPage()),
            _tile(context, Icons.business, 'Supplier', const SupplierPage()),
            _tile(context, Icons.local_shipping_outlined, 'Purchase Order', const PoPage()),
            _tile(context, Icons.bar_chart, 'Laporan penjualan & laba', const ReportPage()),
            _tile(context, Icons.account_balance_wallet_outlined, 'Hutang supplier', const DebtPage()),
            _tile(context, Icons.people_outline, 'Pengguna', const UserPage()),
          ],
          if (role == 'kasir') ...[
            _tile(context, Icons.bar_chart, 'Laporan penjualan & laba', const ReportPage()),
          ],
          if (role == 'gudang') ...[
            _tile(context, Icons.local_shipping_outlined, 'Purchase Order', const PoPage()),
            _tile(context, Icons.account_balance_wallet_outlined, 'Hutang supplier', const DebtPage()),
          ],
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout, color: Color(0xFFD46B3D)),
            title: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFD46B3D))),
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Keluar'),
                  content: const Text('Yakin keluar dari aplikasi?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Keluar')),
                  ],
                ),
              );
              if (ok == true && context.mounted) {
                await auth.logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (r) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String label, Widget page) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFF2D3A2B)),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF9A9A9A)),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page)),
    );
  }
}
