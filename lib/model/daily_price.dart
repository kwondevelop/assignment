// 하루치만 담음
class DailyPrice {
  final String localDate;
  final int closePrice;
  final int openPrice;
  final int highPrice;
  final int lowPrice;
  final int volume;

  DailyPrice({
    required this.localDate,
    required this.closePrice,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.volume,
  });
}

// 파싱 결과를 한 번에 담아서 보냄
class DailyPriceResult {
  final List prices;
  final int lastPage;

  DailyPriceResult({
    required this.prices,
    required this.lastPage,
  });
}