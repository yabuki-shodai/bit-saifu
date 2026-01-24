import 'dart:typed_data';
import 'package:bit_saifu/src/lib/type/bitcoin/address/bitcoin_address_type.dart';
import 'package:bit_saifu/src/lib/crypto/bitcoin/crypto/address/bitcoin_address.dart';
import 'package:bit_saifu/src/lib/type/network/crypto_network.dart';

class BitcoinAddressFactory {
  final CryptoNetwork network;
  BitcoinAddressFactory({required this.network});

  BitcoinAddress createAddress({
    required Uint8List publicKey,
    required BitcoinAddressType type,
  }) {
    switch (type) {
      case BitcoinAddressType.p2pkh:
        return _buildP2PKHAddress(publicKey);
      case BitcoinAddressType.p2wpkh:
        return _buildP2WPKHAddress(publicKey);
      case BitcoinAddressType.p2tr:
        return _buildP2TRAddress(publicKey);
      default:
        throw Exception('未対応のアドレスタイプ');
    }
  }

  // ============================================================
  // 共通ユーティリティ
  // ============================================================

  /// TODO: P2PKHアドレスの生成を実装する
  static BitcoinAddress _buildP2PKHAddress(Uint8List publicKey) {
    return BitcoinAddress(address: "p2pkh", type: BitcoinAddressType.p2pkh);
  }

  /// TODO: P2WPKHアドレスの生成を実装する
  static BitcoinAddress _buildP2WPKHAddress(Uint8List publicKey) {
    return BitcoinAddress(address: "p2wpkh", type: BitcoinAddressType.p2wpkh);
  }

  /// TODO: P2TRアドレスの生成を実装する
  static BitcoinAddress _buildP2TRAddress(Uint8List publicKey) {
    return BitcoinAddress(address: "p2tr", type: BitcoinAddressType.p2tr);
  }
}
