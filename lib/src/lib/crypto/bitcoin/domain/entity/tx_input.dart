import 'dart:typed_data';


class TxInput {
  final Uint8List txid; // little-endian
  final int vout;
  final Uint8List scriptSig;
  final int sequence;

  TxInput({
    required this.txid,
    required this.vout,
    Uint8List? scriptSig,
    this.sequence = 0xffffffff,
  }) : scriptSig = scriptSig ?? Uint8List(0);

  TxInput copyWith({
    Uint8List? scriptSig,
  }) {
    return TxInput(
      txid: txid,
      vout: vout,
      scriptSig: scriptSig ?? this.scriptSig,
      sequence: sequence,
    );
  }
}
