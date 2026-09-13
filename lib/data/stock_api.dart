import 'dart:typed_data';
import 'package:charset_converter/charset_converter.dart';

import 'dart:convert';
import 'dart:io';

import '../model/now_price.dart';

class StockApi {
  Future<Map<String, NowPrice>> fetchQuotes(List<String> symbols) async {
    if (symbols.isEmpty) return {};

    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);

    try {
      final uri = Uri.https('polling.finance.naver.com', '/api/realtime', {
        'query': 'SERVICE_ITEM:${symbols.join(',')}',
      });

      final request = await client
          .getUrl(uri)
          .timeout(const Duration(seconds: 10));

      final response = await request.close().timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode != 200) {
        throw HttpException('시세 조회 실패: ${response.statusCode}');
      }

      // 응답을 먼저 바이트로 받습니다.
      final bytes = await response
          .fold<List<int>>(<int>[], (buffer, chunk) => buffer..addAll(chunk))
          .timeout(const Duration(seconds: 10));

      // 서버가 알려준 인코딩으로 문자열을 만듭니다.
      final charset = response.headers.contentType?.charset ?? 'utf-8';

      final String text;

      if (charset.toLowerCase() == 'utf-8') {
        text = utf8.decode(bytes);
      } else {
        text = await CharsetConverter.decode(
          charset,
          Uint8List.fromList(bytes),
        );
      }

      final json = jsonDecode(text) as Map<String, dynamic>;

      if (json['resultCode'] != 'success') {
        throw const FormatException('시세 응답이 올바르지 않습니다.');
      }

      final result = json['result'] as Map<String, dynamic>;
      final quotes = <String, NowPrice>{};

      for (final area in result['areas'] as List<dynamic>) {
        if (area['name'] != 'SERVICE_ITEM') continue;

        for (final item in area['datas'] as List<dynamic>) {
          final data = item as Map<String, dynamic>;
          final symbol = data['cd'];

          if (symbol is! String || data['nv'] is! num || data['pcv'] is! num) {
            continue;
          }

          quotes[symbol] = NowPrice(
            symbol: symbol,
            currentPrice: (data['nv'] as num).toInt(),
            previousClose: (data['pcv'] as num).toInt(),
            listedStockCount:
                (data['countOfListedStock'] as num?)?.toInt() ?? 0,
          );
        }
      }

      return quotes;
    } finally {
      client.close(force: true);
    }
  }
}
