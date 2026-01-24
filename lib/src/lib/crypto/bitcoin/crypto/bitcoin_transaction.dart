import 'package:bit_saifu/src/lib/crypto/bitcoin/domain/entity/tx_input.dart';
import 'package:bit_saifu/src/lib/crypto/bitcoin/domain/entity/utxo.dart';
import 'dart:typed_data';

class TransactionBuilder {
  TxInput utxoToInput(Utxo utxo) {
    return TxInput(
      txid: _reverseBytes(_hexToBytes(utxo.txid)),
      vout: utxo.vout,
    );
  }

  Uint8List _hexToBytes(String hex) {
    return Uint8List.fromList(
      List.generate(
        hex.length ~/ 2,
        (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16),
      ),
    );
  }

  Uint8List _reverseBytes(Uint8List bytes) {
    return Uint8List.fromList(bytes.reversed.toList());
  }
}
