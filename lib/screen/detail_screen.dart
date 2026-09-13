import 'package:flutter/material.dart';

import '../data/stock_api.dart';
import '../model/daily_price.dart';
import '../model/now_price.dart';
import '../model/stock_meta.dart';
import '../state/favorite_store.dart';
import '../theme/theme.dart';
import '../widget/candle_chart.dart';

enum PricePeriod {
  oneMonth('1개월', 1),
  threeMonths('3개월', 3),
  sixMonths('6개월', 6),
  oneYear('1년', 12);

  const PricePeriod(this.label, this.months);

  final String label;
  final int months;
}

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    super.key,
    required this.stock,
    required this.favoriteStore,
  });

  final StockMeta stock;
  final FavoriteStore favoriteStore;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final StockApi _stockApi = StockApi();

  NowPrice? _quote;
  bool _isLoading = true;
  String? _error;

  List<DailyPrice> _dailyPrices = [];
  bool _isDailyLoading = true;
  String? _dailyError;

  PricePeriod _selectedPeriod = PricePeriod.oneMonth;
  int _dailyRequestId = 0;

  @override
  void initState() {
    super.initState();
    _loadQuote();
    _loadDailyPrices();
  }

  Future<void> _loadQuote() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final quotes = await _stockApi.fetchQuotes([widget.stock.symbolCode]);

      final quote = quotes[widget.stock.symbolCode];

      if (quote == null) {
        throw StateError('종목 시세가 응답에 없습니다.');
      }

      if (!mounted) return;

      setState(() {
        _quote = quote;
      });
    } catch (error) {
      if (!mounted) return;

      debugPrint('상세 시세 조회 오류: $error');

      setState(() {
        _error = '시세를 불러오지 못했습니다.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadDailyPrices() async {
    final requestId = ++_dailyRequestId;
    final period = _selectedPeriod;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 선택한 개월 수만큼 이전 달을 계산합니다.
    final targetMonth = DateTime(today.year, today.month - period.months, 1);

    // 해당 달에 오늘과 같은 날짜가 없으면 그 달의 마지막 날을 씁니다.
    final lastDayOfMonth = DateTime(
      targetMonth.year,
      targetMonth.month + 1,
      0,
    ).day;

    final startDate = DateTime(
      targetMonth.year,
      targetMonth.month,
      today.day > lastDayOfMonth ? lastDayOfMonth : today.day,
    );

    setState(() {
      _isDailyLoading = true;
      _dailyError = null;
      _dailyPrices = [];
    });

    try {
      final pricesByDate = <String, DailyPrice>{};
      int page = 1;

      while (true) {
        if (!mounted || requestId != _dailyRequestId) return;

        final result = await _stockApi.fetchDailyPage(
          widget.stock.symbolCode,
          page,
        );

        if (!mounted || requestId != _dailyRequestId) return;

        if (result.prices.isEmpty) {
          throw StateError('일별 시세 페이지가 비어 있습니다.');
        }

        DateTime oldestDate = _dailyDate(result.prices.first.localDate);

        for (final price in result.prices) {
          final date = _dailyDate(price.localDate);

          if (date.isBefore(oldestDate)) {
            oldestDate = date;
          }

          if (!date.isBefore(startDate) && !date.isAfter(today)) {
            pricesByDate[price.localDate] = price;
          }
        }

        // 필요한 시작일까지 받았거나 마지막 페이지면 종료합니다.
        if (!oldestDate.isAfter(startDate) || page >= result.lastPage) {
          break;
        }

        page++;
      }

      if (!mounted || requestId != _dailyRequestId) return;

      final prices = pricesByDate.values.toList()
        ..sort((a, b) => b.localDate.compareTo(a.localDate));

      setState(() {
        _dailyPrices = prices;
      });
    } catch (error) {
      if (!mounted || requestId != _dailyRequestId) return;

      debugPrint('기간별 시세 조회 오류: $error');

      setState(() {
        _dailyError = '일별 시세를 불러오지 못했습니다.';
      });
    } finally {
      if (mounted && requestId == _dailyRequestId) {
        setState(() {
          _isDailyLoading = false;
        });
      }
    }
  }

  DateTime _dailyDate(String value) {
    return DateTime(
      int.parse(value.substring(0, 4)),
      int.parse(value.substring(4, 6)),
      int.parse(value.substring(6, 8)),
    );
  }

  String _formatNumber(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  String _formatVolume(int value) {
    if (value < 1000) return _formatNumber(value);

    return '${_formatNumber(value ~/ 1000)}천';
  }

  String _formatMarketCap(int value) {
    const trillion = 1000000000000;
    const hundredMillion = 100000000;

    if (value >= trillion) {
      return '${_formatNumber(value ~/ trillion)}조';
    }

    if (value >= hundredMillion) {
      return '${_formatNumber(value ~/ hundredMillion)}억';
    }

    return _formatNumber(value);
  }

  Widget _buildHeader() {
    return ListenableBuilder(
      listenable: widget.favoriteStore,
      builder: (context, child) {
        final stock = widget.stock;
        final isFavorite = widget.favoriteStore.contains(stock.symbolCode);

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.dimens.space2,
            vertical: context.dimens.space2,
          ),
          child: Row(
            children: [
              IconButton(
                tooltip: '뒤로 가기',
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back,
                  size: context.dimens.iconMd,
                  color: context.colors.textPrimary,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock.stockName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: 18,
                        fontWeight: AppTypography.bold,
                      ),
                    ),
                    SizedBox(height: context.dimens.space1),
                    Text(
                      '${stock.symbolCode} · ${stock.exchangeName}',
                      style: TextStyle(
                        color: context.colors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: isFavorite ? '관심 해제' : '관심 등록',
                onPressed: () {
                  widget.favoriteStore.toggle(stock);
                },
                icon: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  size: context.dimens.iconMd,
                  color: isFavorite
                      ? context.colors.favoriteActive
                      : context.colors.favoriteInactive,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuote() {
    if (_isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _skeleton(160, 36),
          SizedBox(height: context.dimens.space2),
          _skeleton(140, 16),
        ],
      );
    }

    if (_error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _error!,
            style: TextStyle(
              color: context.colors.feedbackWarning,
              fontSize: 13,
            ),
          ),
          TextButton(
            onPressed: _loadQuote,
            child: Text(
              '재시도',
              style: TextStyle(color: context.colors.accentDefault),
            ),
          ),
        ],
      );
    }

    final quote = _quote;
    if (quote == null) return const SizedBox.shrink();

    final change = quote.changeAmount;
    final rate = quote.changeRate * 100;

    final color = change > 0
        ? context.colors.priceUpText
        : change < 0
        ? context.colors.priceDownText
        : context.colors.priceFlatText;

    final direction = change > 0
        ? '▲'
        : change < 0
        ? '▼'
        : '―';

    return Wrap(
      spacing: context.dimens.space2,
      runSpacing: context.dimens.space1,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          _formatNumber(quote.currentPrice),
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 32,
            fontWeight: AppTypography.bold,
            height: 1.2,
          ),
        ),
        Text(
          '$direction ${_formatNumber(change.abs())} '
          '(${rate > 0 ? '+' : ''}${rate.toStringAsFixed(2)}%)',
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: AppTypography.regular,
          ),
        ),
      ],
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

  Widget _buildSummaryItem(String label, String value) {
    return Container(
      padding: EdgeInsets.all(context.dimens.space3),
      decoration: BoxDecoration(
        color: context.colors.surfaceRaised,
        borderRadius: BorderRadius.circular(context.dimens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: context.colors.textTertiary,
              fontSize: 11,
              fontWeight: AppTypography.regular,
            ),
          ),
          SizedBox(height: context.dimens.space1),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 16,
              fontWeight: AppTypography.medium,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    if (_isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _skeleton(120, 16),
          SizedBox(height: context.dimens.space4),
          _skeleton(160, 16),
        ],
      );
    }

    final quote = _quote;

    if (_error != null || quote == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryItem('시가', _formatNumber(quote.openPrice)),
            ),
            SizedBox(width: context.dimens.space2),
            Expanded(
              child: _buildSummaryItem('고가', _formatNumber(quote.highPrice)),
            ),
            SizedBox(width: context.dimens.space2),
            Expanded(
              child: _buildSummaryItem('저가', _formatNumber(quote.lowPrice)),
            ),
          ],
        ),
        SizedBox(height: context.dimens.space2),
        Row(
          children: [
            Expanded(
              child: _buildSummaryItem('거래량', _formatVolume(quote.volume)),
            ),
            SizedBox(width: context.dimens.space2),
            Expanded(
              child: _buildSummaryItem(
                '시가총액',
                _formatMarketCap(quote.marketCap),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dailyCell(
    String text, {
    bool heading = false,
    Color? color,
    bool alignLeft = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.dimens.space2),
      child: Text(
        text,
        textAlign: alignLeft ? TextAlign.left : TextAlign.right,
        style: TextStyle(
          color: color ?? context.colors.textTertiary,
          fontSize: 11,
          fontWeight: AppTypography.regular,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildDailyTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '일별 시세',
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 16,
            fontWeight: AppTypography.bold,
          ),
        ),
        SizedBox(height: context.dimens.space2),
        if (_isDailyLoading)
          Padding(
            padding: EdgeInsets.all(context.dimens.space4),
            child: Center(
              child: CircularProgressIndicator(
                color: context.colors.accentDefault,
              ),
            ),
          )
        else if (_dailyError != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _dailyError!,
                style: TextStyle(
                  color: context.colors.feedbackWarning,
                  fontSize: 13,
                ),
              ),
              TextButton(
                onPressed: _loadDailyPrices,
                child: Text(
                  '재시도',
                  style: TextStyle(color: context.colors.accentDefault),
                ),
              ),
            ],
          )
        else if (_dailyPrices.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: context.dimens.space4),
            child: Text(
              '선택한 기간의 시세가 없습니다.',
              style: TextStyle(
                color: context.colors.textTertiary,
                fontSize: 13,
              ),
            ),
          )
        else
          Table(
            columnWidths: const {
              0: FlexColumnWidth(0.8),
              1: FlexColumnWidth(1.2),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1.4),
            },
            border: TableBorder(
              horizontalInside: BorderSide(
                color: context.colors.borderSubtle,
                width: context.dimens.borderHairline,
              ),
            ),
            children: [
              TableRow(
                children: [
                  _dailyCell('날짜', heading: true, alignLeft: true),
                  _dailyCell('종가', heading: true),
                  _dailyCell('등락', heading: true),
                  _dailyCell('거래량', heading: true),
                ],
              ),
              for (final price in _dailyPrices)
                TableRow(
                  children: [
                    _dailyCell(
                      '${price.localDate.substring(4, 6)}.'
                      '${price.localDate.substring(6, 8)}',
                      alignLeft: true,
                    ),
                    _dailyCell(
                      _formatNumber(price.closePrice),
                      color: context.colors.textPrimary,
                    ),
                    _dailyCell(
                      '${price.changeAmount > 0 ? '+' : ''}'
                      '${_formatNumber(price.changeAmount)}',
                      color: price.changeAmount > 0
                          ? context.colors.priceUpText
                          : price.changeAmount < 0
                          ? context.colors.priceDownText
                          : context.colors.priceFlatText,
                    ),
                    _dailyCell(_formatNumber(price.volume)),
                  ],
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildPeriodTabs() {
    return Row(
      children: [
        for (final period in PricePeriod.values)
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.dimens.space1),
              child: TextButton(
                onPressed: () {
                  if (_selectedPeriod == period) return;

                  setState(() {
                    _selectedPeriod = period;
                  });

                  _loadDailyPrices();
                },
                style: TextButton.styleFrom(
                  foregroundColor: _selectedPeriod == period
                      ? context.colors.accentDefault
                      : context.colors.textTertiary,
                  backgroundColor: _selectedPeriod == period
                      ? context.colors.accentBg
                      : context.colors.surfaceBase,
                  padding: EdgeInsets.symmetric(
                    vertical: context.dimens.space2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      context.dimens.radiusMd,
                    ),
                  ),
                ),
                child: Text(
                  period.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: AppTypography.medium,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildChart() {
    if (_isDailyLoading) {
      return SizedBox(
        height: 220,
        child: Center(
          child: CircularProgressIndicator(color: context.colors.accentDefault),
        ),
      );
    }

    if (_dailyError != null) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Text(
            '차트 데이터를 불러오지 못했습니다.\n아래 재시도 버튼을 눌러 주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.colors.textTertiary, fontSize: 13),
          ),
        ),
      );
    }

    if (_dailyPrices.isEmpty) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Text(
            '선택한 기간의 시세가 없습니다.',
            style: TextStyle(color: context.colors.textTertiary, fontSize: 13),
          ),
        ),
      );
    }

    return CandleChart(prices: _dailyPrices);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceBase,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Divider(
              height: context.dimens.borderHairline,
              thickness: context.dimens.borderHairline,
              color: context.colors.borderSubtle,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(context.dimens.space4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuote(),
                    SizedBox(height: context.dimens.space4),
                    _buildPeriodTabs(),
                    SizedBox(height: context.dimens.space4),

                    _buildChart(),
                    SizedBox(height: context.dimens.space4),

                    _buildSummary(),
                    SizedBox(height: context.dimens.space6),
                    _buildDailyTable(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
