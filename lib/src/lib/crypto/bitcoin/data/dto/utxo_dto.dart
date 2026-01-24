import 'dart:typed_data';

import 'package:bit_saifu/src/lib/crypto/bitcoin/domain/entity/utxo.dart';

class UtxoDto {
  final String txid;
  final int vout;
  final int value;
  final bool confirmed;

  const UtxoDto({
    required this.txid,
    required this.vout,
    required this.value,
    required this.confirmed,
  });

  factory UtxoDto.fromJson(Map<String, dynamic> json) {
    return UtxoDto(
      txid: json['txid'],
      vout: json['vout'],
      value: json['value'],
      confirmed: json['status']['confirmed'],
    );
  }

  Utxo toEntity(Uint8List scriptPubKey) {
    return Utxo(
      txid: txid,
      vout: vout,
      value: value,
      confirmed: confirmed,
      scriptPubKey: scriptPubKey,
    );
  }
}
