# Bitcoinモジュール

役割ごとに3つへ分けています。
- crypto: 鍵とアドレス
- domain: ルールと計算
- data: 取得と変換

## crypto/
役割: 鍵生成とアドレス変換。

### lib/src/lib/bitcoin/crypto/key_generator.dart
役割: 秘密鍵/公開鍵の生成と変換
- BitcoinKeyGenerator.generatePrivateKey() // 32byteの秘密鍵を生成
- BitcoinKeyGenerator.privateKeyToPublicKey() // secp256k1で公開鍵へ変換
- BitcoinKeyGenerator._bigIntToBytes() (private) // BigIntを固定長バイト列へ変換

### lib/src/lib/bitcoin/crypto/address.dart
役割: 公開鍵からアドレス生成
- publicKeyToAddress() // 公開鍵からBase58Checkアドレスを生成

## domain/
役割: UTXOと計算ロジック。

### lib/src/lib/bitcoin/domain/entity/utxo.dart
役割: UTXOと選択結果のデータモデル
- 関数なし（データ保持のみ）

### lib/src/lib/bitcoin/domain/usecase/calc_balance.dart
役割: 残高計算
- CalcBalanceUseCase.call() // satoshi合計をBTCへ換算

### lib/src/lib/bitcoin/domain/usecase/select_utxo.dart
役割: UTXO選択と手数料計算
- SelectUtxoUseCase.call() // 送金額と手数料を満たすUTXOを選択
- SelectUtxoUseCase._estimateTxSize() (private) // 入出力数からTxサイズ推定

## data/
役割: 外部API、DTO、Repository。

### lib/src/lib/bitcoin/data/bitcoin_api.dart
役割: UTXO取得APIの抽象と実装
- BitcoinApi.getUtxos() // UTXO取得の抽象インターフェース
- BlockstreamBitcoinApi.getUtxos() // Blockstream APIからUTXO取得

### lib/src/lib/bitcoin/data/dto/utxo_dto.dart
役割: APIレスポンス用のDTO
- UtxoDto.fromJson() // APIレスポンスをDTOへ変換
- UtxoDto.toEntity() // DTOをdomain entityへ変換

### lib/src/lib/bitcoin/data/repository.dart
役割: データ取得の窓口（APIとdomainの橋渡し）
- BitcoinRepository.getUtxos() // API結果をentityへ変換して返す
- BitcoinRepository.collectAllUtxos() // 複数アドレスのUTXOを集約
