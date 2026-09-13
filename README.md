# Flutter 신입 개발자 과제

국내 주식 관심종목 앱의 화면 3개를 **Flutter 코드**로 구현하고, 그중 한 화면을 저희 플랫폼 **Lucy Studio**로 다시 만드는 과제입니다. 전체 기간은 4일입니다.

이 문서는 저장소를 실행하고 디자인 토큰을 쓰는 방법만 다룹니다. **과제 요구사항은 아래 문서에 있습니다.**

| 문서 | 내용 |
| --- | --- |
| [`docs/ASSIGNMENT.md`](docs/ASSIGNMENT.md) | 화면별 요구사항, 평가 기준, 제출 방법 |
| [`docs/NAVER_API.md`](docs/NAVER_API.md) | Naver 데이터 연동 가이드 (endpoint 4개) |

**Figma 시안 링크는 안내 메일에 담겨 있습니다.** 시안의 `Screens` 페이지에는 화면 3개 외에 빈 상태 · 정렬 · 토스트처럼 같은 화면의 다른 상태를 그린 프레임과, 토큰 확인용 `Design Tokens — Dark` 프레임이 함께 있습니다. 어떤 프레임이 무엇인지는 [`docs/ASSIGNMENT.md`의 대상 화면](docs/ASSIGNMENT.md#대상-화면)에 정리해 두었습니다.

AI 도구를 활용해도 괜찮습니다. 다만 이후 기술 면접에서 구현 내용을 구체적으로 질문할 예정이니, 직접 작성한 코드라고 설명할 수 있을 정도로 이해하고 계셔야 합니다.

---

## 실행하기

이 저장소를 그대로 사용하면 됩니다. 별도로 프로젝트를 만들지 않아도 됩니다.

```bash
flutter pub get
flutter run
```

모든 플랫폼으로 실행할 수 있게 만들어져 있습니다. 다만 아래 두 가지를 주의해 주세요.

- **웹(Chrome)에서는 동작하지 않습니다.** Naver endpoint가 CORS를 허용하지 않아 브라우저에서는 요청이 막힙니다. IDE 기본 실행 대상이 Chrome으로 잡혀 있는 경우가 많으니 실행 대상을 바꿔 주세요.
- **모바일 기기나 에뮬레이터, 또는 Figma 프레임에 가까운 창 크기에서 확인해 주세요.** 데스크톱에서 창을 크게 띄우고 비교하면 의미가 없습니다.

macOS 데스크톱으로 확인하실 경우 네트워크 요청에 entitlement가 필요합니다. debug 실행은 기본 설정으로 동작합니다.

---

## 저장소 구성

`flutter create` 직후의 기본 템플릿에 **디자인 토큰과 폰트만 미리 준비해 둔 상태**입니다.

```text
docs/
  ASSIGNMENT.md           과제 요구사항 · 평가 기준 · 제출 방법
  NAVER_API.md            Naver 데이터 연동 가이드
lib/
  main.dart               앱 진입점. 시작용 화면이 들어 있습니다
  theme/
    README.md             Figma 변수 ↔ Dart 필드 대응표
    app_palette.dart      원시 팔레트 (Figma Primitives)
    app_colors.dart       시맨틱 색상 토큰 (Figma Semantic / Dark)
    app_dimens.dart       간격 · 반경 · 크기 토큰 (Figma Scale)
    app_typography.dart   서체 · 굵기 토큰 (Figma Typography)
    app_theme.dart        ThemeData 조립 + context 확장
    theme.dart            barrel
assets/
  fonts/                  Noto Sans KR (등록까지 마쳐둔 상태입니다)
  mock/                   응답 샘플을 저장해 쓰실 위치입니다
```

`lib/` 아래 나머지 구조는 없습니다. **폴더 구조와 아키텍처는 직접 설계해 주세요.**

`lib/main.dart`의 `StartHereScreen`은 토큰 사용 예시를 겸한 임시 화면입니다. 지우고 직접 구현한 화면으로 바꿔 주세요.

---

## 디자인 토큰

색상은 `ThemeExtension`으로 정의되어 있습니다. `AppTheme.dark`가 `MaterialApp`에 이미 연결되어 있으니 `context`로 꺼내 쓰시면 됩니다.

```dart
MaterialApp(
  theme: AppTheme.dark,
  home: const WatchlistScreen(),
)
```

```dart
Text(
  '삼성전자',
  style: TextStyle(color: context.colors.textPrimary),
)

Container(
  padding: EdgeInsets.symmetric(horizontal: context.dimens.space4),
  decoration: BoxDecoration(
    color: context.colors.surfaceRaised,
    borderRadius: BorderRadius.circular(context.dimens.radiusMd),
  ),
)
```

지켜 주셔야 할 것:

- **토큰 값을 수정하지 마세요.** 색상 hex를 화면 코드에 직접 쓰거나 `AppPalette`를 화면에서 바로 참조하지 말고, 항상 `context.colors.*` 시맨틱 토큰을 쓰세요. (필수)
- 필요한 토큰이 없다고 판단되면 추가해도 됩니다. 다만 왜 추가했는지 메모에 적어 주세요.
- **글자 크기와 행간은 토큰으로 정의되어 있지 않습니다.** Figma는 서체와 굵기만 변수로 관리하고 있어서, 크기는 각 화면의 텍스트 레이어에서 직접 확인해 주세요.

Figma 변수명과 Dart 필드명, 원시값, hex는 [`lib/theme/README.md`](lib/theme/README.md)에 1:1로 정리해 두었습니다. Figma에서 본 색이 코드의 어느 필드인지 헷갈릴 때 그 표를 보시면 됩니다.

### 폰트

`Noto Sans KR`을 사용합니다. 폰트 파일과 `pubspec.yaml` 등록은 **미리 해두었으니 따로 작업하지 않으셔도 됩니다.**

`assets/fonts/`에 Regular / Medium / Bold 세 가지 굵기가 들어 있고, `AppTypography.fontFamily`(`'NotoSansKR'`)와 같은 이름으로 등록되어 있습니다. `AppTheme.dark`가 이 family를 기본 서체로 잡아둡니다.

다른 방식(예: `google_fonts` 패키지)으로 바꾸셔도 무방합니다. 바꾸셨다면 메모에 적어 주세요.

---

## 이 README에 대해

제출 시 이 문서는 **본인 프로젝트의 README로 덮어써 주세요.** 작성할 내용은 [`docs/ASSIGNMENT.md`의 제출 방법](docs/ASSIGNMENT.md#제출-방법)에 정리되어 있습니다. `docs/` 아래 문서는 남겨 두시면 됩니다.

## 라이선스

이 저장소는 이든크루 채용 과제의 스타터 템플릿으로만 제공됩니다. 과제 수행을 위해 복제하고 수정하는 것은 괜찮습니다. 다만 그 범위를 넘어선 재배포나 상업적 이용은 Edencrew의 명시적인 허가 없이 허용되지 않습니다. 자세한 내용은 루트의 `LICENSE` 파일을 확인해 주세요.

**별도로 전달드린 Figma 시안과 Lucy Studio 설치 파일은 외부에 공유하지 말아주세요.**
