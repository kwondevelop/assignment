import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Figma `Semantic` 컬렉션(Dark 모드)을 옮긴 시맨틱 색상 토큰입니다.
///
/// 화면 코드에서는 `context.colors.priceUpText` 형태로 사용해 주세요.
/// (`AppThemeContext` 확장은 `app_theme.dart`에 있습니다.)
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.surfaceBase,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.surfaceOverlay,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.borderSubtle,
    required this.borderStrong,
    required this.priceUpText,
    required this.priceUpBg,
    required this.priceDownText,
    required this.priceDownBg,
    required this.priceFlatText,
    required this.priceFlatBg,
    required this.chartLineUp,
    required this.chartLineDown,
    required this.chartLineFlat,
    required this.chartAreaUp,
    required this.chartAreaDown,
    required this.chartBaseline,
    required this.chartAxisLabel,
    required this.chartVolumeBar,
    required this.accentDefault,
    required this.accentBg,
    required this.favoriteActive,
    required this.favoriteInactive,
    required this.navActive,
    required this.navInactive,
    required this.feedbackWarning,
    required this.feedbackSkeleton,
    required this.searchHighlight,
  });

  /// Figma `Semantic` 컬렉션의 Dark 모드 값입니다.
  const AppColors.dark()
      : surfaceBase = AppPalette.neutral950,
        surfaceRaised = AppPalette.neutral900,
        surfaceSunken = AppPalette.neutral800,
        surfaceOverlay = AppPalette.neutral700,
        textPrimary = AppPalette.neutral0,
        textSecondary = AppPalette.neutral200,
        textTertiary = AppPalette.neutral300,
        textDisabled = AppPalette.neutral400,
        borderSubtle = AppPalette.neutral700,
        borderStrong = AppPalette.neutral500,
        priceUpText = AppPalette.red400,
        priceUpBg = AppPalette.redAlpha12,
        priceDownText = AppPalette.blue400,
        priceDownBg = AppPalette.blueAlpha12,
        priceFlatText = AppPalette.neutral200,
        priceFlatBg = AppPalette.neutral700,
        chartLineUp = AppPalette.red400,
        chartLineDown = AppPalette.blue400,
        chartLineFlat = AppPalette.neutral200,
        chartAreaUp = AppPalette.redAlpha12,
        chartAreaDown = AppPalette.blueAlpha12,
        chartBaseline = AppPalette.neutral400,
        chartAxisLabel = AppPalette.neutral300,
        chartVolumeBar = AppPalette.neutral500,
        accentDefault = AppPalette.violet500,
        accentBg = AppPalette.violetAlpha12,
        favoriteActive = AppPalette.gold500,
        favoriteInactive = AppPalette.neutral400,
        navActive = AppPalette.neutral0,
        navInactive = AppPalette.neutral300,
        feedbackWarning = AppPalette.amber500,
        feedbackSkeleton = AppPalette.neutral700,
        searchHighlight = AppPalette.violet500;

  /// 화면 배경 계층.
  final Color surfaceBase;
  final Color surfaceRaised;
  final Color surfaceSunken;
  final Color surfaceOverlay;

  /// 텍스트 계층.
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;

  final Color borderSubtle;
  final Color borderStrong;

  /// 등락 표시. 상승은 빨강, 하락은 파랑입니다. (국내 시장 관행)
  final Color priceUpText;
  final Color priceUpBg;
  final Color priceDownText;
  final Color priceDownBg;

  /// 보합(0%)일 때 사용합니다.
  final Color priceFlatText;
  final Color priceFlatBg;

  /// 캔들 차트.
  final Color chartLineUp;
  final Color chartLineDown;
  final Color chartLineFlat;
  final Color chartAreaUp;
  final Color chartAreaDown;
  final Color chartBaseline;
  final Color chartAxisLabel;
  final Color chartVolumeBar;

  /// 선택된 기간 탭 등 강조 요소.
  final Color accentDefault;
  final Color accentBg;

  /// 관심 등록 별 아이콘.
  final Color favoriteActive;
  final Color favoriteInactive;

  /// 하단 탭 바.
  final Color navActive;
  final Color navInactive;

  final Color feedbackWarning;

  /// 시세를 아직 받지 못한 행의 스켈레톤.
  final Color feedbackSkeleton;

  /// 검색 결과에서 검색어와 일치하는 부분.
  final Color searchHighlight;

  @override
  AppColors copyWith({
    Color? surfaceBase,
    Color? surfaceRaised,
    Color? surfaceSunken,
    Color? surfaceOverlay,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? borderSubtle,
    Color? borderStrong,
    Color? priceUpText,
    Color? priceUpBg,
    Color? priceDownText,
    Color? priceDownBg,
    Color? priceFlatText,
    Color? priceFlatBg,
    Color? chartLineUp,
    Color? chartLineDown,
    Color? chartLineFlat,
    Color? chartAreaUp,
    Color? chartAreaDown,
    Color? chartBaseline,
    Color? chartAxisLabel,
    Color? chartVolumeBar,
    Color? accentDefault,
    Color? accentBg,
    Color? favoriteActive,
    Color? favoriteInactive,
    Color? navActive,
    Color? navInactive,
    Color? feedbackWarning,
    Color? feedbackSkeleton,
    Color? searchHighlight,
  }) {
    return AppColors(
      surfaceBase: surfaceBase ?? this.surfaceBase,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      surfaceOverlay: surfaceOverlay ?? this.surfaceOverlay,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderStrong: borderStrong ?? this.borderStrong,
      priceUpText: priceUpText ?? this.priceUpText,
      priceUpBg: priceUpBg ?? this.priceUpBg,
      priceDownText: priceDownText ?? this.priceDownText,
      priceDownBg: priceDownBg ?? this.priceDownBg,
      priceFlatText: priceFlatText ?? this.priceFlatText,
      priceFlatBg: priceFlatBg ?? this.priceFlatBg,
      chartLineUp: chartLineUp ?? this.chartLineUp,
      chartLineDown: chartLineDown ?? this.chartLineDown,
      chartLineFlat: chartLineFlat ?? this.chartLineFlat,
      chartAreaUp: chartAreaUp ?? this.chartAreaUp,
      chartAreaDown: chartAreaDown ?? this.chartAreaDown,
      chartBaseline: chartBaseline ?? this.chartBaseline,
      chartAxisLabel: chartAxisLabel ?? this.chartAxisLabel,
      chartVolumeBar: chartVolumeBar ?? this.chartVolumeBar,
      accentDefault: accentDefault ?? this.accentDefault,
      accentBg: accentBg ?? this.accentBg,
      favoriteActive: favoriteActive ?? this.favoriteActive,
      favoriteInactive: favoriteInactive ?? this.favoriteInactive,
      navActive: navActive ?? this.navActive,
      navInactive: navInactive ?? this.navInactive,
      feedbackWarning: feedbackWarning ?? this.feedbackWarning,
      feedbackSkeleton: feedbackSkeleton ?? this.feedbackSkeleton,
      searchHighlight: searchHighlight ?? this.searchHighlight,
    );
  }

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      surfaceBase: Color.lerp(surfaceBase, other.surfaceBase, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      surfaceSunken: Color.lerp(surfaceSunken, other.surfaceSunken, t)!,
      surfaceOverlay: Color.lerp(surfaceOverlay, other.surfaceOverlay, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      priceUpText: Color.lerp(priceUpText, other.priceUpText, t)!,
      priceUpBg: Color.lerp(priceUpBg, other.priceUpBg, t)!,
      priceDownText: Color.lerp(priceDownText, other.priceDownText, t)!,
      priceDownBg: Color.lerp(priceDownBg, other.priceDownBg, t)!,
      priceFlatText: Color.lerp(priceFlatText, other.priceFlatText, t)!,
      priceFlatBg: Color.lerp(priceFlatBg, other.priceFlatBg, t)!,
      chartLineUp: Color.lerp(chartLineUp, other.chartLineUp, t)!,
      chartLineDown: Color.lerp(chartLineDown, other.chartLineDown, t)!,
      chartLineFlat: Color.lerp(chartLineFlat, other.chartLineFlat, t)!,
      chartAreaUp: Color.lerp(chartAreaUp, other.chartAreaUp, t)!,
      chartAreaDown: Color.lerp(chartAreaDown, other.chartAreaDown, t)!,
      chartBaseline: Color.lerp(chartBaseline, other.chartBaseline, t)!,
      chartAxisLabel: Color.lerp(chartAxisLabel, other.chartAxisLabel, t)!,
      chartVolumeBar: Color.lerp(chartVolumeBar, other.chartVolumeBar, t)!,
      accentDefault: Color.lerp(accentDefault, other.accentDefault, t)!,
      accentBg: Color.lerp(accentBg, other.accentBg, t)!,
      favoriteActive: Color.lerp(favoriteActive, other.favoriteActive, t)!,
      favoriteInactive: Color.lerp(favoriteInactive, other.favoriteInactive, t)!,
      navActive: Color.lerp(navActive, other.navActive, t)!,
      navInactive: Color.lerp(navInactive, other.navInactive, t)!,
      feedbackWarning: Color.lerp(feedbackWarning, other.feedbackWarning, t)!,
      feedbackSkeleton: Color.lerp(feedbackSkeleton, other.feedbackSkeleton, t)!,
      searchHighlight: Color.lerp(searchHighlight, other.searchHighlight, t)!,
    );
  }
}
