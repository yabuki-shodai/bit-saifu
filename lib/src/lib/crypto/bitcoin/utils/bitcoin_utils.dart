import 'package:bit_saifu/src/lib/type/bitcoin/bitcoin.dart';
import 'package:bit_saifu/src/lib/type/network/crypto_network.dart';

class BitcoinUtils {
  final CryptoNetwork network;

  BitcoinUtils({this.network = CryptoNetwork.testnet});

  // アドレスからアドレスタイプを判別
  static BitcoinAddressType detectAddressType(String address) {
    return BitcoinAddressType.p2pkh;
  }
}
