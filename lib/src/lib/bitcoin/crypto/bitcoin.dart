import 'dart:math';
import 'dart:typed_data';
import 'package:bit_saifu/src/lib/bitcoin/crypto/bitcoin_address_detector.dart';
import 'package:bit_saifu/src/lib/core/crypto_core.dart';
import 'package:crypto/crypto.dart';
import 'package:base58check/base58check.dart';
import 'package:pointycastle/export.dart';

/// Bitcoin 用の暗号処理クラス
/// - 秘密鍵生成
/// - 公開鍵生成
/// - P2PKHアドレス生成
/// - アドレス → scriptPubKey 生成
class BitcoinCrypto implements CryptoCore {
  /// true の場合 Testnet、false の場合 Mainnet
  final bool testnet;

  BitcoinCrypto({this.testnet = true});

  // ============================================================
  // 1. 秘密鍵生成
  // ============================================================

  /// 32バイトのランダムな秘密鍵を生成する
  /// Bitcoin では secp256k1 のスカラーとして利用される
  @override
  Uint8List generatePrivateKey() {
    final rand = Random.secure();
    return Uint8List.fromList(
      List.generate(32, (_) => rand.nextInt(256)),
    );
  }

  // ============================================================
  // 2. 秘密鍵 → 公開鍵
  // ============================================================

  /// 秘密鍵から公開鍵を生成する
  /// ※ 非圧縮公開鍵（65bytes）
  @override
  Uint8List privateKeyToPublicKey(Uint8List privateKey) {
    final curve = ECCurve_secp256k1();

    final d = BigInt.parse(
      privateKey.map((e) => e.toRadixString(16).padLeft(2, '0')).join(),
      radix: 16,
    );

    final ECPoint Q = (curve.G * d)!;

    final x = Q.x!.toBigInteger()!;
    final y = Q.y!.toBigInteger()!;

    return Uint8List.fromList([
      0x04,
      ..._bigIntToBytes(x, 32),
      ..._bigIntToBytes(y, 32),
    ]);
  }

  // ============================================================
  // 3. P2PKH アドレス（Legacy）
  // ============================================================

  @override
  String publicKeyToAddress(Uint8List publicKey) {
    final sha256Hash = sha256.convert(publicKey).bytes;
    final pubKeyHash =
        RIPEMD160Digest().process(Uint8List.fromList(sha256Hash));

    final version = testnet ? 0x6f : 0x00;

    return Base58CheckCodec.bitcoin().encode(
      Base58CheckPayload(version, pubKeyHash),
    );
  }

  // ============================================================
  // ============================================================
  // 4. アドレス → scriptPubKey
  // ============================================================

  /// アドレス文字列から scriptPubKey を生成する
  Uint8List addressToScriptPubKey(String address) {
    final type = BitcoinAddressDetector.detect(address);

    switch (type) {
      case BitcoinAddressType.p2pkh:
        final pubKeyHash = _decodeBase58(address);
        return _buildP2PKHScript(pubKeyHash);
      default:
        throw Exception('未対応のアドレスタイプ');
    }
  }

  // ============================================================
  // scriptPubKey ビルダー
  // ============================================================

  /// OP_DUP OP_HASH160 <pubKeyHash> OP_EQUALVERIFY OP_CHECKSIG
  Uint8List _buildP2PKHScript(Uint8List pubKeyHash) {
    return Uint8List.fromList([
      0x76, // OP_DUP
      0xa9, // OP_HASH160
      0x14, // push 20 bytes
      ...pubKeyHash,
      0x88, // OP_EQUALVERIFY
      0xac, // OP_CHECKSIG
    ]);
  }

  // ============================================================
  // デコード系
  // ============================================================

  Uint8List _decodeBase58(String address) {
    final payload = Base58CheckCodec.bitcoin().decode(address);
    return Uint8List.fromList(payload.payload);
  }

  // ============================================================
  // 共通ユーティリティ
  // ============================================================

  Uint8List _hash160(Uint8List data) {
    final sha = sha256.convert(data).bytes;
    return RIPEMD160Digest().process(Uint8List.fromList(sha));
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
