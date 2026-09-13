import 'package:flutter/material.dart';

/// Figma `Typography` 컬렉션을 옮긴 서체 토큰입니다.
///
/// Figma는 서체와 굵기만 변수로 정의해 두었습니다.
/// **글자 크기와 행간은 각 화면의 텍스트 레이어에서 직접 확인해서 쓰세요.**
/// 여기에 임의의 타입 스케일을 만들어두지 않은 이유입니다.
abstract final class AppTypography {
  /// `pubspec.yaml`의 `flutter.fonts`에 등록한 family 이름과 일치해야 합니다.
  static const String fontFamily = 'NotoSansKR';

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight bold = FontWeight.w700;
}
