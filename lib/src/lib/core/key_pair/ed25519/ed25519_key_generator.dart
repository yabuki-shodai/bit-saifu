import 'package:bit_saifu/src/lib/core/key_pair/key_pair_generator.dart';
import 'package:bit_saifu/src/lib/type/common/key_pair.dart';

import 'dart:typed_data';

class Ed25519KeyPairGenerator implements KeyPairGenerator {
  @override
  KeyPair generate() {
    // ed25519
    return KeyPair(privateKey: Uint8List(32), publicKey: Uint8List(32));
  }
}
