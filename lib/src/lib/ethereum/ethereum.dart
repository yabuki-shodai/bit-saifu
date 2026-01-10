import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/ecc/api.dart';
import 'package:pointycastle/ecc/curves/secp256k1.dart';
import 'package:pointycastle/digests/keccak.dart';

class EthereumKeyGenerator {
  /// 秘密鍵を生成（32byte）
  static Uint8List generatePrivateKey() {
    final rand = Random.secure();
    return Uint8List.fromList(
      List.generate(32, (_) => rand.nextInt(256)),
    );
  }

  /// 秘密鍵 → 公開鍵（Ethereum形式：04なし）
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

    // Ethereumでは 0x04 を付けない
    return Uint8List.fromList([...xBytes, ...yBytes]);
  }

  /// 公開鍵 → Ethereumアドレス（EIP-55 チェックサム付き）
  static String publicKeyToAddress(Uint8List publicKey) {
    final keccak = KeccakDigest(256);
    keccak.update(publicKey, 0, publicKey.length);

    final hash = Uint8List(32);
    keccak.doFinal(hash, 0);

    // 下位20byte
    final addressBytes = hash.sublist(12);
    final hexAddress = '0x${_bytesToHex(addressBytes)}';

    return toChecksumAddress(hexAddress);
  }

  /// EIP-55 チェックサム変換
  static String toChecksumAddress(String address) {
    final addr = address.replaceFirst('0x', '').toLowerCase();

    final keccak = KeccakDigest(256);
    keccak.update(Uint8List.fromList(addr.codeUnits), 0, addr.length);

    final hash = Uint8List(32);
    keccak.doFinal(hash, 0);

    final hashHex = _bytesToHex(hash);
    final result = StringBuffer('0x');

    for (int i = 0; i < addr.length; i++) {
      final char = addr[i];
      final hashNibble = int.parse(hashHex[i], radix: 16);

      if (hashNibble >= 8) {
        result.write(char.toUpperCase());
      } else {
        result.write(char);
      }
    }

    return result.toString();
  }

  /// BigInt → Uint8List
  static Uint8List _bigIntToBytes(BigInt value, int length) {
    final hex = value.toRadixString(16).padLeft(length * 2, '0');
    return Uint8List.fromList(
      List.generate(
        length,
        (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16),
      ),
    );
  }

  /// Uint8List → hex文字列
  static String _bytesToHex(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
