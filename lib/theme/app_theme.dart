import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_palette.dart';
import 'app_typography.dart';

/// 앱 전역 테마입니다.
///
/// `MaterialApp`에 아래와 같이 연결해서 사용해 주세요.
///
/// ```dart
/// MaterialApp(
///   theme: AppTheme.dark,
///   home: const WatchlistScreen(),
/// )
/// ```
///
/// 이번 과제는 다크 테마 단일 모드입니다. 라이트 테마는 구현하지 않아도 됩니다.
abstract final class AppTheme {
  static ThemeData get dark {
    const AppColors colors = AppColors.dark();
    const AppDimens dimens = AppDimens.standard();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppTypography.fontFamily,
      scaffoldBackgroundColor: colors.surfaceBase,
      colorScheme: const ColorScheme.dark(
        primary: AppPalette.violet500,
        onPrimary: AppPalette.neutral0,
        surface: AppPalette.neutral950,
        onSurface: AppPalette.neutral0,
        error: AppPalette.red500,
        onError: AppPalette.neutral0,
      ),
      extensions: const <ThemeExtension<dynamic>>[colors, dimens],
    );
  }
}

/// 토큰을 짧게 꺼내 쓰기 위한 확장입니다.
///
/// ```dart
/// Text('삼성전자', style: TextStyle(color: context.colors.textPrimary))
/// SizedBox(height: context.dimens.space4)
/// ```
extension AppThemeContext on BuildContext {
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? const AppColors.dark();

  AppDimens get dimens =>
      Theme.of(this).extension<AppDimens>() ?? const AppDimens.standard();
}
