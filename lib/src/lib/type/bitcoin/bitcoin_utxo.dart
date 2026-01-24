import 'dart:typed_data';

class BitcoinUtxo {
  final String txid;
  final int vout;
  final int value;
  final bool confirmed;
  final Uint8List scriptPubKey;

  const BitcoinUtxo({
    required this.txid,
    required this.vout,
    required this.value,
    required this.confirmed,
    required this.scriptPubKey,
  });
}
