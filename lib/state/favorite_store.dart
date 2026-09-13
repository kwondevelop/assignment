import 'package:flutter/foundation.dart';

import '../model/stock_meta.dart';

class FavoriteStore extends ChangeNotifier {
  final Map<String, StockMeta> _stocks = {};

  // 현재 관심종목 목록
  List<StockMeta> get stocks => _stocks.values.toList();

  // 해당 종목이 관심종목인지 확인
  bool contains(String symbol) {
    return _stocks.containsKey(symbol);
  }

  // 관심종목이면 해제, 아니면 등록
  void toggle(StockMeta stock) {
    if (contains(stock.symbolCode)) {
      _stocks.remove(stock.symbolCode);
    } else {
      _stocks[stock.symbolCode] = stock;
    }

    // 연결된 화면에 변경 사실을 알림
    notifyListeners();
  }
}