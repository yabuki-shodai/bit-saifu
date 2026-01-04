import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bit_saifu/src/lib/bitcoin.dart';


class BitcoinPage extends StatefulWidget {
  const BitcoinPage({super.key});

  @override
  State<BitcoinPage> createState() => _BitcoinPageState();
}

class _BitcoinPageState extends State<BitcoinPage> {
  static const storageKey = 'bitcoin_addresses';

  List<String> addresses = [];

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  /// 保存済みアドレスを読み込む
  Future<void> _loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      addresses = prefs.getStringList(storageKey) ?? [];
    });
  }

  /// アドレスを保存
  Future<void> _saveAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(storageKey, addresses);
  }

  /// 新しいアドレス生成
  void generateAddress() {
    final privateKey = BitcoinKeyGenerator.generatePrivateKey();
    final publicKey = BitcoinKeyGenerator.privateKeyToPublicKey(privateKey);
    final address = BitcoinKeyGenerator.publicKeyToAddressTestnet(publicKey);

    setState(() {
      addresses.insert(0, address);
    });

    _saveAddresses();
  }

  /// アドレス削除
  void deleteAddress(int index) {
    setState(() {
      addresses.removeAt(index);
    });
    _saveAddresses();
  }

  /// Explorerを開く
  Future<void> openExplorer(String address) async {
    final url = Uri.parse(
      'https://www.blockchain.com/explorer/search?search=$address',
    );
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bitcoin Address Generator (Testnet)'),
      ),

      /// ✅ 生成ボタン
      floatingActionButton: FloatingActionButton(
        onPressed: generateAddress,
        child: const Icon(Icons.add),
      ),

      body: addresses.isEmpty
          ? const Center(
              child: Text('まだアドレスがありません'),
            )
          : ListView.builder(
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];

                return Dismissible(
                  key: ValueKey(address),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => deleteAddress(index),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.account_balance_wallet),
                    title: Text(
                      address,
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: const Text('Tap to open explorer'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => deleteAddress(index),
                    ),
                    onTap: () => openExplorer(address),
                  ),
                );
              },
            ),
    );
  }
}
