import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:bit_saifu/src/lib/ethereum/ethereum.dart';

class EthereumPage extends StatefulWidget {
  const EthereumPage({super.key});

  @override
  State<EthereumPage> createState() => _EthereumPageState();
}

class _EthereumPageState extends State<EthereumPage> {
  static const storageKey = 'ethereum_addresses';

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

  /// 新しいEthereumアドレス生成
  void generateAddress() {
    final privateKey = EthereumKeyGenerator.generatePrivateKey();
    final publicKey = EthereumKeyGenerator.privateKeyToPublicKey(privateKey);
    final address = EthereumKeyGenerator.publicKeyToAddress(publicKey);

    setState(() {
      addresses.add(address);
    });

    _saveAddresses();
  }

  /// アドレス削除
  void deleteAddress(String address) {
    setState(() {
      addresses.removeWhere((e) => e == address);
    });
    _saveAddresses();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('アドレスを削除しました')),
    );
  }

  /// Etherscan を開く
  Future<void> openExplorer(String address) async {
    final url = Uri.parse(
      // 'https://etherscan.io/address/$address',
      'https://sepolia.etherscan.io/address/$address',
    );
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  /// QRコードダイアログ
  void showQrDialog(String address) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Receive Ethereum',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // QR
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: PrettyQrView.data(
                          data: address,
                          decoration: const PrettyQrDecoration(
                            shape: PrettyQrSmoothSymbol(
                              roundFactor: 0.6,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    SelectableText(
                      address,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Etherscanを開く'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          openExplorer(address);
                        },
                      ),
                    ),

                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('閉じる'),
                    ),
                  ],
                ),
              ),

              // 削除ボタン
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  tooltip: '削除',
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red.shade400,
                  ),
                  onPressed: () {
                    showDeleteConfirmDialog(address);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showDeleteConfirmDialog(String address) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('アドレスを削除しますか？'),
          content: const Text(
            'この操作は取り消せません。',
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.of(context).pop(); // confirm
                Navigator.of(context).pop(); // qr
                deleteAddress(address);
              },
              child: const Text('削除'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          flexibleSpace: const Padding(
            padding: EdgeInsets.fromLTRB(16, 48, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ethereum Wallet',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Receive addresses Sepolia',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: generateAddress,
        icon: const Icon(Icons.add),
        label: const Text('新しいアドレス'),
      ),
      body: addresses.isEmpty
          ? const Center(
              child: Text(
                'まだアドレスがありません',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];

                return Dismissible(
                  key: ValueKey(address),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => deleteAddress(address),
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => showQrDialog(address),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.account_balance_wallet,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                address,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Icon(Icons.qr_code),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
