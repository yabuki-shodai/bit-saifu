import 'dart:io';

import 'package:bit_saifu/src/lib/crypto/bitcoin/repository/bitcoin_repository.dart';
import 'package:bit_saifu/src/lib/models/bitcoin/bitcoin_entity.dart';
import 'package:bit_saifu/src/lib/type/bitcoin/address/bitcoin_address_type.dart';
import 'package:bit_saifu/src/lib/type/network/crypto_network.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  const boxName = 'bitcoin_entities_test';
  late Directory tempDir;
  late Box<String> box;
  late BitcoinRepository repository;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);
  });

  setUp(() async {
    box = await Hive.openBox<String>(boxName);
    await box.clear();
    repository = BitcoinRepository(box);
  });

  tearDown(() async {
    await box.close();
  });

  tearDownAll(() async {
    await Hive.deleteBoxFromDisk(boxName);
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  BitcoinEntity buildEntity({
    required String address,
    required String publicKey,
  }) {
    return BitcoinEntity(
      address: address,
      publicKey: publicKey,
      type: BitcoinAddressType.p2pkh,
      network: CryptoNetwork.testnet,
    );
  }

  group('BitcoinRepository', () {
    test('saveBitcoinEntity and getBitcoinEntities', () async {
      final entity = buildEntity(
        address: 'addr1',
        publicKey: 'pub1',
      );

      await repository.saveBitcoinEntity(entity);

      final entities = await repository.getBitcoinEntities();
      expect(entities, contains(entity));
    });

    test('deleteBitcoinEntity removes stored entry', () async {
      final first = buildEntity(
        address: 'addr1',
        publicKey: 'pub1',
      );
      final second = buildEntity(
        address: 'addr2',
        publicKey: 'pub2',
      );

      await repository.saveBitcoinEntity(first);
      await repository.saveBitcoinEntity(second);
      await repository.deleteBitcoinEntity(first);

      final entities = await repository.getBitcoinEntities();
      expect(entities.length, 1);
      expect(entities.first, second);
    });
  });
}
