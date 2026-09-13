import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Figma `Scale` 컬렉션을 옮긴 간격 / 반경 / 크기 토큰입니다.
///
/// 화면 코드에서는 `context.dimens.space4` 형태로 사용해 주세요.
@immutable
class AppDimens extends ThemeExtension<AppDimens> {
  const AppDimens({
    required this.space1,
    required this.space2,
    required this.space3,
    required this.space4,
    required this.space5,
    required this.space6,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.borderHairline,
    required this.iconSm,
    required this.iconMd,
    required this.rowMinHeight,
    required this.tabBarHeight,
  });

  const AppDimens.standard()
      : space1 = 4,
        space2 = 8,
        space3 = 12,
        space4 = 16,
        space5 = 20,
        space6 = 24,
        radiusSm = 4,
        radiusMd = 8,
        radiusLg = 12,
        borderHairline = 1,
        iconSm = 16,
        iconMd = 20,
        rowMinHeight = 56,
        tabBarHeight = 56;

  final double space1;
  final double space2;
  final double space3;
  final double space4;
  final double space5;
  final double space6;

  final double radiusSm;
  final double radiusMd;
  final double radiusLg;

  final double borderHairline;

  final double iconSm;
  final double iconMd;

  /// 목록 행의 최소 높이입니다.
  final double rowMinHeight;

  /// 하단 탭 바의 높이입니다.
  final double tabBarHeight;

  @override
  AppDimens copyWith({
    double? space1,
    double? space2,
    double? space3,
    double? space4,
    double? space5,
    double? space6,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? borderHairline,
    double? iconSm,
    double? iconMd,
    double? rowMinHeight,
    double? tabBarHeight,
  }) {
    return AppDimens(
      space1: space1 ?? this.space1,
      space2: space2 ?? this.space2,
      space3: space3 ?? this.space3,
      space4: space4 ?? this.space4,
      space5: space5 ?? this.space5,
      space6: space6 ?? this.space6,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      borderHairline: borderHairline ?? this.borderHairline,
      iconSm: iconSm ?? this.iconSm,
      iconMd: iconMd ?? this.iconMd,
      rowMinHeight: rowMinHeight ?? this.rowMinHeight,
      tabBarHeight: tabBarHeight ?? this.tabBarHeight,
    );
  }

  @override
  AppDimens lerp(covariant AppDimens? other, double t) {
    if (other == null) return this;
    return AppDimens(
      space1: lerpDouble(space1, other.space1, t)!,
      space2: lerpDouble(space2, other.space2, t)!,
      space3: lerpDouble(space3, other.space3, t)!,
      space4: lerpDouble(space4, other.space4, t)!,
      space5: lerpDouble(space5, other.space5, t)!,
      space6: lerpDouble(space6, other.space6, t)!,
      radiusSm: lerpDouble(radiusSm, other.radiusSm, t)!,
      radiusMd: lerpDouble(radiusMd, other.radiusMd, t)!,
      radiusLg: lerpDouble(radiusLg, other.radiusLg, t)!,
      borderHairline: lerpDouble(borderHairline, other.borderHairline, t)!,
      iconSm: lerpDouble(iconSm, other.iconSm, t)!,
      iconMd: lerpDouble(iconMd, other.iconMd, t)!,
      rowMinHeight: lerpDouble(rowMinHeight, other.rowMinHeight, t)!,
      tabBarHeight: lerpDouble(tabBarHeight, other.tabBarHeight, t)!,
    );
  }
}
