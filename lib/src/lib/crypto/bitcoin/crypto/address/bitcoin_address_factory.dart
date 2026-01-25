import 'dart:typed_data';

import 'package:bit_saifu/src/lib/type/bitcoin/address/bitcoin_address_type.dart';
import 'package:bit_saifu/src/lib/crypto/bitcoin/crypto/address/bitcoin_address.dart';
import 'package:bit_saifu/src/lib/type/network/crypto_network.dart';

class BitcoinAddressFactory {
  final CryptoNetwork network;

  BitcoinAddressFactory({required this.network});

  // 公開鍵からアドレスを生成
  BitcoinAddress fromPublicKey({
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
  // utility methods（アドレス文字列 → BitcoinAddress（解析））
  // ============================================================

  // アドレス文字列からBitcoinAddressを生成
  BitcoinAddress fromAddress({
    required String address,
  }) {
    if (_isP2TR(address)) {
      return BitcoinAddress(
        address: address,
        type: BitcoinAddressType.p2tr,
      );
    }

    if (_isBech32(address)) {
      return BitcoinAddress(
        address: address,
        type: BitcoinAddressType.p2wpkh,
      );
    }

    if (_isBase58(address)) {
      return BitcoinAddress(
        address: address,
        type: BitcoinAddressType.p2pkh,
      );
    }

    throw Exception('未対応のBitcoinアドレス形式');
  }

  // ============================================================
  // utility methods（生成）
  // ============================================================

  BitcoinAddress _buildP2PKHAddress(Uint8List publicKey) {
    // TODO: HASH160 + Base58Check
    return BitcoinAddress(
      address: 'p2pkh_dummy',
      type: BitcoinAddressType.p2pkh,
    );
  }

  BitcoinAddress _buildP2WPKHAddress(Uint8List publicKey) {
    // TODO: HASH160 + bech32
    return BitcoinAddress(
      address: 'bc1_dummy',
      type: BitcoinAddressType.p2wpkh,
    );
  }

  BitcoinAddress _buildP2TRAddress(Uint8List publicKey) {
    // TODO: x-only pubkey + bech32m
    return BitcoinAddress(
      address: 'bc1p_dummy',
      type: BitcoinAddressType.p2tr,
    );
  }

  // ============================================================
  // private helpers（判定）
  // ============================================================

  bool _isBech32(String address) {
    return address.startsWith('bc1') || address.startsWith('tb1');
  }

  bool _isP2TR(String address) {
    return address.startsWith('bc1p') || address.startsWith('tb1p');
  }

  bool _isBase58(String address) {
    return address.startsWith('1') ||
        address.startsWith('m') ||
        address.startsWith('n');
  }
}
