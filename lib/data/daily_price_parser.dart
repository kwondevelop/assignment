import 'package:html/parser.dart' as html_parser;

import '../model/daily_price.dart';

class DailyPriceParser {
  DailyPriceResult parse(String html) {
    final document = html_parser.parse(html);
    final prices = <DailyPrice>[];

    for (final row in document.querySelectorAll('table.type2 tr')) {
      final cells = row.querySelectorAll('td');

      // 제목 행과 여백 행은 제외합니다.
      if (cells.length != 7) continue;

      final dateText = cells[0].text.trim();

      if (!RegExp(r'^\d{4}\.\d{2}\.\d{2}$').hasMatch(dateText)) {
        continue;
      }

      final parts = dateText.split('.');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      final date = DateTime(year, month, day);

      if (date.year != year || date.month != month || date.day != day) {
        throw FormatException('잘못된 날짜: $dateText');
      }

      final changeCell = cells[2];
      final changeText = changeCell.querySelector('span.tah')?.text;

      if (changeText == null) {
        throw const FormatException('일별 등락액을 찾지 못했습니다.');
      }

      final amount = _parseNumber(changeText).abs();

      final isDown =
          changeCell.querySelector('.bu_pdn, .nv01') != null ||
          changeCell.text.contains('하락');

      final isUp =
          changeCell.querySelector('.bu_pup, .red02') != null ||
          changeCell.text.contains('상승');

      if (amount != 0 && !isDown && !isUp) {
        throw const FormatException('등락 방향을 확인하지 못했습니다.');
      }

      prices.add(
        DailyPrice(
          localDate: dateText.replaceAll('.', ''),
          closePrice: _parseNumber(cells[1].text),
          changeAmount: amount == 0
              ? 0
              : isDown
              ? -amount
              : amount,
          openPrice: _parseNumber(cells[3].text),
          highPrice: _parseNumber(cells[4].text),
          lowPrice: _parseNumber(cells[5].text),
          volume: _parseNumber(cells[6].text),
        ),
      );
    }

    if (prices.isEmpty) {
      throw const FormatException('일별 시세를 찾지 못했습니다. 응답 내용을 확인해 주세요.');
    }

    prices.sort((a, b) => b.localDate.compareTo(a.localDate));

    final lastLink = document.querySelector('.pgRR a');
    int lastPage;

    if (lastLink != null) {
      final page = _pageFromLink(lastLink.attributes['href']);

      if (page == null) {
        throw const FormatException('마지막 페이지를 읽지 못했습니다.');
      }

      lastPage = page;
    } else {
      // 마지막 페이지에서는 '맨뒤' 링크가 없을 수 있습니다.
      if (document.querySelector('.pgR a') != null) {
        throw const FormatException('마지막 페이지를 확인하지 못했습니다.');
      }

      lastPage = 1;

      for (final link in document.querySelectorAll('table.Nnavi a')) {
        final page = _pageFromLink(link.attributes['href']);

        if (page != null && page > lastPage) {
          lastPage = page;
        }
      }
    }

    return DailyPriceResult(prices: prices, lastPage: lastPage);
  }

  int _parseNumber(String text) {
    final cleaned = text.replaceAll(',', '').trim();
    final value = int.tryParse(cleaned);

    if (value == null) {
      throw FormatException('숫자를 읽지 못했습니다: $text');
    }

    return value;
  }

  int? _pageFromLink(String? href) {
    if (href == null) return null;

    final value = Uri.tryParse(href)?.queryParameters['page'];
    final page = int.tryParse(value ?? '');

    return page != null && page > 0 ? page : null;
  }
}
