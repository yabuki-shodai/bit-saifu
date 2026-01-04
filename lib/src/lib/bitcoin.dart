import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/ecc/api.dart';
import 'package:pointycastle/ecc/curves/secp256k1.dart';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/digests/ripemd160.dart';
import 'package:base58check/base58check.dart';

class BitcoinKeyGenerator {
  /// 秘密鍵を生成
  static Uint8List generatePrivateKey() {
    final rand = Random.secure();
    return Uint8List.fromList(
      List.generate(32, (_) => rand.nextInt(256)),
    );
  }

  /// 秘密鍵を公開鍵に変換
  static Uint8List privateKeyToPublicKey(Uint8List privateKey) {
    final curve = ECCurve_secp256k1();

    final d = BigInt.parse(
      privateKey.map((e) => e.toRadixString(16).padLeft(2, '0')).join(),
      radix: 16,
    );

    final ECPoint Q = (curve.G * d)!;

    final x = Q.x!.toBigInteger()!;
    final y = Q.y!.toBigInteger()!;

    final xBytes = _bigIntToBytes(x, 32);
    final yBytes = _bigIntToBytes(y, 32);

    // 非圧縮公開鍵
    return Uint8List.fromList([0x04, ...xBytes, ...yBytes]);
  }

  /// 公開鍵をビットコインアドレスに変換
  static String publicKeyToAddress(Uint8List publicKey) {
    final sha256Hash = sha256.convert(publicKey).bytes;
    final ripemd160Hash =
        RIPEMD160Digest().process(Uint8List.fromList(sha256Hash));

    // P2PKH Mainnet
    const int version = 0x00;
    // version = 0x6f; // testnet

    final payload = Uint8List.fromList(ripemd160Hash);

    return Base58CheckCodec.bitcoin().encode(
      Base58CheckPayload(version, payload),
    );
  }

  /// 大きな整数をバイト列に変換
  static Uint8List _bigIntToBytes(BigInt value, int length) {
    final hex = value.toRadixString(16).padLeft(length * 2, '0');
    return Uint8List.fromList(
      List.generate(
          length, (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16)),
    );
  }
}
