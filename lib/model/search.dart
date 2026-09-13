class Search {
  final String id;
  final String code;
  final String name;

  Search({required this.id, required this.code, required this.name});

  factory Search.fromJson(Map json) {
    return Search(
      id: 'domestic:${json['code']}', // domestic:{symbol} 형태
      code: json['code'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

List parseAndFilterSearchItems(List items) {
  return items.where((item) {
    final nationCode = item['nationCode'] ?? '';
    final code = item['code'] ?? '';
    
    // 국내 주식만 
    final isDomestic = nationCode == 'KOR'; 
    // 6자리 종목코드만
    final isSixDigits = code.length == 6 && int.tryParse(code) != null;
    
    return isDomestic && isSixDigits;
  }).map((item) => Search.fromJson(item)).toList();
}