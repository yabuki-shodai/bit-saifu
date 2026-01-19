import 'dart:typed_data';
import 'package:bit_saifu/src/lib/bitcoin/crypto/bitcoin.dart';
import 'package:bit_saifu/src/lib/bitcoin/crypto/bitcoin_address_detector.dart';
import 'package:bit_saifu/src/lib/bitcoin/crypto/bitcoin_signer.dart';
import 'package:bit_saifu/src/lib/bitcoin/crypto/bitcoin_transaction.dart';
import 'package:bit_saifu/src/lib/bitcoin/crypto/bitcoin_transaction_serializer.dart';
import 'package:bit_saifu/src/lib/bitcoin/data/repository.dart';
import 'package:bit_saifu/src/lib/bitcoin/domain/entity/transaction.dart';
import 'package:bit_saifu/src/lib/bitcoin/domain/entity/tx_output.dart';
import 'package:bit_saifu/src/lib/bitcoin/domain/entity/utxo.dart';

const int satoshiPerBtc = 100000000;

class BitcoinService {
  final BitcoinRepository repository;
  final BitcoinCrypto crypto;
  final BitcoinSigner signer;
  final BitcoinTransactionSerializer serializer;

  BitcoinService({
    BitcoinRepository? repository,
    BitcoinCrypto? crypto,
    BitcoinSigner? signer,
    BitcoinTransactionSerializer? serializer,
  })  : repository = repository ?? BitcoinRepository(),
        crypto = crypto ?? BitcoinCrypto(),
        signer = signer ?? BitcoinSigner(),
        serializer = serializer ?? BitcoinTransactionSerializer();

  // 保存済みアドレス一覧を取得
  Future<List<String>> loadAddresses() async {
    return repository.getAllAddresses();
  }

  // 新しいアドレスを生成して保存
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

  // アドレスを削除して保存
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

  // アドレスに紐づく秘密鍵を取得
  Future<Uint8List?> loadPrivateKey(String address) async {
    return repository.loadPrivateKey(address);
  }

  // アドレスに紐づくUTXOを取得
  Future<List<Utxo>> getUtxos(String address) async {
    try {
      return repository.getUtxos(address);
    } catch (e) {
      return [];
    }
  }

  /// 複数アドレスのUTXOを集約
  Future<List<Utxo>> collectAllUtxos(List<String> addresses) async {
    return repository.collectAllUtxos(addresses);
  }

  // UTXOのsatoshi合計をBTCへ換算
  double calcBalance(List<Utxo> utxos) {
    final balance = utxos.fold(0, (sum, u) => sum + u.value);
    return balance / satoshiPerBtc;
  }

  // 送金可能な最大額を推定
  Future<int> estimateMaxSendable({
    required String fromAddress,
    required int feeRate,
  }) async {
    final normalizedFrom = _normalizeAddress(fromAddress);
    _ensureP2pkhAddress(normalizedFrom);

    final utxos = await getUtxos(normalizedFrom);
    final confirmed = utxos.where((u) => u.confirmed).toList();
    if (confirmed.isEmpty) {
      throw Exception('使用可能なUTXOがありません');
    }

    final totalInput = confirmed.fold<int>(0, (sum, u) => sum + u.value);
    final fee = _estimateTxSize(
          inputCount: confirmed.length,
          outputCount: 1,
        ) *
        feeRate;
    final max = totalInput - fee;
    if (max < 546) {
      throw Exception('送金額が小さすぎます');
    }

    return max;
  }

  /// 送金額と手数料を満たすUTXOを選択
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

  /// トランザクションサイズを推定
  int _estimateTxSize({
    required int inputCount,
    required int outputCount,
  }) {
    return 10 + (148 * inputCount) + (34 * outputCount);
  }

  /// P2PKHアドレスのトランザクションをビルド
  Future<Transaction> buildUnsignedP2pkhTransaction({
    required String fromAddress,
    required String toAddress,
    required int amountSatoshi,
    required int feeRate,
    String? changeAddress,
  }) async {
    final (transaction, _) = await _buildUnsignedP2pkhTransactionWithSelection(
      fromAddress: fromAddress,
      toAddress: toAddress,
      amountSatoshi: amountSatoshi,
      feeRate: feeRate,
      changeAddress: changeAddress,
    );

    return transaction;
  }

  /// P2PKHアドレスのトランザクションをビルド
  Future<(Transaction transaction, List<Utxo> selectedUtxos)>
      _buildUnsignedP2pkhTransactionWithSelection({
    required String fromAddress,
    required String toAddress,
    required int amountSatoshi,
    required int feeRate,
    String? changeAddress,
  }) async {
    if (amountSatoshi < 546) {
      throw Exception('送金額が小さすぎます');
    }
    final normalizedFrom = _normalizeAddress(fromAddress);
    final normalizedTo = _normalizeAddress(toAddress);
    final normalizedChange =
        changeAddress == null ? null : _normalizeAddress(changeAddress);

    _ensureP2pkhAddress(normalizedFrom);
    _ensureP2pkhAddress(normalizedTo);
    if (normalizedChange != null) {
      _ensureP2pkhAddress(normalizedChange);
    }

    final utxos = await getUtxos(normalizedFrom);
    final result = selectUtxos(
      utxos: utxos,
      sendAmountSatoshi: amountSatoshi,
      feeRate: feeRate,
    );

    final inputs = result.selectedUtxos
        .map((utxo) => TransactionBuilder().utxoToInput(utxo))
        .toList();

    final outputs = <TxOutput>[
      TxOutput(
        value: amountSatoshi,
        scriptPubKey: crypto.addressToScriptPubKey(normalizedTo),
      ),
    ];

    final change = result.change;
    if (change > 0) {
      final changeTo = normalizedChange ?? normalizedFrom;
      outputs.add(
        TxOutput(
          value: change,
          scriptPubKey: crypto.addressToScriptPubKey(changeTo),
        ),
      );
    }

    return (
      Transaction(inputs: inputs, outputs: outputs),
      result.selectedUtxos
    );
  }

  /// P2PKHアドレスかどうかを確認
  void _ensureP2pkhAddress(String address) {
    final type = BitcoinAddressDetector.detect(address);
    if (type != BitcoinAddressType.p2pkh) {
      throw Exception('未対応のアドレスです');
    }
  }

  /// アドレスを正規化
  String _normalizeAddress(String address) {
    final normalized = address.trim();
    if (normalized.isEmpty) {
      throw Exception('未対応のアドレスです');
    }
    return normalized;
  }

  /// P2PKHアドレスのトランザクションを署名
  Transaction signP2pkh(
    Transaction transaction,
    List<P2pkhInputSigningData> inputs,
  ) {
    return signer.signP2pkhTransaction(transaction, inputs);
  }

  /// トランザクションをバイト列へ変換
  Uint8List buildRawTransaction(Transaction transaction) {
    return serializer.serialize(transaction);
  }

  /// トランザクションをバイト列へ変換
  String buildRawTransactionHex(Transaction transaction) {
    return serializer.toHex(transaction);
  }

  /// P2PKHアドレスのトランザクションを送信
  Future<String> sendP2pkhTransaction({
    required String fromAddress,
    required String toAddress,
    required int amountSatoshi,
    required int feeRate,
    String? changeAddress,
  }) async {
    final normalizedFrom = _normalizeAddress(fromAddress);
    final normalizedTo = _normalizeAddress(toAddress);
    final normalizedChange =
        changeAddress == null ? null : _normalizeAddress(changeAddress);

    _ensureP2pkhAddress(normalizedFrom);
    _ensureP2pkhAddress(normalizedTo);
    if (normalizedChange != null) {
      _ensureP2pkhAddress(normalizedChange);
    }

    final (unsignedTx, selectedUtxos) =
        await _buildUnsignedP2pkhTransactionWithSelection(
      fromAddress: normalizedFrom,
      toAddress: normalizedTo,
      amountSatoshi: amountSatoshi,
      feeRate: feeRate,
      changeAddress: normalizedChange,
    );

    final privateKey = await loadPrivateKey(normalizedFrom);
    if (privateKey == null) {
      throw Exception('秘密鍵が見つかりません');
    }

    final signingInputs = <P2pkhInputSigningData>[];
    for (int i = 0; i < selectedUtxos.length; i++) {
      signingInputs.add(
        P2pkhInputSigningData(
          inputIndex: i,
          utxo: selectedUtxos[i],
          privateKey: privateKey,
        ),
      );
    }

    final signedTx = signP2pkh(unsignedTx, signingInputs);
    final rawHex = buildRawTransactionHex(signedTx);

    return repository.broadcastTransaction(rawHex);
  }
}
