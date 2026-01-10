import 'dart:typed_data';
import 'package:bit_saifu/src/lib/bitcoin/crypto/bitcoin.dart';
import 'package:bit_saifu/src/lib/bitcoin/data/repository.dart';
import 'package:bit_saifu/src/lib/bitcoin/domain/entity/utxo.dart';

const int satoshiPerBtc = 100000000;

class BitcoinService {
  final BitcoinRepository repository;
  final BitcoinCrypto crypto;

  BitcoinService({
    BitcoinRepository? repository,
    BitcoinCrypto? crypto,
  })  : repository = repository ?? BitcoinRepository(),
        crypto = crypto ?? BitcoinCrypto();

  Future<List<String>> loadAddresses() async {
    return repository.getAllAddresses();
  }

  Future<List<String>> createAddress() async {
    final privateKey = crypto.generatePrivateKey();
    final publicKey = crypto.privateKeyToPublicKey(privateKey);
    final address = crypto.publicKeyToAddress(publicKey);

    final addresses = await repository.getAllAddresses();
    if (addresses.contains(address)) {
      throw Exception('アドレスがすでに存在します');
    }

    addresses.add(address);
    await repository.saveAddresses(addresses);
    await repository.savePrivateKey(address, privateKey);

    return addresses;
  }

  Future<List<String>> deleteAddress(String address) async {
    final addresses = await repository.getAllAddresses();
    if (!addresses.contains(address)) {
      throw Exception('アドレスが存在しません');
    }

    addresses.remove(address);
    await repository.saveAddresses(addresses);
    await repository.deletePrivateKey(address);

    return addresses;
  }

  Future<Uint8List?> loadPrivateKey(String address) async {
    return repository.loadPrivateKey(address);
  }

  Future<List<Utxo>> getUtxos(String address) async {
    return repository.getUtxos(address);
  }

  Future<List<Utxo>> collectAllUtxos(List<String> addresses) async {
    return repository.collectAllUtxos(addresses);
  }

  double calcBalance(List<Utxo> utxos) {
    final balance = utxos.fold(0, (sum, u) => sum + u.value);
    return balance / satoshiPerBtc;
  }

  UtxoSelectionResult selectUtxos({
    required List<Utxo> utxos,
    required int sendAmountSatoshi,
    required int feeRate, // sat / vByte
  }) {
    final available = utxos.where((u) => u.confirmed).toList();
    available.sort((a, b) => b.value.compareTo(a.value));

    final List<Utxo> selected = [];
    int totalInput = 0;

    for (final utxo in available) {
      selected.add(utxo);
      totalInput += utxo.value;

      final inputCount = selected.length;
      const outputCount = 2;

      final txSize = _estimateTxSize(
        inputCount: inputCount,
        outputCount: outputCount,
      );

      final fee = txSize * feeRate;

      if (totalInput >= sendAmountSatoshi + fee) {
        int change = totalInput - sendAmountSatoshi - fee;
        if (change < 546) {
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
