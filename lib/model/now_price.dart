class NowPrice {
  final String symbol;
  final int currentPrice;
  final int previousClose;
  final int listedStockCount;
  final int openPrice;
  final int highPrice;
  final int lowPrice;
  final int volume;

  NowPrice({
    required this.symbol,
    required this.currentPrice,
    required this.previousClose,
    required this.listedStockCount,
    this.openPrice = 0,
    this.highPrice = 0,
    this.lowPrice = 0,
    this.volume = 0,
  });

  factory NowPrice.fromJson(Map<String, dynamic> json) {
    return NowPrice(
      symbol: json['cd'] as String? ?? '',
      currentPrice: (json['nv'] as num?)?.toInt() ?? 0,
      previousClose: (json['pcv'] as num?)?.toInt() ?? 0,
      listedStockCount: (json['countOfListedStock'] as num?)?.toInt() ?? 0,
      openPrice: (json['ov'] as num?)?.toInt() ?? 0,
      highPrice: (json['hv'] as num?)?.toInt() ?? 0,
      lowPrice: (json['lv'] as num?)?.toInt() ?? 0,
      volume: (json['aq'] as num?)?.toInt() ?? 0,
    );
  }

  int get changeAmount => currentPrice - previousClose;

  double get changeRate {
    if (previousClose == 0) return 0;
    return changeAmount / previousClose;
  }

  int get marketCap => currentPrice * listedStockCount;
}
