import 'package:bit_saifu/src/lib/bitcoin/data/repository.dart';
import 'package:bit_saifu/src/lib/secure/secure_key_store.dart';

class DeleteAddressUseCase {
  final BitcoinRepository bitcoinRepository;

  DeleteAddressUseCase({required this.bitcoinRepository});

  Future<void> execute(String address, List<String> addresses) async {
    // アドレスが存在するかを確認
    if (!addresses.contains(address)) {
      throw Exception('アドレスが存在しません');
    }
    // アドレスを削除
    await bitcoinRepository.deleteAddress(address, addresses);

    // プライベートキーが存在しているかを確認
    final secureKeyStore = SecureKeyStore();
    final privateKey = await secureKeyStore.loadPrivateKey(address);
    if (privateKey == null) {
      throw Exception('プライベートキーが存在しません');
    }

    // プライベートキーを削除
    await secureKeyStore.deletePrivateKey(
      address,
    );
  }
}
