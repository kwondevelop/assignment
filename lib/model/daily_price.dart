class DailyPrice {
  final String localDate;
  final int closePrice;
  final int changeAmount;
  final int openPrice;
  final int highPrice;
  final int lowPrice;
  final int volume;

  const DailyPrice({
    required this.localDate,
    required this.closePrice,
    required this.changeAmount,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.volume,
  });
}

class DailyPriceResult {
  final List<DailyPrice> prices;
  final int lastPage;

  const DailyPriceResult({required this.prices, required this.lastPage});
}
