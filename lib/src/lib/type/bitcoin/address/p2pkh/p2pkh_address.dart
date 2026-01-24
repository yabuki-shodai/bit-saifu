import 'dart:typed_data';
import 'package:bit_saifu/src/lib/type/bitcoin/address/bitcoin_address_base.dart';

class P2pkhAddress extends Address {
  final Uint8List pubKeyHash; // 20 bytes

  P2pkhAddress(this.pubKeyHash);

  @override
  Uint8List toScriptPubKey() {
    return Uint8List.fromList([
      0x76, // OP_DUP
      0xa9, // OP_HASH160
      0x14, // push 20
      ...pubKeyHash,
      0x88, // OP_EQUALVERIFY
      0xac, // OP_CHECKSIG
    ]);
  }
}
