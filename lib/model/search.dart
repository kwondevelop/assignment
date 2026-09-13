class Search {
  final String id;
  final String code;
  final String name;
  final String exchangeName;

  const Search({
    required this.id,
    required this.code,
    required this.name,
    required this.exchangeName,
  });

  factory Search.fromJson(Map<String, dynamic> json) {
    final code = json['code'] as String;

    return Search(
      id: 'domestic:$code',
      code: code,
      name: json['name'] as String,
      exchangeName: json['typeName'] as String? ?? '',
    );
  }
}

List<Search> parseAndFilterSearchItems(List<dynamic> items) {
  final results = <Search>[];
  final seen = <String>{};

  for (final item in items) {
    if (item is! Map<String, dynamic>) continue;

    final code = item['code'];

    if (item['nationCode'] != 'KOR' ||
        item['category'] != 'stock' ||
        code is! String ||
        !RegExp(r'^[0-9]{6}$').hasMatch(code) ||
        item['name'] is! String) {
      continue;
    }

    if (seen.add(code)) {
      results.add(Search.fromJson(item));
    }
  }

  return results;
}
