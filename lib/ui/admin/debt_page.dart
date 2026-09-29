import 'package:flutter/material.dart';
import '../../../core/utils.dart';
import '../../../core/http_client.dart';

class DebtPage extends StatefulWidget {
  const DebtPage({super.key});

  @override
  State<DebtPage> createState() => _DebtPageState();
}

class _DebtPageState extends State<DebtPage> {
  List<dynamic> _rows = [];
  double _total = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await HttpClient.get('/reports/debt');
      final map = res as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _rows = map['items'] as List? ?? [];
          _total = (map['totalHutang'] as num?)?.toDouble() ?? 0;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pay(int id, double sisa) async {
    final ctrl = TextEditingController(text: AppUtils.formatCurrency(sisa.toInt()));
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bayar hutang'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Jumlah', prefixText: 'Rp '),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Simpan')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await HttpClient.patch('/purchase_orders/$id', {'payAmount': AppUtils.parseCurrency(ctrl.text)});
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hutang supplier')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text('Total hutang  Rp ${AppUtils.formatCurrency(_total)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 16),
                      if (_rows.isEmpty) const Text('Tidak ada hutang'),
                      for (final r in _rows)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('PO #${r['id']}  ${r['supplierName'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('Sisa Rp ${AppUtils.formatCurrency(r['unpaid'])}'),
                          trailing: TextButton(
                            onPressed: () => _pay(r['id'] as int, (r['unpaid'] as num).toDouble()),
                            child: const Text('Bayar'),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}
