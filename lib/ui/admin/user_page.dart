import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../data/models/models.dart';
import '../../../providers/admin_provider.dart';
import '../widgets/modern_widgets.dart';
import '../widgets/confirm_dialog.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchUsers();
    });
  }

  void _showForm({User? user}) {
    final usernameCtrl = TextEditingController(text: user?.username ?? '');
    final passwordCtrl = TextEditingController();
    String selectedRole = user?.role ?? 'kasir';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(user == null ? 'Tambah Pengguna' : 'Edit Pengguna', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: usernameCtrl, decoration: const InputDecoration(labelText: 'Username *', prefixIcon: Icon(Icons.person_outline))),
              const SizedBox(height: 12),
              TextField(controller: passwordCtrl, obscureText: true, decoration: InputDecoration(labelText: user == null ? 'Password *' : 'Password baru (opsional)', prefixIcon: const Icon(Icons.lock_outline))),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(labelText: 'Role', prefixIcon: Icon(Icons.admin_panel_settings_outlined)),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'kasir', child: Text('Kasir')),
                  DropdownMenuItem(value: 'gudang', child: Text('Gudang')),
                ],
                onChanged: (v) => setModalState(() => selectedRole = v ?? 'kasir'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ModernButton(
              text: 'Simpan',
              onPressed: () async {
                final u = usernameCtrl.text.trim();
                final p = passwordCtrl.text;
                if (u.isEmpty) return;
                if (user == null && p.isEmpty) return;

                final admin = context.read<AdminProvider>();
                final ok = user == null
                    ? await admin.createUser(u, p, selectedRole)
                    : await admin.updateUser(user.id, username: u, password: p.isEmpty ? null : p, role: selectedRole);
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                if (!ok && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: ${admin.errorMessage}')));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Pengguna'),
        actions: [IconButton(icon: const Icon(Icons.person_add, size: 32), onPressed: () => _showForm())],
      ),
      body: RefreshIndicator(
        onRefresh: () => admin.fetchUsers(),
        child: admin.isLoading
            ? const Center(child: CircularProgressIndicator())
            : admin.users.isEmpty
                ? const Center(child: Text('Belum ada pengguna'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: admin.users.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final u = admin.users[i];
                      return ModernCard(
                        padding: const EdgeInsets.all(12),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(color: AppColors.primary.withAlpha(20), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.person, color: AppColors.primary),
                          ),
                          title: Text(u.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Role: ${u.role.toUpperCase()}', style: const TextStyle(color: AppColors.textSecondary)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.edit, size: 20, color: AppColors.primary), onPressed: () => _showForm(user: u)),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20, color: AppColors.statusError),
                                onPressed: () async {
                                  final ok = await showConfirmDialog(
                                    context,
                                    title: 'Hapus Pengguna',
                                    message: 'Yakin ingin menghapus "${u.username}"? Data tidak bisa dikembalikan.',
                                  );
                                  if (ok && context.mounted) admin.deleteUser(u.id);
                                },
                              ),
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
