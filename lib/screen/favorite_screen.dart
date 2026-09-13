import 'package:flutter/material.dart';
import '../data/stock_api.dart';

import '../model/now_price.dart';
import '../model/stock_meta.dart';
import '../theme/theme.dart';

enum SortType { price, changeRate, name }

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  SortType _sortType = SortType.price;

  // 목록과 정렬 확인용 임시 관심종목입니다.
  final List<StockMeta> _favorites = [
    StockMeta(symbolCode: '005930', stockName: '삼성전자', exchangeName: '코스피'),
    StockMeta(symbolCode: '000660', stockName: 'SK하이닉스', exchangeName: '코스피'),
  ];

  final StockApi _stockApi = StockApi();

  final Map<String, NowPrice> _quotes = {};
  String? _loadError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshQuotes();
  }

  Future<void> _refreshQuotes() async {
    // 조회 중에는 중복 요청하지 않습니다.
    if (_isLoading || _favorites.isEmpty) return;

    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final symbols = _favorites.map((stock) => stock.symbolCode).toList();

      final quotes = await _stockApi.fetchQuotes(symbols);

      if (!mounted) return;

      setState(() {
        // 응답에서 빠진 종목은 기존 시세를 유지합니다.
        _quotes.addAll(quotes);

        if (symbols.any((symbol) => !quotes.containsKey(symbol))) {
          _loadError = '일부 종목의 시세를 받지 못했습니다. 다시 시도해 주세요.';
        }
      });
    } catch (error, stackTrace) {
      debugPrint('시세 조회 오류: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _loadError = '시세를 불러오지 못했습니다. 새로고침을 눌러 주세요.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _labelFor(SortType type) {
    switch (type) {
      case SortType.price:
        return '현재가순';
      case SortType.changeRate:
        return '등락률순';
      case SortType.name:
        return '가나다순';
    }
  }

  Future<void> _showSortSheet() async {
    final selected = await showModalBottomSheet<SortType>(
      context: context,
      backgroundColor: context.colors.surfaceRaised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.dimens.radiusLg),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: sheetContext.dimens.space4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    '정렬',
                    style: TextStyle(
                      color: sheetContext.colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                for (final type in SortType.values)
                  ListTile(
                    title: Text(
                      _labelFor(type),
                      style: TextStyle(color: sheetContext.colors.textPrimary),
                    ),
                    trailing: _sortType == type
                        ? Icon(
                            Icons.check,
                            color: sheetContext.colors.accentDefault,
                          )
                        : null,
                    onTap: () {
                      Navigator.pop(sheetContext, type);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || selected == null) return;

    setState(() {
      _sortType = selected;
    });
  }

  List<StockMeta> get _sortedFavorites {
    final sorted = List<StockMeta>.of(_favorites);

    sorted.sort((a, b) {
      if (_sortType == SortType.name) {
        return a.stockName.compareTo(b.stockName);
      }

      final aQuote = _quotes[a.symbolCode];
      final bQuote = _quotes[b.symbolCode];

      // 시세가 없는 종목은 마지막에 표시합니다.
      if (aQuote == null && bQuote != null) return 1;
      if (aQuote != null && bQuote == null) return -1;

      if (aQuote == null || bQuote == null) {
        return a.stockName.compareTo(b.stockName);
      }

      final comparison = _sortType == SortType.price
          ? bQuote.currentPrice.compareTo(aQuote.currentPrice)
          : bQuote.changeRate.compareTo(aQuote.changeRate);

      return comparison == 0 ? a.stockName.compareTo(b.stockName) : comparison;
    });

    return sorted;
  }

  String _formatNumber(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  Widget _skeleton(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.colors.feedbackSkeleton,
        borderRadius: BorderRadius.circular(context.dimens.radiusSm),
      ),
    );
  }

  Widget _buildStockRow(StockMeta stock) {
    final quote = _quotes[stock.symbolCode];
    final colors = context.colors;

    final change = quote?.changeAmount ?? 0;
    final priceColor = change > 0
        ? colors.priceUpText
        : change < 0
        ? colors.priceDownText
        : colors.priceFlatText;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: context.dimens.rowMinHeight),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.dimens.space3),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.stockName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: context.dimens.space1),
                  Text(
                    '${stock.symbolCode} · ${stock.exchangeName}',
                    style: TextStyle(color: colors.textTertiary, fontSize: 11),
                  ),
                ],
              ),
            ),
            SizedBox(width: context.dimens.space3),
            if (quote == null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _skeleton(80, 16),
                  SizedBox(height: context.dimens.space2),
                  _skeleton(110, 12),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatNumber(quote.currentPrice),
                    style: TextStyle(
                      color: priceColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: context.dimens.space1),
                  Text(
                    '${change > 0 ? '+' : ''}${_formatNumber(change)} '
                    '(${change > 0 ? '+' : ''}'
                    '${(quote.changeRate * 100).toStringAsFixed(2)}%)',
                    style: TextStyle(color: priceColor, fontSize: 11),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.dimens.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star_border,
              size: 48,
              color: context.colors.favoriteInactive,
            ),
            SizedBox(height: context.dimens.space4),
            Text(
              '관심 종목이 없습니다',
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: context.dimens.space2),
            Text(
              '검색 탭에서 종목을 찾아\n별 아이콘을 눌러 추가해 주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textTertiary,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stocks = _sortedFavorites;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.colors.surfaceBase,
        title: Text('관심', style: TextStyle(color: context.colors.textPrimary)),
        actions: [
          TextButton(
            onPressed: _showSortSheet,
            style: TextButton.styleFrom(
              foregroundColor: context.colors.textSecondary,
              padding: EdgeInsets.symmetric(horizontal: context.dimens.space2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _labelFor(_sortType),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: context.dimens.space1),
                Icon(Icons.arrow_downward, size: context.dimens.iconSm),
              ],
            ),
          ),
          IconButton(
            tooltip: '새로고침',
            onPressed: _isLoading ? null : _refreshQuotes,
            icon: _isLoading
                ? SizedBox(
                    width: context.dimens.iconMd,
                    height: context.dimens.iconMd,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.colors.textSecondary,
                    ),
                  )
                : Icon(
                    Icons.refresh,
                    color: context.colors.textSecondary,
                    size: context.dimens.iconMd,
                  ),
          ),
          SizedBox(width: context.dimens.space2),
        ],
      ),
      body: _favorites.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                if (_loadError != null)
                  Padding(
                    padding: EdgeInsets.all(context.dimens.space4),
                    child: Text(
                      _loadError!,
                      style: TextStyle(color: context.colors.feedbackWarning),
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.dimens.space4,
                    ),
                    itemCount: stocks.length,
                    separatorBuilder: (context, index) => Divider(
                      height: context.dimens.borderHairline,
                      color: context.colors.borderSubtle,
                    ),
                    itemBuilder: (context, index) {
                      return _buildStockRow(stocks[index]);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
