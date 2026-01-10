import 'package:bit_saifu/src/lib/bitcoin/data/bitcoin_api.dart';
import 'package:bit_saifu/src/lib/bitcoin/domain/entity/utxo.dart';
import 'dart:typed_data';
import 'package:bit_saifu/src/lib/secure/secure_key_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BitcoinRepository {
  static const storageKey = 'bitcoin_addresses';

  Future<List<Utxo>> getUtxos(String address) async {
    final bitcoinClient = BlockstreamBitcoinClient();

    final dtos = await bitcoinClient.getUtxos(address);
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  Future<List<Utxo>> collectAllUtxos(List<String> addresses) async {
    final List<Utxo> all = [];

    for (final address in addresses) {
      final utxos = await getUtxos(address);
      all.addAll(utxos);
    }

    return all;
  }

  Future<List<String>> getAllAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(storageKey) ?? <String>[];
  }

  Future<void> saveAddresses(List<String> addresses) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(storageKey, addresses);
  }

  Future<void> savePrivateKey(String address, Uint8List privateKey) async {
    final secureKeyStore = SecureKeyStore();
    await secureKeyStore.savePrivateKey(address, privateKey);
  }

  Future<Uint8List?> loadPrivateKey(String address) async {
    final secureKeyStore = SecureKeyStore();
    return secureKeyStore.loadPrivateKey(address);
  }

  Future<void> deletePrivateKey(String address) async {
    final secureKeyStore = SecureKeyStore();
    await secureKeyStore.deletePrivateKey(address);
  }
}
