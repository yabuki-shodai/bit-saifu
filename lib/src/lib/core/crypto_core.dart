import 'dart:typed_data';

abstract class CryptoCore {
  /// 秘密鍵を生成
  Uint8List generatePrivateKey();

  /// 秘密鍵を公開鍵に変換
  Uint8List privateKeyToPublicKey(Uint8List privateKey);

  /// 公開鍵をアドレスに変換
  String publicKeyToAddress(Uint8List publicKey);
}
