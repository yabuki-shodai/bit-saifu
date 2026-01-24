import 'package:flutter_test/flutter_test.dart';
import 'dart:typed_data';

import 'package:bit_saifu/src/lib/crypto/bitcoin/data/dto/utxo_dto.dart';
import 'package:bit_saifu/src/lib/crypto/bitcoin/domain/entity/utxo.dart';

void main() {
  group('UtxoDto', () {
    test('fromJson maps fields', () {
      final json = {
        'txid': 'abc',
        'vout': 1,
        'value': 12345,
        'status': {'confirmed': true},
      };

      final dto = UtxoDto.fromJson(json);
      expect(dto.txid, 'abc');
      expect(dto.vout, 1);
      expect(dto.value, 12345);
      expect(dto.confirmed, isTrue);
    });

    test('toEntity converts to Utxo', () {
      const dto = UtxoDto(
        txid: 'abc',
        vout: 1,
        value: 12345,
        confirmed: true,
      );

      final script = Uint8List.fromList([0x00, 0x01]);
      final entity = dto.toEntity(script);
      expect(entity, isA<Utxo>());
      expect(entity.txid, 'abc');
      expect(entity.vout, 1);
      expect(entity.value, 12345);
      expect(entity.confirmed, isTrue);
      expect(entity.scriptPubKey, script);
    });
  });
}
