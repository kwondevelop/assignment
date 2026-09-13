import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../model/daily_price.dart';
import '../theme/theme.dart';

class CandleChart extends StatelessWidget {
  const CandleChart({super.key, required this.prices});

  final List<DailyPrice> prices;

  @override
  Widget build(BuildContext context) {
    // 표는 최신순이지만 차트는 과거 → 최근 순서로 그립니다.
    final sorted = List<DailyPrice>.of(prices)
      ..sort((a, b) => a.localDate.compareTo(b.localDate));

    return Semantics(
      label: '${sorted.length}거래일 캔들 차트. 상세 값은 아래 일별 시세 표에서 확인할 수 있습니다.',
      child: SizedBox(
        width: double.infinity,
        height: 220,
        child: CustomPaint(
          painter: _CandlestickPainter(
            prices: sorted,
            upColor: context.colors.chartLineUp,
            downColor: context.colors.chartLineDown,
            flatColor: context.colors.chartLineFlat,
            verticalPadding: context.dimens.space3,
          ),
        ),
      ),
    );
  }
}

class _CandlestickPainter extends CustomPainter {
  _CandlestickPainter({
    required this.prices,
    required this.upColor,
    required this.downColor,
    required this.flatColor,
    required this.verticalPadding,
  });

  final List<DailyPrice> prices;
  final Color upColor;
  final Color downColor;
  final Color flatColor;
  final double verticalPadding;

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.isEmpty || size.width <= 0 || size.height <= 0) {
      return;
    }

    double lowest = prices.first.lowPrice.toDouble();
    double highest = prices.first.highPrice.toDouble();

    for (final price in prices) {
      lowest = math.min(lowest, price.lowPrice.toDouble());
      highest = math.max(highest, price.highPrice.toDouble());
    }

    // 모든 가격이 같아도 0으로 나누지 않도록 범위를 확보합니다.
    final difference = highest - lowest;
    final margin = difference > 0
        ? difference * 0.05
        : math.max(highest.abs() * 0.01, 1.0);

    final minPrice = lowest - margin;
    final maxPrice = highest + margin;
    final priceRange = maxPrice - minPrice;

    final padding = math.min(verticalPadding, size.height / 4);
    final plotHeight = size.height - padding * 2;

    double priceToY(int price) {
      return padding + (maxPrice - price) / priceRange * plotHeight;
    }

    final step = size.width / prices.length;
    final bodyWidth = math.min(step * 0.65, 10.0);
    final wickWidth = math.min(bodyWidth, 1.0);

    final paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.clipRect(Offset.zero & size);

    for (int index = 0; index < prices.length; index++) {
      final price = prices[index];

      // 캔들 색은 전일 대비가 아니라 당일 시가·종가로 결정합니다.
      if (price.closePrice > price.openPrice) {
        paint.color = upColor;
      } else if (price.closePrice < price.openPrice) {
        paint.color = downColor;
      } else {
        paint.color = flatColor;
      }

      final x = step * (index + 0.5);

      final highY = priceToY(price.highPrice);
      final lowY = priceToY(price.lowPrice);
      final openY = priceToY(price.openPrice);
      final closeY = priceToY(price.closePrice);

      // 꼬리: 당일 고가부터 저가까지
      paint.strokeWidth = wickWidth;
      canvas.drawLine(Offset(x, highY), Offset(x, lowY), paint);

      final bodyTop = math.min(openY, closeY);
      final bodyBottom = math.max(openY, closeY);
      final bodyHeight = bodyBottom - bodyTop;

      if (bodyHeight < 1) {
        // 시가와 종가가 같거나 차이가 작으면 가로선으로 표시합니다.
        paint.strokeWidth = 1;
        final y = (openY + closeY) / 2;

        canvas.drawLine(
          Offset(x - bodyWidth / 2, y),
          Offset(x + bodyWidth / 2, y),
          paint,
        );
      } else {
        // 몸통: 당일 시가부터 종가까지
        canvas.drawRect(
          Rect.fromLTWH(x - bodyWidth / 2, bodyTop, bodyWidth, bodyHeight),
          paint,
        );
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CandlestickPainter oldDelegate) {
    return oldDelegate.prices != prices ||
        oldDelegate.upColor != upColor ||
        oldDelegate.downColor != downColor ||
        oldDelegate.flatColor != flatColor ||
        oldDelegate.verticalPadding != verticalPadding;
  }
}
