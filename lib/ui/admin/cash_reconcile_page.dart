import 'package:flutter/material.dart';
import '../../../core/utils.dart';
import '../../../data/services/services.dart';

class CashReconcilePage extends StatefulWidget {
  const CashReconcilePage({super.key});

  @override
  State<CashReconcilePage> createState() => _CashReconcilePageState();
}

class _CashReconcilePageState extends State<CashReconcilePage> {
  final counted = TextEditingController();
  final note = TextEditingController();
  Map<String, dynamic>? data;
  bool loading = true;
  bool saving = false;

  String get today => DateTime.now().toIso8601String().substring(0, 10);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    counted.dispose();
    note.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final r = await CashService.getReconcile(today);
      if (!mounted) return;
      setState(() {
        data = r;
        loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _save() async {
    final n = double.tryParse(counted.text.replaceAll('.', '').replaceAll(',', '.'));
    if (n == null) return;
    setState(() => saving = true);
    try {
      await CashService.saveReconcile(today, n, note: note.text.trim());
      counted.clear();
      note.clear();
      await _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final expected = (data?['expected'] as num?)?.toDouble() ?? 0;
    final rows = (data?['rows'] as List?) ?? [];
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Rekonsiliasi Kas', style: TextStyle(fontWeight: FontWeight.w800))),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kas tunai sistem · $today'),
                        const SizedBox(height: 8),
                        Text('Rp ${AppUtils.formatCurrency(expected)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 12),
                        TextField(controller: counted, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Uang fisik dihitung')),
                        TextField(controller: note, decoration: const InputDecoration(labelText: 'Catatan (opsional)')),
                        const SizedBox(height: 12),
                        FilledButton(onPressed: saving ? null : _save, child: Text(saving ? 'Menyimpan...' : 'Simpan selisih')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...rows.map((raw) {
                  final r = raw as Map<String, dynamic>;
                  final diff = (r['diff'] as num?)?.toDouble() ?? 0;
                  return ListTile(
                    title: Text('Hitung Rp ${AppUtils.formatCurrency((r['counted'] as num?)?.toDouble() ?? 0)}'),
                    subtitle: Text('${r['user']?['username'] ?? '-'} · ${r['note'] ?? ''}'),
                    trailing: Text(diff == 0 ? 'Pas' : (diff > 0 ? '+${diff.round()}' : '${diff.round()}'),
                        style: TextStyle(fontWeight: FontWeight.w800, color: diff == 0 ? Colors.green : Colors.red)),
                  );
                }),
              ],
            ),
    );
  }
}
