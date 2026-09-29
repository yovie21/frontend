import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/utils.dart';

void main() {
  test('formatCurrency pakai titik ribuan', () {
    expect(AppUtils.formatCurrency(25000), '25.000');
    expect(AppUtils.formatCurrency(25000.9), '25.001');
    expect(AppUtils.formatCurrency(25), '25');
    expect(AppUtils.formatCurrency(0), '0');
  });

  test('parseCurrency buang titik', () {
    expect(AppUtils.parseCurrency('25.000'), 25000);
    expect(AppUtils.parseCurrency('Rp 230.000'), 230000);
    expect(AppUtils.parseCurrency('25'), 25);
  });
}
