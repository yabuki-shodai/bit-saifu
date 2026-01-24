import 'dart:typed_data';
import 'package:bit_saifu/src/lib/crypto/bitcoin/utils/bitcoin_utils.dart';
import 'package:bit_saifu/src/lib/type/bitcoin/bitcoin.dart';

class InputBuilder {
  final BitcoinUtils bitcoinUtils = BitcoinUtils();

  static TxInput fromUtxo({
    required BitcoinUtxo utxo,
    required Uint8List signature,
    required Uint8List publicKey,
  }) {
    // addressのタイプか判別
    const addressType = BitcoinAddressType.p2sh;

    switch (addressType) {
      case BitcoinAddressType.p2pkh:
        return TxInput(
          txid: Uint8List.fromList(utxo.txid.codeUnits),
          vout: utxo.vout,
          scriptSig: _buildScriptSig(signature, publicKey),
        );

      case BitcoinAddressType.p2wpkh:
        return TxInput(
          txid: Uint8List.fromList(utxo.txid.codeUnits),
          vout: utxo.vout,
          scriptSig: Uint8List(0),
          witness: [signature, publicKey],
        );

      case BitcoinAddressType.p2tr:
        return TxInput(
          txid: Uint8List.fromList(utxo.txid.codeUnits),
          vout: utxo.vout,
          scriptSig: Uint8List(0),
          witness: [signature], // schnorr
        );
      default:
        throw Exception('未対応のアドレスタイプ');
    }
  }

  static Uint8List _buildScriptSig(
    Uint8List signature,
    Uint8List publicKey,
  ) {
    return Uint8List.fromList([
      signature.length,
      ...signature,
      publicKey.length,
      ...publicKey,
    ]);
  }
}
