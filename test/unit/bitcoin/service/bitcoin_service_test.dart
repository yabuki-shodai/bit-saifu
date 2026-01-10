import 'package:flutter_test/flutter_test.dart';
import 'package:bit_saifu/src/lib/bitcoin/domain/entity/utxo.dart';
import 'package:bit_saifu/src/lib/bitcoin/service/bitcoin_service.dart';

void main() {
  group('BitcoinService', () {
    test('calcBalance converts satoshi to BTC', () {
      final service = BitcoinService();
      final utxos = [
        Utxo(txid: 'a', vout: 0, value: 150000000, confirmed: true),
        Utxo(txid: 'b', vout: 1, value: 50000000, confirmed: true),
      ];
      final balance = service.calcBalance(utxos);
      expect(balance, 2.0);
    });

    test('selectUtxos chooses confirmed utxos and calculates fee', () {
      final service = BitcoinService();
      final utxos = [
        Utxo(txid: 'a', vout: 0, value: 10000, confirmed: true),
        Utxo(txid: 'b', vout: 1, value: 8000, confirmed: true),
        Utxo(txid: 'c', vout: 2, value: 50000, confirmed: false),
      ];

      final result = service.selectUtxos(
        utxos: utxos,
        sendAmountSatoshi: 12000,
        feeRate: 1,
      );

      expect(result.selectedUtxos.length, 2);
      expect(result.fee, 374);
      expect(result.change, 5626);
      expect(result.txSize, 374);
    });
  });
}
