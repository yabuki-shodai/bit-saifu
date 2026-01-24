import 'package:bit_saifu/src/lib/core/key_pair/key_pair_generator.dart';
import 'package:bit_saifu/src/lib/type/common/key_pair.dart';
import 'dart:typed_data';
import 'dart:math';

import 'package:pointycastle/export.dart';

class Secp256k1KeyPairGenerator implements KeyPairGenerator {
  @override
  KeyPair generate() {
    // secp256k1
    final random = Random.secure();

    /// 秘密鍵の生成
    final privateKey =
        Uint8List.fromList(List.generate(32, (_) => random.nextInt(256)));

    // 公開鍵の生成
    final curve = ECCurve_secp256k1();

    final d = BigInt.parse(
      privateKey.map((e) => e.toRadixString(16).padLeft(2, '0')).join(),
      radix: 16,
    );

    final ECPoint Q = (curve.G * d)!;

    final x = Q.x!.toBigInteger()!;
    final y = Q.y!.toBigInteger()!;
    final publicKey = Uint8List.fromList([
      0x04,
      ..._bigIntToBytes(x, 32),
      ..._bigIntToBytes(y, 32),
    ]);

    return KeyPair(privateKey: privateKey, publicKey: publicKey);
  }

  static Uint8List _bigIntToBytes(BigInt value, int length) {
    final hex = value.toRadixString(16).padLeft(length * 2, '0');
    return Uint8List.fromList(
      List.generate(
        length,
        (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16),
      ),
    );
  }
}
