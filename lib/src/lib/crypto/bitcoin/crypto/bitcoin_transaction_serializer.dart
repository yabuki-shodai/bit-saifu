import 'dart:typed_data';
import 'package:bit_saifu/src/lib/crypto/bitcoin/domain/entity/transaction.dart';

class BitcoinTransactionSerializer {
  Uint8List serialize(Transaction tx) {
    final buffer = BytesBuilder();

    buffer.add(_uint32LE(tx.version));
    buffer.add(_varInt(tx.inputs.length));

    for (final input in tx.inputs) {
      buffer.add(input.txid);
      buffer.add(_uint32LE(input.vout));
      buffer.add(_varInt(input.scriptSig.length));
      buffer.add(input.scriptSig);
      buffer.add(_uint32LE(input.sequence));
    }

    buffer.add(_varInt(tx.outputs.length));
    for (final output in tx.outputs) {
      buffer.add(_uint64LE(output.value));
      buffer.add(_varInt(output.scriptPubKey.length));
      buffer.add(output.scriptPubKey);
    }

    buffer.add(_uint32LE(tx.lockTime));
    return buffer.toBytes();
  }

  String toHex(Transaction tx) {
    final bytes = serialize(tx);
    final buffer = StringBuffer();
    for (final b in bytes) {
      buffer.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  Uint8List _varInt(int value) {
    if (value < 0xfd) {
      return Uint8List.fromList([value]);
    }
    if (value <= 0xffff) {
      return Uint8List.fromList([0xfd, ..._uint16LE(value)]);
    }
    if (value <= 0xffffffff) {
      return Uint8List.fromList([0xfe, ..._uint32LE(value)]);
    }
    return Uint8List.fromList([0xff, ..._uint64LE(value)]);
  }

  Uint8List _uint16LE(int value) {
    return Uint8List.fromList([
      value & 0xff,
      (value >> 8) & 0xff,
    ]);
  }

  Uint8List _uint32LE(int value) {
    return Uint8List.fromList([
      value & 0xff,
      (value >> 8) & 0xff,
      (value >> 16) & 0xff,
      (value >> 24) & 0xff,
    ]);
  }

  Uint8List _uint64LE(int value) {
    final low = value & 0xffffffff;
    final high = (value >> 32) & 0xffffffff;
    return Uint8List.fromList([
      low & 0xff,
      (low >> 8) & 0xff,
      (low >> 16) & 0xff,
      (low >> 24) & 0xff,
      high & 0xff,
      (high >> 8) & 0xff,
      (high >> 16) & 0xff,
      (high >> 24) & 0xff,
    ]);
  }
}
