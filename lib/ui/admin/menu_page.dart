import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../auth/login_page.dart';
import '../kasir/receipt_page.dart';
import 'uom_page.dart';
import 'user_page.dart';
import 'supplier_page.dart';
import 'po_page.dart';
import 'report_page.dart';
import 'debt_page.dart';
import 'barcode_label_page.dart';
import '../gudang/stock_mutation_page.dart';
import '../gudang/supplier_returns_page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = (auth.user?.role ?? 'kasir').trim().toLowerCase();
    final username = auth.user?.username ?? 'User';
    final initial = username.isNotEmpty ? username[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Menu & Pengaturan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // Executive User Profile Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x060F172A),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F3826), Color(0xFF1B5E3C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x200F3826),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Text(
                          role.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF065F46),
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section 1: Operasional
          if (role == 'admin') ...[
            _sectionHeader('OPERASIONAL & STOK'),
            _groupedCard([
              _MenuItem(
                icon: Icons.square_foot_rounded,
                iconBg: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF2563EB),
                title: 'Satuan (UOM)',
                subtitle: 'Konversi dan satuan hitung produk',
                page: const UomPage(),
              ),
              _MenuItem(
                icon: Icons.storefront_rounded,
                iconBg: const Color(0xFFF0FDF4),
                iconColor: const Color(0xFF16A34A),
                title: 'Supplier',
                subtitle: 'Daftar mitra distributor & kontak',
                page: const SupplierPage(),
              ),
              _MenuItem(
                icon: Icons.local_shipping_rounded,
                iconBg: const Color(0xFFFAF5FF),
                iconColor: const Color(0xFF9333EA),
                title: 'Purchase Order',
                subtitle: 'Pemesanan barang masuk ke supplier',
                page: const PoPage(),
              ),
              _MenuItem(
                icon: Icons.swap_vert_rounded,
                iconBg: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFD97706),
                title: 'Kartu & Mutasi Stok',
                subtitle: 'Riwayat lengkap barang masuk/keluar/opname',
                page: const StockMutationPage(),
              ),
              _MenuItem(
                icon: Icons.assignment_return_rounded,
                iconBg: const Color(0xFFFEF2F2),
                iconColor: const Color(0xFFDC2626),
                title: 'Retur Supplier',
                subtitle: 'Pengembalian barang rusak / kadaluarsa',
                page: const SupplierReturnsPage(),
              ),
              _MenuItem(
                icon: Icons.qr_code_2_rounded,
                iconBg: const Color(0xFFECFDF5),
                iconColor: const Color(0xFF059669),
                title: 'Cetak Label Barcode & Rak',
                subtitle: 'Generate & cetak label harga/barcode',
                page: const BarcodeLabelPage(),
              ),
            ], context),
            const SizedBox(height: 18),
          ],

          if (role == 'gudang') ...[
            _sectionHeader('OPERASIONAL GUDANG'),
            _groupedCard([
              _MenuItem(
                icon: Icons.local_shipping_rounded,
                iconBg: const Color(0xFFFAF5FF),
                iconColor: const Color(0xFF9333EA),
                title: 'Purchase Order',
                subtitle: 'Kelola pemesanan & terima barang',
                page: const PoPage(),
              ),
              _MenuItem(
                icon: Icons.storefront_rounded,
                iconBg: const Color(0xFFF0FDF4),
                iconColor: const Color(0xFF16A34A),
                title: 'Supplier',
                subtitle: 'Data mitra supplier & kontak',
                page: const SupplierPage(),
              ),
              _MenuItem(
                icon: Icons.square_foot_rounded,
                iconBg: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF2563EB),
                title: 'Satuan (UOM)',
                subtitle: 'Daftar satuan kemasan barang',
                page: const UomPage(),
              ),
              _MenuItem(
                icon: Icons.swap_vert_rounded,
                iconBg: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFD97706),
                title: 'Kartu & Mutasi Stok',
                subtitle: 'Riwayat lengkap barang masuk/keluar/opname',
                page: const StockMutationPage(),
              ),
              _MenuItem(
                icon: Icons.assignment_return_rounded,
                iconBg: const Color(0xFFFEF2F2),
                iconColor: const Color(0xFFDC2626),
                title: 'Retur Supplier',
                subtitle: 'Pengembalian barang rusak / kadaluarsa',
                page: const SupplierReturnsPage(),
              ),
              _MenuItem(
                icon: Icons.qr_code_2_rounded,
                iconBg: const Color(0xFFECFDF5),
                iconColor: const Color(0xFF059669),
                title: 'Cetak Label Barcode & Rak',
                subtitle: 'Generate & cetak label harga/barcode',
                page: const BarcodeLabelPage(),
              ),
            ], context),
            const SizedBox(height: 18),
          ],

          if (role == 'kasir') ...[
            _sectionHeader('PENJUALAN & TRANSAKSI'),
            _groupedCard([
              _MenuItem(
                icon: Icons.receipt_long_rounded,
                iconBg: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF2563EB),
                title: 'Riwayat Transaksi',
                subtitle: 'Cek daftar struk & cetak ulang',
                page: const ReceiptPage(),
              ),
              _MenuItem(
                icon: Icons.square_foot_rounded,
                iconBg: const Color(0xFFFAF5FF),
                iconColor: const Color(0xFF9333EA),
                title: 'Informasi Satuan (UOM)',
                subtitle: 'Daftar satuan konversi produk',
                page: const UomPage(),
              ),
            ], context),
            const SizedBox(height: 18),
          ],

          // Section 2: Keuangan & Laporan
          _sectionHeader('KEUANGAN & LAPORAN'),
          _groupedCard([
            if (role != 'gudang')
              _MenuItem(
                icon: Icons.insights_rounded,
                iconBg: const Color(0xFFECFDF5),
                iconColor: const Color(0xFF059669),
                title: 'Laporan Penjualan & Laba',
                subtitle: 'Ringkasan omset harian, bulanan & profit',
                page: const ReportPage(),
              ),
            if (role == 'admin' || role == 'gudang')
              _MenuItem(
                icon: Icons.account_balance_wallet_rounded,
                iconBg: const Color(0xFFFFFBEB),
                iconColor: const Color(0xFFD97706),
                title: 'Hutang Supplier',
                subtitle: 'Monitoring jatuh tempo tagihan supplier',
                page: const DebtPage(),
              ),
          ], context),
          const SizedBox(height: 18),

          // Section 3: Akun & Keamanan
          if (role == 'admin') ...[
            _sectionHeader('AKUN & PENGATURAN'),
            _groupedCard([
              _MenuItem(
                icon: Icons.manage_accounts_rounded,
                iconBg: const Color(0xFFF1F5F9),
                iconColor: const Color(0xFF475569),
                title: 'Pengguna & Akses',
                subtitle: 'Kelola kasir, gudang, dan password',
                page: const UserPage(),
              ),
            ], context),
            const SizedBox(height: 22),
          ],

          // Logout Action Tile
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  title: const Text('Keluar dari Akun', style: TextStyle(fontWeight: FontWeight.w800)),
                  content: const Text(
                    'Anda akan diarahkan kembali ke layar masuk.',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Keluar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Keluar / Ganti Akun',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.chevron_right_rounded, color: Color(0xFFF87171), size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Footnote
          const Center(
            child: Text(
              'Warungku POS · Versi 1.0.0',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF94A3B8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF94A3B8),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _groupedCard(List<_MenuItem> items, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x040F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            InkWell(
              borderRadius: BorderRadius.vertical(
                top: i == 0 ? const Radius.circular(18) : Radius.zero,
                bottom: i == items.length - 1 ? const Radius.circular(18) : Radius.zero,
              ),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => items[i].page)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: items[i].iconBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(items[i].icon, color: items[i].iconColor, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            items[i].title,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            items[i].subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1), size: 20),
                  ],
                ),
              ),
            ),
            if (i < items.length - 1)
              const Padding(
                padding: EdgeInsets.only(left: 70, right: 16),
                child: Divider(height: 1, color: Color(0xFFF1F5F9)),
              ),
          ],
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget page;

  _MenuItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.page,
  });
}
