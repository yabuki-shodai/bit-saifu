import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:bit_saifu/src/lib/crypto/bitcoin/crypto/bitcoin.dart';

void main() {
  group('Bitcoin address', () {
    test('publicKeyToAddress returns testnet address', () {
      final bitcoinCrypto = BitcoinCrypto(testnet: true);
      final keyBytes = List<int>.filled(32, 0);
      keyBytes[31] = 1;
      final privateKey = Uint8List.fromList(keyBytes);
      final publicKey = bitcoinCrypto.privateKeyToPublicKey(privateKey);
      final address = bitcoinCrypto.publicKeyToAddress(publicKey);
      expect(address.length, greaterThanOrEqualTo(26));
      expect(address.startsWith('m') || address.startsWith('n'), isTrue);
    });

    test('publicKeyToAddress returns mainnet address', () {
      final bitcoinCrypto = BitcoinCrypto(testnet: false);
      final keyBytes = List<int>.filled(32, 0);
      keyBytes[31] = 1;
      final privateKey = Uint8List.fromList(keyBytes);
      final publicKey = bitcoinCrypto.privateKeyToPublicKey(privateKey);
      final address = bitcoinCrypto.publicKeyToAddress(publicKey);
      expect(address.startsWith('1'), isTrue);
    });
  });
}
