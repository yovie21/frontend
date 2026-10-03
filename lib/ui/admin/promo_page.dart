import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/utils.dart';
import '../../../data/services/services.dart';

class PromoPage extends StatefulWidget {
  const PromoPage({super.key});

  @override
  State<PromoPage> createState() => _PromoPageState();
}

class _PromoPageState extends State<PromoPage> {
  List<dynamic> promos = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await PromoService.getPromos();
      if (!mounted) return;
      setState(() {
        promos = data;
        loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  void _showForm({Map<String, dynamic>? promo}) {
    final nameCtrl = TextEditingController(text: promo?['name'] ?? '');
    final percentCtrl = TextEditingController(text: promo?['percent']?.toString() ?? '');
    final amountCtrl = TextEditingController(text: promo?['amount']?.toString() ?? '');
    String startDate = promo?['startDate'] ?? DateTime.now().toIso8601String().split('T')[0];
    String endDate = promo?['endDate'] ?? DateTime.now().add(const Duration(days: 30)).toIso8601String().split('T')[0];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(promo == null ? 'Buat Promo Baru' : 'Edit Promo', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
            const SizedBox(height: 16),
            TextField(controller: nameCtrl, decoration: InputDecoration(hintText: 'Nama Promo', labelText: 'Nama Promo', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: percentCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(hintText: '0', labelText: 'Diskon %', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(hintText: '0', labelText: 'Nominal Rp', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(context: ctx, initialDate: DateTime.parse(startDate), firstDate: DateTime(2020), lastDate: DateTime(2099));
                      if (picked != null) startDate = picked.toIso8601String().split('T')[0];
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
                      child: Text(startDate, style: const TextStyle(fontSize: 13)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(context: ctx, initialDate: DateTime.parse(endDate), firstDate: DateTime(2020), lastDate: DateTime(2099));
                      if (picked != null) endDate = picked.toIso8601String().split('T')[0];
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
                      child: Text(endDate, style: const TextStyle(fontSize: 13)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(onPressed: Navigator.of(ctx).pop, child: const Text('Batal')),
                ),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      try {
                        if (promo == null) {
                          await PromoService.createPromo(
                            name: nameCtrl.text,
                            percent: percentCtrl.text.isEmpty ? null : double.parse(percentCtrl.text),
                            amount: amountCtrl.text.isEmpty ? null : double.parse(amountCtrl.text),
                            startDate: startDate,
                            endDate: endDate,
                          );
                        } else {
                          await PromoService.updatePromo(
                            promo['id'],
                            name: nameCtrl.text,
                            percent: percentCtrl.text.isEmpty ? null : double.parse(percentCtrl.text),
                            amount: amountCtrl.text.isEmpty ? null : double.parse(amountCtrl.text),
                            startDate: startDate,
                            endDate: endDate,
                          );
                        }
                        if (mounted) {
                          Navigator.pop(ctx);
                          _load();
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                    child: const Text('Simpan'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manajemen Promo', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _showForm()),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : promos.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.local_offer_outlined, size: 48, color: AppColors.textMuted), const SizedBox(height: 12), const Text('Belum ada promo', style: TextStyle(color: AppColors.textSecondary))]))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: promos.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final p = promos[i];
                    final isActive = p['status'] == 'active';
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(p['name'], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15))),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isActive ? AppColors.successBg : AppColors.warnBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(p['status'].toString().toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isActive ? AppColors.successFg : AppColors.warnFg)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (p['percent'] != null) Text('${p['percent']}% ', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
                              if (p['amount'] != null) Text('Rp ${AppUtils.formatCurrency(p['amount'] ?? 0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('${p['startDate']} s/d ${p['endDate']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: OutlinedButton.icon(onPressed: () => _showForm(promo: p), icon: const Icon(Icons.edit, size: 16), label: const Text('Edit', style: TextStyle(fontSize: 12)))),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  if (await showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Hapus Promo?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus'))])) == true) {
                                    try {
                                      await PromoService.deletePromo(p['id']);
                                      _load();
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                    }
                                  }
                                },
                                icon: const Icon(Icons.delete, size: 16),
                                label: const Text('Hapus', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}