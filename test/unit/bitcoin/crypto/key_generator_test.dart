import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:bit_saifu/src/lib/crypto/bitcoin/crypto/bitcoin.dart';

void main() {
  group('BitcoinKeyGenerator', () {
    test('generatePrivateKey returns 32 bytes', () {
      final bitcoinCrypto = BitcoinCrypto(testnet: true);
      final key = bitcoinCrypto.generatePrivateKey();
      expect(key.length, 32);
      expect(key.any((b) => b != 0), isTrue);
    });

    test('privateKeyToPublicKey returns uncompressed key', () {
      final bitcoinCrypto = BitcoinCrypto(testnet: true);
      final keyBytes = List<int>.filled(32, 0);
      keyBytes[31] = 1;
      final privateKey = Uint8List.fromList(keyBytes);
      final publicKey = bitcoinCrypto.privateKeyToPublicKey(privateKey);
      expect(publicKey.length, 65);
      expect(publicKey.first, 0x04);
    });
  });
}
