import 'package:bit_saifu/src/lib/bitcoin/data/repository.dart';
import 'package:bit_saifu/src/lib/secure/secure_key_store.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:bit_saifu/src/components/common/send_transaction_input_view.dart';
import 'package:bit_saifu/src/lib/bitcoin/crypto/bitcoin.dart';
import 'package:bit_saifu/src/lib/bitcoin/domain/usecase/usecase.dart';
import 'package:bit_saifu/src/lib/core/private_key/repository.dart';

class BitcoinPage extends StatefulWidget {
  const BitcoinPage({super.key});

  @override
  State<BitcoinPage> createState() => _BitcoinPageState();
}

class _BitcoinPageState extends State<BitcoinPage> {
  List<String> addresses = [];
  final BitcoinRepository _bitcoinRepository = BitcoinRepository();
  final CalcBalanceUseCase _calcBalance = CalcBalanceUseCase();
  final SelectUtxoUseCase _selectUtxo = SelectUtxoUseCase();
  final PrivateKeyRepository _privateKeyRepository =
      PrivateKeyRepository(secureKeyStore: SecureKeyStore());
  final BitcoinCrypto _bitcoinCrypto = BitcoinCrypto();

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  /// 保存済みアドレスを読み込む
  Future<void> _loadAddresses() async {
    final items = await _bitcoinRepository.getAllAddresses();
    if (!mounted) return;
    setState(() {
      addresses = items;
    });
  }

  /// 新しいアドレス生成
  void generateAddress() async {
    final createUseCase =
        CreateBitcoinAddressUseCase(bitcoinCrypto: _bitcoinCrypto);
    final (address, privateKey, _) = createUseCase.execute();

    final saveUseCase = SaveBitcoinAddressAndPrivateKeyUseCase(
      bitcoinRepository: _bitcoinRepository,
      privateKeyRepository: _privateKeyRepository,
    );

    final updated = await saveUseCase.execute(address, privateKey);
    if (!mounted) return;
    setState(() {
      addresses = updated;
    });
  }

  /// アドレス削除
  void deleteAddress(String address) async {
    final deleteUseCase = DeleteAddressUseCase(
      bitcoinRepository: _bitcoinRepository,
      privateKeyRepository: _privateKeyRepository,
    );

    final updated = await deleteUseCase.execute(address);
    if (!mounted) return;
    setState(() {
      addresses = updated;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('アドレスを削除しました')),
    );
  }

  /// Explorerを開く
  Future<void> openExplorer(String address) async {
    final url = Uri.parse(
        // 'https://www.blockchain.com/explorer/search?search=$address',
        "https://blockstream.info/testnet/address/$address");
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  void showSendViewBottomSheet(String address, double balance) {
    final balanceSatoshi = (balance * satoshiPerBtc).toInt();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            top: false,
            child: SendTransactionInputView(
              balanceSatoshi: balanceSatoshi,
              onClose: () => Navigator.of(context).pop(),
              onSubmit: (
                  {required address,
                  required amountSatoshi,
                  required feeRate}) async {
                Navigator.pop(context);
                debugPrint('To: $address');
                debugPrint('Amount: $amountSatoshi satoshi');
                debugPrint('Fee Rate: $feeRate sat/vByte');
                final allUtxos =
                    await _bitcoinRepository.collectAllUtxos(addresses);

                final result = _selectUtxo.execute(
                  utxos: allUtxos,
                  sendAmountSatoshi: amountSatoshi,
                  feeRate: 5, // 例：5 sat/vByte
                );

                debugPrint('Inputs: ${result.selectedUtxos.length}');
                debugPrint('Fee: ${result.fee} sat');
                debugPrint('Change: ${result.change} sat');
                debugPrint('TxSize: ${result.txSize} vB');
              },
            ),
          ),
        );
      },
    );
  }

  // QRコードを表示するダイアログ
  void showQrDialog(String address) async {
    final utxos = await _bitcoinRepository.getUtxos(address);
    final balance = _calcBalance.execute(utxos);
    if (!mounted) return;
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
              // メインコンテンツ
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Receive Bitcoin',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    // 残高を表示
                    Text(
                      'Balance: $balance BTC',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 16),
                    // QRコード
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
                        label: const Text('Explorerを開く'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          openExplorer(address);
                        },
                      ),
                    ),

                    // utxoを表示
                    const SizedBox(height: 16),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'UTXO',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: utxos.length,
                      itemBuilder: (context, index) {
                        final utxo = utxos[index];
                        final btcValue = _calcBalance.execute([utxo]);

                        return Card(
                          elevation: 1,
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Amount: $btcValue BTC',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'txid: ${utxo.txid}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  'vout: ${utxo.vout}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('閉じる'),
                    ),
                  ],
                ),
              ),

              // 左上の削除ボタン
              Positioned(
                top: 8,
                left: 8,
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

              // 右上の送金ボタン
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  tooltip: '送金',
                  icon: Icon(
                    Icons.send,
                    color: Colors.blue.shade400,
                  ),
                  onPressed: () {
                    showSendViewBottomSheet(address, balance);
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
                Navigator.of(context).pop(); // confirm dialog
                Navigator.of(context).pop(); // QR dialog
                deleteAddress(address);
              },
              child: const Text('削除'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> isCheckPrivateKey(String address) async {
    final secureKeyStore = SecureKeyStore();
    final key = await secureKeyStore.loadPrivateKey(address);
    return key != null;
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
                  'Bitcoin Wallet',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Receive addresses Testnet',
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
