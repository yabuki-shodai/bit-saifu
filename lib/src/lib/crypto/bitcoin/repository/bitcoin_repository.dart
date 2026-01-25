import 'dart:convert';

import 'package:bit_saifu/src/lib/models/bitcoin/bitcoin_entity.dart';
import 'package:bit_saifu/src/lib/type/bitcoin/bitcoin.dart';
import 'package:hive/hive.dart';

abstract class BitcoinRepositoryBase {
  /// UTXOを取得
  Future<List<BitcoinUtxo>> getUtxos(String address);

  /// ビットコインエンティティを取得
  Future<List<BitcoinEntity>> getBitcoinEntities();

  /// ビットコインエンティティを保存
  Future<void> saveBitcoinEntity(BitcoinEntity bitcoinEntity);

  /// ビットコインエンティティを削除
  Future<void> deleteBitcoinEntity(BitcoinEntity bitcoinEntity);
}

class BitcoinRepository implements BitcoinRepositoryBase {
  static const String boxName = 'bitcoin_entities';
  final Box<String> _box;

  BitcoinRepository(this._box);

  @override
  Future<void> deleteBitcoinEntity(BitcoinEntity bitcoinEntity) {
    return _box.delete(bitcoinEntity.address);
  }

  @override
  Future<List<BitcoinEntity>> getBitcoinEntities() async {
    return _box.values
        .map((value) => BitcoinEntity.fromJson(
              jsonDecode(value) as Map<String, dynamic>,
            ))
        .toList();
  }

  @override
  Future<List<BitcoinUtxo>> getUtxos(String address) {
    return Future.value([]);
  }

  @override
  Future<void> saveBitcoinEntity(BitcoinEntity bitcoinEntity) async {
    final json = jsonEncode(bitcoinEntity.toJson());
    await _box.put(bitcoinEntity.address, json);
  }
}
