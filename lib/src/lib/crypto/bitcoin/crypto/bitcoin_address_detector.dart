import 'package:base58check/base58check.dart';

enum BitcoinAddressType {
  p2pkh,
  unknown,
}

class BitcoinAddressDetector {
  static BitcoinAddressType detect(String address) {
    return _detectBase58(address);
  }

  static BitcoinAddressType _detectBase58(String address) {
    try {
      final decoded = Base58CheckCodec.bitcoin().decode(address);

      final version = decoded.version;

      // Mainnet
      if (version == 0x00) return BitcoinAddressType.p2pkh;

      // Testnet
      if (version == 0x6f) return BitcoinAddressType.p2pkh;
    } catch (_) {
      return BitcoinAddressType.unknown;
    }

    return BitcoinAddressType.unknown;
  }
}
