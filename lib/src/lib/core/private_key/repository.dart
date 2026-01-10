import 'dart:typed_data';
import 'package:bit_saifu/src/lib/secure/secure_key_store.dart';

class PrivateKeyRepository {
  final SecureKeyStore secureKeyStore;

  PrivateKeyRepository({required this.secureKeyStore});

  Future<void> savePrivateKey(String address, Uint8List privateKey) async {
    await secureKeyStore.savePrivateKey(address, privateKey);
  }

  Future<Uint8List?> loadPrivateKey(String address) async {
    return await secureKeyStore.loadPrivateKey(address);
  }

  Future<void> deletePrivateKey(String address) async {
    await secureKeyStore.deletePrivateKey(address);
  }
}
