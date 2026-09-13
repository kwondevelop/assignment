import 'package:flutter/foundation.dart';

import '../model/stock_meta.dart';

class FavoriteStore extends ChangeNotifier {
  final Map<String, StockMeta> _stocks = {};

  List<StockMeta> get stocks => _stocks.values.toList();

  bool contains(String symbol) {
    return _stocks.containsKey(symbol);
  }

  void toggle(StockMeta stock) {
    if (contains(stock.symbolCode)) {
      _stocks.remove(stock.symbolCode);
    } else {
      _stocks[stock.symbolCode] = stock;
    }

    notifyListeners();
  }
}
