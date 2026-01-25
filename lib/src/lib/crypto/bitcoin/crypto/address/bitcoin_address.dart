import 'package:base58check/base58check.dart';
import 'package:bech32/bech32.dart';
import 'package:bit_saifu/src/lib/type/bitcoin/address/bitcoin_address_type.dart';
import 'dart:typed_data';

class BitcoinAddress {
  final String address;
  final BitcoinAddressType type;

  BitcoinAddress({
    required this.address,
    required this.type,
  });

  // ============================================================
  // scriptPubKey を生成
  // ============================================================

  Uint8List toScriptPubKey() {
    switch (type) {
      case BitcoinAddressType.p2pkh:
        return _p2pkhScriptPubKey();
      case BitcoinAddressType.p2wpkh:
        return _p2wpkhScriptPubKey();
      case BitcoinAddressType.p2tr:
        return _p2trScriptPubKey();
      default:
        throw Exception('未対応のアドレスタイプ');
    }
  }

  // ============================================================
  // private helpers
  // ============================================================

  /// P2PKHのscriptPubKeyを生成
  Uint8List _p2pkhScriptPubKey() {
    final payload = Base58CheckCodec.bitcoin().decode(address);
    final pubKeyHash = Uint8List.fromList(payload.payload);

    return Uint8List.fromList([
      0x76, // OP_DUP
      0xa9, // OP_HASH160
      0x14, // push 20 bytes
      ...pubKeyHash,
      0x88, // OP_EQUALVERIFY
      0xac, // OP_CHECKSIG
    ]);
  }

  /// P2WPKHのscriptPubKeyを生成
  Uint8List _p2wpkhScriptPubKey() {
    const codec = Bech32Codec();
    final decoded = codec.decode(address);
    final witnessProgram = decoded.data;

    return Uint8List.fromList([
      0x00, // witness version 0
      0x14, // push 20 bytes
      ...witnessProgram,
    ]);
  }

  /// P2TRのscriptPubKeyを生成
  Uint8List _p2trScriptPubKey() {
    const codec = Bech32Codec();
    final decoded = codec.decode(address);
    final witnessProgram = decoded.data;

    return Uint8List.fromList([
      0x51, // OP_1
      0x20, // push 32 bytes
      ...witnessProgram,
    ]);
  }
}
