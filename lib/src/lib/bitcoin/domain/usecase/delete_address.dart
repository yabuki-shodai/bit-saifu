import 'package:bit_saifu/src/lib/bitcoin/data/repository.dart';
import 'package:bit_saifu/src/lib/core/private_key/repository.dart';

class DeleteAddressUseCase {
  final BitcoinRepository bitcoinRepository;
  final PrivateKeyRepository privateKeyRepository;

  DeleteAddressUseCase({
    required this.bitcoinRepository,
    required this.privateKeyRepository,
  });

  Future<List<String>> execute(String address) async {
    final addresses = await bitcoinRepository.getAllAddresses();

    // アドレスが存在するかを確認
    if (!addresses.contains(address)) {
      throw Exception('アドレスが存在しません');
    }

    addresses.remove(address);

    // アドレスを削除
    await bitcoinRepository.saveAddresses(addresses);

    // プライベートキーが存在しているかを確認
    final privateKey = await privateKeyRepository.loadPrivateKey(address);
    if (privateKey == null) {
      throw Exception('プライベートキーが存在しません');
    }

    // プライベートキーを削除
    await privateKeyRepository.deletePrivateKey(address);

    return addresses;
  }
}
