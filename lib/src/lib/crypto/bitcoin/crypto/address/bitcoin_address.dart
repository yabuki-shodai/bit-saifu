import 'package:bit_saifu/src/lib/type/bitcoin/address/bitcoin_address_type.dart';

class BitcoinAddress {
  final String address;
  final BitcoinAddressType type;

  BitcoinAddress({
    required this.address,
    required this.type,
  });
}
