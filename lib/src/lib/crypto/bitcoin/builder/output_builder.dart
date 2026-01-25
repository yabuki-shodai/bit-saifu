import 'package:bit_saifu/src/lib/crypto/bitcoin/crypto/address/bitcoin_address_factory.dart';
import 'package:bit_saifu/src/lib/type/bitcoin/bitcoin.dart';
import 'package:bit_saifu/src/lib/type/network/crypto_network.dart';

abstract class OutputBuilderBase {
  TxOutput fromAddress({
    required String address,
    required int amount,
    required CryptoNetwork network,
  });
}

class OutputBuilder implements OutputBuilderBase {
  @override
  TxOutput fromAddress({
    required String address,
    required int amount,
    required CryptoNetwork network,
  }) {
    final factory = BitcoinAddressFactory(network: network);
    final bitcoinAddress = factory.fromAddress(address: address);

    final output = TxOutput(
      value: amount,
      scriptPubKey: bitcoinAddress.toScriptPubKey(),
    );
    return output;
  }
}
