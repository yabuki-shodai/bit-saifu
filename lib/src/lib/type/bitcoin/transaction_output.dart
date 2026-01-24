import 'dart:typed_data';

class TxOutput {
  final int value; // satoshi
  final Uint8List scriptPubKey;

  TxOutput({
    required this.value,
    required this.scriptPubKey,
  });
}
