import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureKeyStore {
  static const _storage = FlutterSecureStorage();

  static String _key(String address) => 'btc_private_$address';

  /// 秘密鍵を保存
  /// [address] アドレス
  /// [privateKey] 秘密鍵
  Future<void> savePrivateKey(
    String address,
    Uint8List privateKey,
  ) async {
    await _storage.write(
      key: _key(address),
      value: _bytesToHex(privateKey),
    );
  }

  /// 秘密鍵を読み込む
  ///
  /// [address] アドレス
  Future<Uint8List?> loadPrivateKey(String address) async {
    final value = await _storage.read(key: _key(address));
    if (value == null) return null;
    return _hexToBytes(value);
  }

  /// 秘密鍵を削除
  /// [address] アドレス
  Future<void> deletePrivateKey(String address) async {
    await _storage.delete(key: _key(address));
  }

  /// バイト列を16進文字列に変換
  static String _bytesToHex(Uint8List bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  static Uint8List _hexToBytes(String hex) => Uint8List.fromList(
        List.generate(
          hex.length ~/ 2,
          (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16),
        ),
      );
}
