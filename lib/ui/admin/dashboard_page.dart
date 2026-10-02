import 'package:flutter/material.dart';
import '../../../core/utils.dart';
import '../../../data/services/services.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _loading = true;
  double omzet = 0;
  int txCount = 0;
  int habis = 0;
  int menipis = 0;
  int hutang = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await DashboardService.getSummary();
      if (!mounted) return;
      setState(() {
        omzet = (data['omzet'] as num?)?.toDouble() ?? 0;
        txCount = (data['txCount'] as num?)?.toInt() ?? 0;
        habis = (data['habis'] as num?)?.toInt() ?? 0;
        menipis = (data['menipis'] as num?)?.toInt() ?? 0;
        hutang = (data['hutang'] as num?)?.toInt() ?? 0;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Omzet hari ini
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F3826), Color(0xFF1B5E3C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Omzet Hari Ini', style: TextStyle(color: Color(0xFFA7F3D0), fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text('Rp ${AppUtils.formatCurrency(omzet.toInt())}',
                            style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -1)),
                        const SizedBox(height: 6),
                        Text('$txCount transaksi', style: const TextStyle(color: Color(0xFFA7F3D0), fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Notifikasi stok habis
                  if (habis > 0 || menipis > 0)
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: habis > 0 ? const Color(0xFFFEF2F2) : const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: habis > 0 ? const Color(0xFFFECACA) : const Color(0xFFFDE68A)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: habis > 0 ? const Color(0xFFDC2626) : const Color(0xFFD97706), size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      habis > 0 ? '$habis produk habis!' : '$menipis produk menipis',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: habis > 0 ? const Color(0xFFDC2626) : const Color(0xFFD97706),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text('Segera buat PO untuk kulakan', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),

                  // Stats grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.15,
                    children: [
                      _statCard('Transaksi Hari Ini', '$txCount', Icons.receipt_long_rounded, const Color(0xFF2563EB)),
                      _statCard('Stok Habis', '$habis', Icons.inventory_2_outlined, const Color(0xFFDC2626)),
                      _statCard('Stok Menipis', '$menipis', Icons.trending_down_rounded, const Color(0xFFD97706)),
                      _statCard('Hutang Supplier', '$hutang PO', Icons.account_balance_wallet_rounded, const Color(0xFF9333EA)),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}