import 'package:flutter_test/flutter_test.dart';
import 'package:bit_saifu/src/lib/bitcoin/domain/entity/utxo.dart';
import 'package:bit_saifu/src/lib/bitcoin/domain/usecase/select_utxo.dart';

void main() {
  group('SelectUtxoUseCase', () {
    test('selects confirmed utxos and calculates fee', () {
      final useCase = SelectUtxoUseCase();
      final utxos = [
        const Utxo(txid: 'a', vout: 0, value: 10000, confirmed: true),
        const Utxo(txid: 'b', vout: 1, value: 8000, confirmed: true),
        const Utxo(txid: 'c', vout: 2, value: 50000, confirmed: false),
      ];

      final result = useCase.execute(
        utxos: utxos,
        sendAmountSatoshi: 12000,
        feeRate: 1,
      );

      expect(result.selectedUtxos.length, 2);
      expect(result.fee, 374);
      expect(result.change, 5626);
      expect(result.txSize, 374);
    });

    test('drops dust change', () {
      final useCase = SelectUtxoUseCase();
      final utxos = [
        const Utxo(txid: 'a', vout: 0, value: 3000, confirmed: true),
      ];

      final result = useCase.execute(
        utxos: utxos,
        sendAmountSatoshi: 1500,
        feeRate: 5,
      );

      expect(result.change, 0);
    });
  });
}
