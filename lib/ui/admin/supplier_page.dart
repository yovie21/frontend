import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../data/models/models.dart';
import '../../../providers/admin_provider.dart';
import '../widgets/modern_widgets.dart';
import '../widgets/confirm_dialog.dart';

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
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: admin.suppliers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final s = admin.suppliers[i];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: const [BoxShadow(color: Color(0x040F172A), blurRadius: 10, offset: Offset(0, 4))],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFF0F3826), Color(0xFF1B5E3C)]),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.business, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A))),
                                  const SizedBox(height: 4),
                                  Text('${s.contact ?? '-'} · ${s.phone ?? '-'}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                                ],
                              ),
                            ),
                            IconButton(icon: const Icon(Icons.edit, color: Color(0xFF0F3826)), onPressed: () => _showForm(supplier: s)),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Color(0xFFDC2626)),
                              onPressed: () async {
                                final ok = await showConfirmDialog(
                                  context,
                                  title: 'Hapus Supplier',
                                  message: 'Yakin ingin menghapus "${s.name}"? Data tidak bisa dikembalikan.',
                                );
                                if (ok && context.mounted) admin.deleteSupplier(s.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(24)),
            child: const Icon(Icons.business_center_outlined, size: 48, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 16),
          const Text('Belum ada supplier', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }
}
