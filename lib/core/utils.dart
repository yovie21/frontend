import 'package:flutter/services.dart';

class AppUtils {
  /// 25000 → 25.000 (titik ribuan, tanpa locale).
  static String formatCurrency(dynamic value) {
    if (value == null) return '0';
    final int n = value is num
        ? value.round()
        : (int.tryParse(value.toString().replaceAll(RegExp(r'[^0-9-]'), '')) ?? 0);
    final digits = n.abs().toString();
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write('.');
      buf.write(digits[i]);
    }
    return n < 0 ? '-$buf' : buf.toString();
  }

  static String formatDate(dynamic dateString) {
    if (dateString == null) return '-';
    try {
      final dt = DateTime.parse(dateString.toString()).toLocal();
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year} $hh:$mm';
    } catch (_) {
      return dateString.toString();
    }
  }

  static double parseCurrency(String text) {
    if (text.isEmpty) return 0.0;
    final clean = text.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(clean) ?? 0.0;
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue.copyWith(text: '');
    final clean = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) return newValue.copyWith(text: '');
    final formatted = AppUtils.formatCurrency(int.parse(clean));
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
