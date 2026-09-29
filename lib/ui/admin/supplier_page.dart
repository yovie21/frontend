import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../data/models/models.dart';
import '../../../providers/admin_provider.dart';
import '../widgets/modern_widgets.dart';

class SupplierPage extends StatefulWidget {
  const SupplierPage({super.key});

  @override
  State<SupplierPage> createState() => _SupplierPageState();
}

class _SupplierPageState extends State<SupplierPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchSuppliers();
    });
  }

  void _showForm({Supplier? supplier}) {
    final nameCtrl = TextEditingController(text: supplier?.name ?? '');
    final contactCtrl = TextEditingController(text: supplier?.contact ?? '');
    final phoneCtrl = TextEditingController(text: supplier?.phone ?? '');
    final emailCtrl = TextEditingController(text: supplier?.email ?? '');
    final addressCtrl = TextEditingController(text: supplier?.address ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 24, left: 24, right: 24, top: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(supplier == null ? 'Tambah Supplier' : 'Edit Supplier', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 24),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Supplier *', prefixIcon: Icon(Icons.business))),
              const SizedBox(height: 16),
              TextField(controller: contactCtrl, decoration: const InputDecoration(labelText: 'Kontak Person', prefixIcon: Icon(Icons.person))),
              const SizedBox(height: 16),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Nomor Telepon', prefixIcon: Icon(Icons.phone))),
              const SizedBox(height: 16),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email))),
              const SizedBox(height: 16),
              TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Alamat', prefixIcon: Icon(Icons.location_on))),
              const SizedBox(height: 24),
              ModernButton(
                text: 'Simpan Supplier',
                onPressed: () async {
                  if (nameCtrl.text.trim().isEmpty) return;
                  final data = {
                    'name': nameCtrl.text.trim(),
                    'contact': contactCtrl.text.trim(),
                    'phone': phoneCtrl.text.trim(),
                    'email': emailCtrl.text.trim(),
                    'address': addressCtrl.text.trim(),
                  };
                  final admin = context.read<AdminProvider>();
                  bool success = supplier == null
                      ? await admin.createSupplier(data)
                      : await admin.updateSupplier(supplier.id, data);
                  if (mounted && success) Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Supplier'),
        actions: [IconButton(icon: const Icon(Icons.add_circle, size: 32), onPressed: () => _showForm())],
      ),
      body: RefreshIndicator(
        onRefresh: () => admin.fetchSuppliers(),
        child: admin.isLoading
            ? const Center(child: CircularProgressIndicator())
            : admin.suppliers.isEmpty
                ? const Center(child: Text('Belum ada supplier'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: admin.suppliers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final s = admin.suppliers[i];
                      return ModernCard(
                        padding: const EdgeInsets.all(12),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(color: AppColors.primary.withAlpha(20), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.business, color: AppColors.primary),
                          ),
                          title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${s.contact ?? '-'} • ${s.phone ?? '-'}', style: const TextStyle(color: AppColors.textSecondary)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.edit, size: 20, color: AppColors.primary), onPressed: () => _showForm(supplier: s)),
                              IconButton(icon: const Icon(Icons.delete, size: 20, color: AppColors.statusError), onPressed: () => admin.deleteSupplier(s.id)),
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
