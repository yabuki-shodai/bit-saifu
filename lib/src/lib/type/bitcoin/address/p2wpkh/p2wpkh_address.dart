import 'dart:typed_data';
import 'package:bit_saifu/src/lib/type/bitcoin/address/bitcoin_address_base.dart';

class P2wpkhAddress extends Address {
  final Uint8List pubKeyHash; // 20 bytes

  P2wpkhAddress(this.pubKeyHash);

  @override
  Uint8List toScriptPubKey() {
    return Uint8List.fromList([
      0x00, // witness version 0
      0x14, // push 20
      ...pubKeyHash,
    ]);
  }
}
