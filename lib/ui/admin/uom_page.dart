import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../data/models/models.dart';
import '../../../providers/admin_provider.dart';
import '../widgets/modern_widgets.dart';

class UomPage extends StatefulWidget {
  const UomPage({super.key});

  @override
  State<UomPage> createState() => _UomPageState();
}

class _UomPageState extends State<UomPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchUoms();
    });
  }

  void _showForm({Uom? uom}) {
    final nameCtrl = TextEditingController(text: uom?.name ?? '');
    final symbolCtrl = TextEditingController(text: uom?.symbol ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(uom == null ? 'Tambah Satuan' : 'Edit Satuan', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Satuan *', prefixIcon: Icon(Icons.straighten))),
            const SizedBox(height: 12),
            TextField(controller: symbolCtrl, decoration: const InputDecoration(labelText: 'Simbol (cth: PCS)', prefixIcon: Icon(Icons.short_text))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ModernButton(
            text: 'Simpan',
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              final admin = context.read<AdminProvider>();
              bool ok = uom == null
                  ? await admin.createUom(nameCtrl.text.trim(), symbol: symbolCtrl.text.trim().isEmpty ? null : symbolCtrl.text.trim())
                  : await admin.updateUom(uom.id, nameCtrl.text.trim(), symbol: symbolCtrl.text.trim().isEmpty ? null : symbolCtrl.text.trim());
              if (mounted) {
                Navigator.pop(ctx);
                if (!ok) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: ${admin.errorMessage}')));
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Satuan Ukuran (UOM)'),
        actions: [IconButton(icon: const Icon(Icons.add_circle, size: 32), onPressed: () => _showForm())],
      ),
      body: RefreshIndicator(
        onRefresh: () => admin.fetchUoms(),
        child: admin.uoms.isEmpty
            ? const Center(child: Text('Belum ada satuan'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: admin.uoms.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) {
                  final u = admin.uoms[i];
                  return ModernCard(
                    padding: const EdgeInsets.all(12),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(color: AppColors.primary.withAlpha(20), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.straighten, color: AppColors.primary),
                      ),
                      title: Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(u.symbol ?? '-', style: const TextStyle(color: AppColors.textSecondary)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit, size: 20, color: AppColors.primary), onPressed: () => _showForm(uom: u)),
                          IconButton(icon: const Icon(Icons.delete, size: 20, color: AppColors.statusError), onPressed: () => admin.deleteUom(u.id)),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
