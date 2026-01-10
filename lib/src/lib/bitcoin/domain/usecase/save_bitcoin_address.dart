import 'dart:typed_data';
import 'package:bit_saifu/src/lib/bitcoin/data/repository.dart';
import 'package:bit_saifu/src/lib/core/private_key/repository.dart';

class SaveBitcoinAddressAndPrivateKeyUseCase {
  final BitcoinRepository bitcoinRepository;
  final PrivateKeyRepository privateKeyRepository;
  SaveBitcoinAddressAndPrivateKeyUseCase(
      {required this.bitcoinRepository, required this.privateKeyRepository});

  Future<List<String>> execute(String address, Uint8List privateKey) async {
    // アドレスがすでに存在するかを確認
    final addresses = await bitcoinRepository.getAllAddresses();
    if (addresses.contains(address)) {
      throw Exception('アドレスがすでに存在します');
    }

    // アドレスを保存
    addresses.add(address);
    await bitcoinRepository.saveAddresses(addresses);

    // 秘密鍵を保存
    await privateKeyRepository.savePrivateKey(address, privateKey);

    return addresses;
  }
}
