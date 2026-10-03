import 'package:flutter/material.dart';
import '../../../core/utils.dart';
import '../../../data/services/services.dart';

class AuditPage extends StatefulWidget {
  const AuditPage({super.key});

  @override
  State<AuditPage> createState() => _AuditPageState();
}

class _AuditPageState extends State<AuditPage> {
  List<dynamic> rows = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await AuditService.getLogs();
      if (!mounted) return;
      setState(() {
        rows = r;
        loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Log Aktivitas', style: TextStyle(fontWeight: FontWeight.w800))),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: rows.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final r = rows[i] as Map<String, dynamic>;
                final user = r['user'] as Map<String, dynamic>?;
                return ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  title: Text('${r['action']} · ${r['entity']}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${user?['username'] ?? '-'} · ${AppUtils.formatDate(r['createdAt'])}'),
                  trailing: Text('#${r['entityId'] ?? '-'}'),
                );
              },
            ),
    );
  }
}
