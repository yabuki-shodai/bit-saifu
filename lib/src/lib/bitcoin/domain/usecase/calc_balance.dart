import 'package:bit_saifu/src/lib/bitcoin/domain/entity/utxo.dart';

const int satoshiPerBtc = 100000000;

class CalcBalanceUseCase {
  double execute(List<Utxo> utxos) {
    final balance = utxos.fold(0, (sum, u) => sum + u.value);
    return balance / satoshiPerBtc;
  }
}
