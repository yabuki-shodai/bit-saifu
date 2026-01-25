import 'package:bit_saifu/src/lib/models/bitcoin/bitcoin_entity.dart';
import 'package:bit_saifu/src/lib/type/bitcoin/bitcoin.dart';

abstract class BitcoinServiceBase {
  /// 保存しているアドレスを取得
  Future<List<BitcoinEntity>> loadAddresses();

  // ビットコインアドレスを生成して保存
  Future<BitcoinEntity> generateAddress({required BitcoinAddressType type});

  /// ビットコインアドレスを削除
  Future<void> deleteAddress({required BitcoinEntity bitcoinEntity});

  /// ビットコインアドレスに紐づくUTXOを取得
  Future<List<BitcoinUtxo>> getUtxos({required BitcoinEntity bitcoinEntity});

  /// ビットコインを送金
  Future<void> sendBitcoin(
      {required BitcoinEntity fromAddress,
      required String toAddress,
      required int amount,
      required int feeRate,
      String? changeAddress});
}
