import 'dart:convert';
import 'package:http/http.dart' as http;

class ExchangeService {
  Future<Map<String, dynamic>> getDollarQuotation() async {
    final url = Uri.parse(
      'https://economia.awesomeapi.com.br/json/last/USD-BRL,EUR-BRL,BTC-BRL',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Erro ao buscar cotação');
  }
}