import 'dart:ui' show Color;

/// Figma `Primitives` 컬렉션을 그대로 옮긴 원시 팔레트입니다.
///
/// 화면 코드에서 이 클래스를 직접 참조하지 마세요.
/// 항상 [AppColors]의 시맨틱 토큰을 사용해 주세요.
/// (예: `AppPalette.red400` 대신 `context.colors.priceUpText`)
abstract final class AppPalette {
  // neutral
  static const Color neutral950 = Color(0xFF0F0F0E);
  static const Color neutral900 = Color(0xFF161614);
  static const Color neutral800 = Color(0xFF1C1C19);
  static const Color neutral700 = Color(0xFF23231F);
  static const Color neutral600 = Color(0xFF2E2E29);
  static const Color neutral500 = Color(0xFF3D3D37);
  static const Color neutral400 = Color(0xFF5A5952);
  static const Color neutral300 = Color(0xFF888780);
  static const Color neutral200 = Color(0xFFB4B2A9);
  static const Color neutral100 = Color(0xFFD6D4CB);
  static const Color neutral50 = Color(0xFFEAE8E0);
  static const Color neutral0 = Color(0xFFFAF9F5);

  // red — 국내 시장 관행상 상승을 의미합니다.
  static const Color red600 = Color(0xFFD93B44);
  static const Color red500 = Color(0xFFF04452);
  static const Color red400 = Color(0xFFFF5B5B);

  // blue — 국내 시장 관행상 하락을 의미합니다.
  static const Color blue600 = Color(0xFF2A6FB5);
  static const Color blue500 = Color(0xFF378ADD);
  static const Color blue400 = Color(0xFF4D9BEE);

  static const Color gold500 = Color(0xFFF5B544);
  static const Color amber500 = Color(0xFFE8973A);

  static const Color violet600 = Color(0xFF6D5DE0);
  static const Color violet500 = Color(0xFF8B7CF6);
  static const Color violet400 = Color(0xFFA594FF);

  // alpha-12 — 위 색상의 12% 불투명도 (0.12 * 255 = 31 = 0x1F)
  static const Color redAlpha12 = Color(0x1FFF5B5B);
  static const Color blueAlpha12 = Color(0x1F4D9BEE);
  static const Color violetAlpha12 = Color(0x1F8B7CF6);
}
