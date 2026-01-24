# Bitcoinモジュール

役割ごとに4つへ分けています。
- crypto: 鍵とアドレス
- data: 取得と変換
- service: まとめ役
- domain: データモデル

## crypto/
役割: 鍵生成とアドレス変換。

### lib/src/lib/bitcoin/crypto/bitcoin.dart
役割: 秘密鍵・公開鍵・アドレスの生成
- BitcoinCrypto.generatePrivateKey() // 32byteの秘密鍵を生成
- BitcoinCrypto.privateKeyToPublicKey() // secp256k1で公開鍵へ変換
- BitcoinCrypto.publicKeyToAddress() // 公開鍵からBase58Checkアドレスを生成
- BitcoinCrypto._bigIntToBytes() (private) // BigIntを固定長バイト列へ変換

## domain/
役割: UTXOと選択結果のデータモデル。

### lib/src/lib/bitcoin/domain/entity/utxo.dart
役割: UTXOと選択結果のデータモデル
- 関数なし（データ保持のみ）

## data/
役割: 外部API、DTO、Repository。

### lib/src/lib/bitcoin/data/bitcoin_api.dart
役割: UTXO取得APIの抽象と実装
- BitcoinApi.getUtxos() // UTXO取得の抽象インターフェース
- BlockstreamBitcoinClient.getUtxos() // Blockstream APIからUTXO取得

### lib/src/lib/bitcoin/data/dto/utxo_dto.dart
役割: APIレスポンス用のDTO
- UtxoDto.fromJson() // APIレスポンスをDTOへ変換
- UtxoDto.toEntity() // DTOをdomain entityへ変換

### lib/src/lib/bitcoin/data/repository.dart
役割: 取得・保存の窓口（APIとストレージの橋渡し）
- BitcoinRepository.getUtxos() // API結果をentityへ変換して返す
- BitcoinRepository.collectAllUtxos() // 複数アドレスのUTXOを集約
- BitcoinRepository.getAllAddresses() // 保存済みアドレス一覧の取得
- BitcoinRepository.saveAddresses() // アドレス一覧を保存
- BitcoinRepository.savePrivateKey() // 秘密鍵を保存
- BitcoinRepository.loadPrivateKey() // 秘密鍵を読み込み
- BitcoinRepository.deletePrivateKey() // 秘密鍵を削除

## service/
役割: UIから呼ぶまとめ役。

### lib/src/lib/bitcoin/service/bitcoin_service.dart
役割: アドレス管理とUTXO処理をまとめる
- BitcoinService.loadAddresses() // アドレス一覧の取得
- BitcoinService.createAddress() // 生成して保存
- BitcoinService.deleteAddress() // 削除して保存
- BitcoinService.loadPrivateKey() // 秘密鍵を取得
- BitcoinService.getUtxos() // UTXO取得
- BitcoinService.collectAllUtxos() // 複数アドレスのUTXOを集約
- BitcoinService.calcBalance() // satoshi合計をBTCへ換算
- BitcoinService.selectUtxos() // 送金額と手数料を満たすUTXOを選択
