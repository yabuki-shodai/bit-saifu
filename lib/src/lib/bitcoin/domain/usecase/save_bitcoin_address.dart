import 'package:bit_saifu/src/lib/bitcoin/data/repository.dart';
import 'dart:typed_data';

class SaveBitcoinAddressAndPrivateKeyUseCase {
  final BitcoinRepository bitcoinRepository;

  SaveBitcoinAddressAndPrivateKeyUseCase({required this.bitcoinRepository});

  Future<void> execute(String address, Uint8List privateKey) async {
    // アドレスがすでに存在するかを確認
    final addresses = await bitcoinRepository.getAllAddresses();
    if (addresses.contains(address)) {
      throw Exception('アドレスがすでに存在します');
    }

    // アドレスを保存
    addresses.add(address);

    // 秘密鍵を安全に保存
    await bitcoinRepository.savePrivateKey(address, privateKey);

    // アドレスを保存
    await bitcoinRepository.saveAddresses(addresses);
  }
}
