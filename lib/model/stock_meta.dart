class StockMeta {
  final String symbolCode;
  final String stockName;
  final String exchangeName;

  StockMeta({
    required this.symbolCode,
    required this.stockName,
    required this.exchangeName,
  });

  factory StockMeta.fromJson(Map json) {
    return StockMeta(
      symbolCode: json['symbolCode'] ?? '',
      stockName: json['stockName'] ?? '',
      exchangeName: json['stockExchangeNameKor'] ?? '',
    );
  }
}
