import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:bit_saifu/src/lib/type/bitcoin/address/bitcoin_address_type.dart';
import 'package:bit_saifu/src/lib/type/network/crypto_network.dart';

part 'bitcoin_entity.freezed.dart';
part 'bitcoin_entity.g.dart';

@freezed
abstract class BitcoinEntity with _$BitcoinEntity {
  const factory BitcoinEntity({
    required String address,
    required String publicKey,
    required BitcoinAddressType type,
    required CryptoNetwork network,
  }) = _BitcoinEntity;

  factory BitcoinEntity.fromJson(Map<String, dynamic> json) =>
      _$BitcoinEntityFromJson(json);
}
