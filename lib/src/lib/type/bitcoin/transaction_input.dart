import 'dart:typed_data';

class TxInput {
  final Uint8List txid;
  final int vout;
  Uint8List scriptSig;
  List<Uint8List>? witness;
  final int sequence;

  TxInput({
    required this.txid,
    required this.vout,
    Uint8List? scriptSig,
    this.witness,
    this.sequence = 0xffffffff,
  }) : scriptSig = scriptSig ?? Uint8List(0);
}
