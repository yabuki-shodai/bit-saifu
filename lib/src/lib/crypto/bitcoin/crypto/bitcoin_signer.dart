import 'dart:math';
import 'dart:typed_data';
import 'package:bit_saifu/src/lib/crypto/bitcoin/crypto/bitcoin.dart';
import 'package:bit_saifu/src/lib/crypto/bitcoin/domain/entity/transaction.dart';
import 'package:bit_saifu/src/lib/crypto/bitcoin/domain/entity/tx_input.dart';
import 'package:bit_saifu/src/lib/crypto/bitcoin/domain/entity/utxo.dart';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';

class P2pkhInputSigningData {
  final int inputIndex;
  final Utxo utxo;
  final Uint8List privateKey;

  const P2pkhInputSigningData({
    required this.inputIndex,
    required this.utxo,
    required this.privateKey,
  });
}

class BitcoinSigner {
  static const int sighashAll = 0x01;

  final BitcoinCrypto crypto;

  BitcoinSigner({BitcoinCrypto? crypto}) : crypto = crypto ?? BitcoinCrypto();

  Transaction signP2pkhTransaction(
    Transaction transaction,
    List<P2pkhInputSigningData> inputs,
  ) {
    final updatedInputs = List<TxInput>.from(transaction.inputs);

    for (final item in inputs) {
      if (item.inputIndex < 0 || item.inputIndex >= transaction.inputs.length) {
        throw Exception('inputIndexが範囲外です');
      }

      final pubKey = crypto.privateKeyToPublicKey(item.privateKey);
      final sighash = _sighashAll(transaction, item.inputIndex, item.utxo);
      final signature = _sign(item.privateKey, sighash);

      final signatureWithType = Uint8List.fromList([...signature, sighashAll]);
      final scriptSig = _buildScriptSig(signatureWithType, pubKey);

      updatedInputs[item.inputIndex] =
          updatedInputs[item.inputIndex].copyWith(scriptSig: scriptSig);
    }

    return Transaction(
      version: transaction.version,
      inputs: updatedInputs,
      outputs: transaction.outputs,
      lockTime: transaction.lockTime,
    );
  }

  Uint8List _sighashAll(
    Transaction tx,
    int inputIndex,
    Utxo utxo,
  ) {
    final serialized = _serializeForSigning(tx, inputIndex, utxo.scriptPubKey);
    final hashed = sha256.convert(serialized).bytes;
    final doubleHashed = sha256.convert(hashed).bytes;
    return Uint8List.fromList(doubleHashed);
  }


  Uint8List _serializeForSigning(
    Transaction tx,
    int inputIndex,
    Uint8List scriptPubKey,
  ) {
    final buffer = BytesBuilder();

    buffer.add(_uint32LE(tx.version));
    buffer.add(_varInt(tx.inputs.length));

    for (int i = 0; i < tx.inputs.length; i++) {
      final input = tx.inputs[i];
      buffer.add(input.txid);
      buffer.add(_uint32LE(input.vout));
      if (i == inputIndex) {
        buffer.add(_varInt(scriptPubKey.length));
        buffer.add(scriptPubKey);
      } else {
        buffer.add(_varInt(0));
      }
      buffer.add(_uint32LE(input.sequence));
    }

    buffer.add(_varInt(tx.outputs.length));
    for (final output in tx.outputs) {
      buffer.add(_uint64LE(output.value));
      buffer.add(_varInt(output.scriptPubKey.length));
      buffer.add(output.scriptPubKey);
    }

    buffer.add(_uint32LE(tx.lockTime));
    buffer.add(_uint32LE(sighashAll));

    return buffer.toBytes();
  }


  Uint8List _sign(Uint8List privateKey, Uint8List messageHash) {
    final curve = ECCurve_secp256k1();
    final d = BigInt.parse(
      privateKey.map((e) => e.toRadixString(16).padLeft(2, '0')).join(),
      radix: 16,
    );
    final priv = ECPrivateKey(d, curve);

    final signer = ECDSASigner(null);
    final random = FortunaRandom();
    final seed = Uint8List.fromList(
      List.generate(32, (_) => Random.secure().nextInt(256)),
    );
    random.seed(KeyParameter(seed));
    signer.init(
      true,
      ParametersWithRandom(PrivateKeyParameter<ECPrivateKey>(priv), random),
    );
    final sig = signer.generateSignature(messageHash) as ECSignature;

    var r = sig.r;
    var s = sig.s;
    final n = curve.n;
    if (s > n! >> 1) {
      s = n - s;
    }

    return _encodeDer(r, s);
  }

  Uint8List _encodeDer(BigInt r, BigInt s) {
    Uint8List encodeInt(BigInt value) {
      final bytes = _bigIntToBytes(value);
      if (bytes.isNotEmpty && (bytes[0] & 0x80) != 0) {
        return Uint8List.fromList([0x00, ...bytes]);
      }
      return bytes;
    }

    final rBytes = encodeInt(r);
    final sBytes = encodeInt(s);
    final totalLength = 2 + rBytes.length + 2 + sBytes.length;

    return Uint8List.fromList([
      0x30,
      totalLength,
      0x02,
      rBytes.length,
      ...rBytes,
      0x02,
      sBytes.length,
      ...sBytes,
    ]);
  }

  Uint8List _buildScriptSig(
    Uint8List signatureWithType,
    Uint8List publicKey,
  ) {
    return Uint8List.fromList([
      ..._pushData(signatureWithType),
      ..._pushData(publicKey),
    ]);
  }

  Uint8List _pushData(Uint8List data) {
    final length = data.length;
    if (length < 0x4c) {
      return Uint8List.fromList([length, ...data]);
    }
    if (length <= 0xff) {
      return Uint8List.fromList([0x4c, length, ...data]);
    }
    if (length <= 0xffff) {
      final le = _uint16LE(length);
      return Uint8List.fromList([0x4d, ...le, ...data]);
    }
    final le = _uint32LE(length);
    return Uint8List.fromList([0x4e, ...le, ...data]);
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

  Uint8List _bigIntToBytes(BigInt value) {
    final hex = value.toRadixString(16);
    final normalized = hex.length.isOdd ? '0$hex' : hex;
    return Uint8List.fromList(
      List.generate(
        normalized.length ~/ 2,
        (i) => int.parse(
          normalized.substring(i * 2, i * 2 + 2),
          radix: 16,
        ),
      ),
    );
  }
}
