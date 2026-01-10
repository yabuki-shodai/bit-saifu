class Utxo {
  final String txid;
  final int vout;
  final int value;
  final bool confirmed;

  const Utxo({
    required this.txid,
    required this.vout,
    required this.value,
    required this.confirmed,
  });
}

/// UTXO選択結果
class UtxoSelectionResult {
  final List<Utxo> selectedUtxos;
  final int fee; // satoshi
  final int change; // satoshi
  final int txSize; // vBytes

  const UtxoSelectionResult({
    required this.selectedUtxos,
    required this.fee,
    required this.change,
    required this.txSize,
  });
}
