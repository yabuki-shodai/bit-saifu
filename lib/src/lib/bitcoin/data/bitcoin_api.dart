import 'dart:convert';
import 'package:bit_saifu/src/lib/bitcoin/data/dto/utxo_dto.dart';
import 'package:http/http.dart' as http;

abstract class BitcoinApi {
  Future<List<UtxoDto>> getUtxos(String address);
}

class BlockstreamBitcoinClient implements BitcoinApi {
  @override
  Future<List<UtxoDto>> getUtxos(String address) async {
    final url = Uri.parse(
      'https://blockstream.info/testnet/api/address/$address/utxo',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to get UTXO: ${response.statusCode}');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => UtxoDto.fromJson(e)).toList();
  }
}
