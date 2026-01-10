import 'package:bit_saifu/src/lib/bitcoin/domain/entity/utxo.dart';

class SelectUtxoUseCase {
  UtxoSelectionResult execute({
    required List<Utxo> utxos,
    required int sendAmountSatoshi,
    required int feeRate, // sat / vByte
  }) {
    // confirmed のみ使用
    final available = utxos.where((u) => u.confirmed).toList();

    // 大きい順にソート（input数削減）
    available.sort((a, b) => b.value.compareTo(a.value));

    final List<Utxo> selected = [];
    int totalInput = 0;

    for (final utxo in available) {
      selected.add(utxo);
      totalInput += utxo.value;

      // 送金 + お釣り（仮で2 output）
      final inputCount = selected.length;
      const outputCount = 2;

      final txSize = _estimateTxSize(
        inputCount: inputCount,
        outputCount: outputCount,
      );

      final fee = txSize * feeRate;

      if (totalInput >= sendAmountSatoshi + fee) {
        int change = totalInput - sendAmountSatoshi - fee;

        // Dust対策
        if (change < 546) {
          // お釣りを作らず fee に含める
          change = 0;
        }

        return UtxoSelectionResult(
          selectedUtxos: selected,
          fee: fee,
          change: change,
          txSize: txSize,
        );
      }
    }

    throw Exception('残高不足');
  }

  int _estimateTxSize({
    required int inputCount,
    required int outputCount,
  }) {
    return 10 + (148 * inputCount) + (34 * outputCount);
  }
}
