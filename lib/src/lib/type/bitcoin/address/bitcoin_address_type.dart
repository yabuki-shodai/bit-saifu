/// Bitcoinアドレスのタイプ
enum BitcoinAddressType {
  /// P2PKHアドレス
  /// 1から始まる
  /// 一番レガシーなアドレス
  p2pkh,

  /// P2SHアドレス
  /// 3から始まる
  p2sh,

  /// P2SH-P2WPKHアドレス
  /// 3から始まる
  p2shP2wpkh,

  /// P2WPKHアドレス
  /// bc1qから始まる
  p2wpkh,

  /// P2WSHアドレス
  /// bc1qから始まる
  p2wsh,

  /// P2TRアドレス
  /// bc1pから始まる
  p2tr,
}
