import 'package:bit_saifu/src/lib/type/bitcoin/bitcoin.dart';

class BitcoinTransaction {
  final int version;
  final List<TxInput> inputs;
  final List<TxOutput> outputs;
  final int lockTime;

  BitcoinTransaction({
    this.version = 2,
    required this.inputs,
    required this.outputs,
    this.lockTime = 0,
  });

  /// Segwitトランザクションかどうかを判定
  bool get isSegwit =>
      inputs.any((input) => input.witness != null && input.witness!.isNotEmpty);
}
