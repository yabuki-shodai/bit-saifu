import 'package:flutter_test/flutter_test.dart';
import 'package:bit_saifu/src/lib/bitcoin/domain/entity/utxo.dart';
import 'package:bit_saifu/src/lib/bitcoin/domain/usecase/calc_balance.dart';

void main() {
  group('CalcBalanceUseCase', () {
    test('calculates BTC balance from satoshi', () {
      final useCase = CalcBalanceUseCase();
      final utxos = [
        const Utxo(txid: 'a', vout: 0, value: 150000000, confirmed: true),
        const Utxo(txid: 'b', vout: 1, value: 50000000, confirmed: true),
      ];
      final balance = useCase.execute(utxos);
      expect(balance, 2.0);
    });

    test('returns 0 for empty list', () {
      final useCase = CalcBalanceUseCase();
      final balance = useCase.execute(const []);
      expect(balance, 0.0);
    });
  });
}
