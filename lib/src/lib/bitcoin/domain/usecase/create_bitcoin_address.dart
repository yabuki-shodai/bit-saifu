import 'package:bit_saifu/src/lib/bitcoin/crypto/bitcoin.dart';
import 'dart:typed_data';
import 'package:bit_saifu/src/lib/secure/secure_key_store.dart';
import 'package:bit_saifu/src/lib/bitcoin/data/repository.dart';

typedef CreateBitcoinAddressResult = (
  String address,
  Uint8List privateKey,
  Uint8List publicKey
);

class CreateBitcoinAddressUseCase {
  final BitcoinCrypto bitcoinCrypto;

  CreateBitcoinAddressUseCase({required this.bitcoinCrypto});

  /// 新しいBitcoinアドレスを生成
  ///
  /// 秘密鍵、公開鍵、アドレスを返す
  ///
  /// [address] アドレス
  ///
  /// [privateKey] 秘密鍵
  ///
  /// [publicKey] 公開鍵
  ///
  CreateBitcoinAddressResult execute() {
    final privateKey = bitcoinCrypto.generatePrivateKey();
    final publicKey = bitcoinCrypto.privateKeyToPublicKey(privateKey);
    final address = bitcoinCrypto.publicKeyToAddress(publicKey);

    return (address, privateKey, publicKey);
  }
}
