import 'dart:convert';
import 'package:bit_saifu/src/lib/crypto/bitcoin/data/dto/utxo_dto.dart';
import 'package:http/http.dart' as http;

abstract class BitcoinApi {
  Future<List<UtxoDto>> getUtxos(String address);
  Future<String> broadcastTransaction(String rawTxHex);
}

class BlockstreamBitcoinClient implements BitcoinApi {
  @override
  Future<List<UtxoDto>> getUtxos(String address) async {
    final url = Uri.parse(
      'https://blockstream.info/testnet/api/address/$address/utxo',
    );

    final response = await http.get(url);
    print('response: ${response.body}');

    if (response.statusCode != 200) {
      return [];
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => UtxoDto.fromJson(e)).toList();
  }

  @override
  Future<String> broadcastTransaction(String rawTxHex) async {
    final url = Uri.parse(
      'https://blockstream.info/testnet/api/tx',
    );

    final response = await http.post(
      url,
      body: rawTxHex,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to broadcast tx: ${response.statusCode} ${response.body}',
      );
    }

    return response.body;
  }
}
