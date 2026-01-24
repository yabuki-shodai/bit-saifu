import 'package:bit_saifu/src/lib/crypto/bitcoin/domain/entity/tx_input.dart';
import 'package:bit_saifu/src/lib/crypto/bitcoin/domain/entity/tx_output.dart';

class Transaction {
  final int version;
  final List<TxInput> inputs;
  final List<TxOutput> outputs;
  final int lockTime;

  Transaction({
    this.version = 2,
    required this.inputs,
    required this.outputs,
    this.lockTime = 0,
  });
}
