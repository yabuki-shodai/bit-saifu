import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FeeOption {
  final String label;
  final String description;
  final int satPerVByte;
  final IconData icon;

  const FeeOption({
    required this.label,
    required this.description,
    required this.satPerVByte,
    required this.icon,
  });
}

class SendTransactionInputView extends StatefulWidget {
  final int balanceSatoshi;
  final void Function({
    required String address,
    required int amountSatoshi,
    required int feeRate, // sat/vByte
  }) onSubmit;

  final void Function() onClose;

  const SendTransactionInputView({
    super.key,
    required this.balanceSatoshi,
    required this.onSubmit,
    required this.onClose,
  });

  @override
  State<SendTransactionInputView> createState() =>
      _SendTransactionInputViewState();
}

class _SendTransactionInputViewState extends State<SendTransactionInputView> {
  static const int satoshiPerBtc = 100000000;

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String? addressError;
  String? amountError;

  /// fee options
  final List<FeeOption> feeOptions = const [
    FeeOption(
      label: 'Fast',
      description: '~10 minutes',
      satPerVByte: 15,
      icon: Icons.flash_on,
    ),
    FeeOption(
      label: 'Normal',
      description: '~30 minutes',
      satPerVByte: 8,
      icon: Icons.trending_flat,
    ),
    FeeOption(
      label: 'Slow',
      description: '~1 hour',
      satPerVByte: 3,
      icon: Icons.schedule,
    ),
  ];

  late FeeOption selectedFee;

  @override
  void initState() {
    super.initState();
    selectedFee = feeOptions[1]; // Normal をデフォルト
  }

  double get balanceBtc => widget.balanceSatoshi / satoshiPerBtc;

  int _btcToSatoshi(String value) {
    final btc = double.tryParse(value) ?? 0;
    return (btc * satoshiPerBtc).round();
  }

  bool _isValidBitcoinAddress(String value) {
    return value.startsWith('m') ||
        value.startsWith('n') ||
        value.startsWith('tb1');
  }

  void _onMax() {
    _amountController.text = balanceBtc.toStringAsFixed(8);
    setState(() => amountError = null);
  }

  void _onContinue() {
    final address = _addressController.text.trim();
    final satoshi = _btcToSatoshi(_amountController.text);

    bool hasError = false;

    if (address.isEmpty) {
      addressError = '送金先アドレスを入力してください';
      hasError = true;
    } else if (!_isValidBitcoinAddress(address)) {
      addressError = '無効なビットコインアドレスです';
      hasError = true;
    } else {
      addressError = null;
    }

    if (satoshi <= 0) {
      amountError = '送金額を入力してください';
      hasError = true;
    } else if (satoshi > widget.balanceSatoshi) {
      amountError = '残高が不足しています';
      hasError = true;
    } else {
      amountError = null;
    }

    setState(() {});

    if (hasError) return;

    widget.onSubmit(
      address: address,
      amountSatoshi: satoshi,
      feeRate: selectedFee.satPerVByte,
    );
  }

  Widget _buildFeeCard(FeeOption option) {
    final isSelected = option == selectedFee;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        setState(() {
          selectedFee = option;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              option.icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    option.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${option.satPerVByte} sat/vB',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Send Bitcoin',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 24),

            /// Address
            const Text('To (Bitcoin Address)',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              maxLines: 1,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],
              decoration: InputDecoration(
                hintText: 'tb1q...',
                errorText: addressError,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// Amount
            const Text('Amount (BTC)',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,8}$')),
              ],
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: '0.00000000',
                suffixText: 'BTC',
                errorText: amountError,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available: ${balanceBtc.toStringAsFixed(8)} BTC',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                TextButton(onPressed: _onMax, child: const Text('MAX')),
              ],
            ),

            const SizedBox(height: 24),

            /// Fee selection
            const Text(
              'Fee',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            Column(
              children: feeOptions
                  .map((option) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildFeeCard(option),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _onContinue,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 6),
            Center(
              child: TextButton(
                onPressed: widget.onClose,
                child: const Text('閉じる'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
