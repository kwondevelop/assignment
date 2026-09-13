class NowPrice {
  final String symbol;
  final int currentPrice;
  final int previousClose;
  final int listedStockCount;

  NowPrice({
    required this.symbol,
    required this.currentPrice,
    required this.previousClose,
    required this.listedStockCount,
  });

  factory NowPrice.fromJson(Map json) {
    return NowPrice(
      symbol: json['cd'] ?? '',
      currentPrice: json['nv'] ?? 0,
      previousClose: json['pcv'] ?? 0,
      listedStockCount: json['countOfListedStock'] ?? 0,
    );
  }
  // 등락액 = 현재가 - 전일종가
  int get changeAmount => currentPrice - previousClose; 
  
  // 등락률 = 등락액 / 전일종가
  double get changeRate => previousClose == 0 ? 0.0 : (currentPrice - previousClose) / previousClose; 
  
  // 시가총액 = 현재가 * 상장주식수
  int get marketCap => currentPrice * listedStockCount;
}
