import 'dart:convert';
import 'dart:io';

import 'package:charset_converter/charset_converter.dart';
import 'package:flutter/foundation.dart';

import '../model/daily_price.dart';
import '../model/now_price.dart';
import '../model/search.dart';
import '../model/stock_meta.dart';
import 'daily_price_parser.dart';

class StockApi {
  final Map<String, Future<DailyPriceResult>> _dailyPageCache = {};
  final Map<String, int> _lastPages = {};

  Future<DailyPriceResult> fetchDailyPage(String symbol, int page) async {
    if (!RegExp(r'^[0-9]{6}$').hasMatch(symbol) || page < 1) {
      throw ArgumentError('종목코드 또는 페이지가 올바르지 않습니다.');
    }

    final lastPage = _lastPages[symbol];

    if (lastPage != null && page > lastPage) {
      throw StateError('마지막 페이지를 넘겨 요청할 수 없습니다.');
    }

    final key = '$symbol:$page';
    final cached = _dailyPageCache[key];

    if (cached != null) return cached;

    final request = _requestDailyPage(symbol, page);
    _dailyPageCache[key] = request;

    try {
      final result = await request;
      _lastPages[symbol] = result.lastPage;
      return result;
    } catch (_) {
      // 실패한 페이지는 다음 호출에서 재시도합니다.
      if (identical(_dailyPageCache[key], request)) {
        _dailyPageCache.remove(key);
      }
      rethrow;
    }
  }

  Future<DailyPriceResult> _requestDailyPage(String symbol, int page) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);

    try {
      final uri = Uri.https('finance.naver.com', '/item/sise_day.naver', {
        'code': symbol,
        'page': page.toString(),
      });

      final request = await client
          .getUrl(uri)
          .timeout(const Duration(seconds: 10));

      request.headers.set(
        HttpHeaders.userAgentHeader,
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
        'AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/130.0.0.0 Safari/537.36',
      );

      request.headers.set(
        HttpHeaders.refererHeader,
        'https://finance.naver.com/item/main.naver?code=$symbol',
      );

      final response = await request.close().timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode != 200) {
        throw HttpException('일별 시세 조회 실패: ${response.statusCode}');
      }

      final bytes = await response
          .fold<List<int>>(<int>[], (buffer, chunk) => buffer..addAll(chunk))
          .timeout(const Duration(seconds: 10));

      // 일별 HTML은 헤더에 인코딩이 없으면 EUC-KR로 읽습니다.
      final charset = response.headers.contentType?.charset ?? 'euc-kr';

      final String text;

      if (charset.toLowerCase() == 'utf-8') {
        text = utf8.decode(bytes);
      } else {
        text = await CharsetConverter.decode(
          charset,
          Uint8List.fromList(bytes),
        );
      }

      return DailyPriceParser().parse(text);
    } finally {
      client.close(force: true);
    }
  }

  final Map<String, Future<StockMeta>> _metadataCache = {};

  Future<StockMeta> fetchMetadata(String symbol) async {
    final cached = _metadataCache[symbol];
    if (cached != null) return cached;

    final request = _requestMetadata(symbol);
    _metadataCache[symbol] = request;

    try {
      return await request;
    } catch (_) {
      // 실패한 요청은 제거해서 다음에 재시도할 수 있게 합니다.
      if (identical(_metadataCache[symbol], request)) {
        _metadataCache.remove(symbol);
      }
      rethrow;
    }
  }

  Future<StockMeta> _requestMetadata(String symbol) async {
    if (!RegExp(r'^[0-9]{6}$').hasMatch(symbol)) {
      throw ArgumentError('종목코드는 숫자 6자리여야 합니다.');
    }

    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);

    try {
      final uri = Uri.https(
        'stock.naver.com',
        '/api/securityFe/api/fchart/domestic/stock/$symbol',
      );

      final request = await client
          .getUrl(uri)
          .timeout(const Duration(seconds: 10));

      final response = await request.close().timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode != 200) {
        throw HttpException('종목 정보 조회 실패: ${response.statusCode}');
      }

      final bytes = await response
          .fold<List<int>>(<int>[], (buffer, chunk) => buffer..addAll(chunk))
          .timeout(const Duration(seconds: 10));

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

      if (json['symbolCode'] != symbol ||
          json['stockName'] is! String ||
          json['stockExchangeNameKor'] is! String) {
        throw const FormatException('종목 정보 응답이 올바르지 않습니다.');
      }

      return StockMeta.fromJson(json);
    } finally {
      client.close(force: true);
    }
  }

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

      final bytes = await response
          .fold<List<int>>(<int>[], (buffer, chunk) => buffer..addAll(chunk))
          .timeout(const Duration(seconds: 10));

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

          quotes[symbol] = NowPrice.fromJson(data);
        }
      }

      return quotes;
    } finally {
      client.close(force: true);
    }
  }

  Future<List<Search>> searchStocks(String keyword) async {
    if (keyword.trim().isEmpty) return [];

    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);

    try {
      final uri = Uri.https('ac.stock.naver.com', '/ac', {
        'q': keyword,
        'target': 'stock,ipo,index,marketindicator',
      });

      final request = await client
          .getUrl(uri)
          .timeout(const Duration(seconds: 10));

      final response = await request.close().timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode != 200) {
        throw HttpException('검색 실패: ${response.statusCode}');
      }

      final bytes = await response
          .fold<List<int>>(<int>[], (buffer, chunk) => buffer..addAll(chunk))
          .timeout(const Duration(seconds: 10));

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

      return parseAndFilterSearchItems(json['items'] as List<dynamic>);
    } finally {
      client.close(force: true);
    }
  }
}
