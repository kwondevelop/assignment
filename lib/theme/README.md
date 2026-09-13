# lib/theme — 디자인 토큰

이 폴더는 **Figma 파일의 변수(Variables)를 그대로 옮긴 디자인 토큰**입니다.
앱 테마(`AppTheme.dark`)로 연결되어 있으니 화면 코드에서는 이 토큰만 사용해 주세요.

- 값을 임의로 수정하지 마세요. 아래 대응표로 Figma 변수와 1:1 확인이 가능합니다.
- 색상 hex를 화면 코드에 직접 쓰거나 `AppPalette`를 화면에서 바로 참조하지 마세요.
- 필요한 토큰이 없다고 판단되면 추가해도 됩니다. 다만 왜 추가했는지 메모에 적어 주세요.

## 파일 구성

| 파일 | 내용 | Figma 컬렉션 |
|---|---|---|
| `app_palette.dart` | 원시 팔레트 | `Primitives` |
| `app_colors.dart` | 시맨틱 색상 (`ThemeExtension`) | `Semantic` / Dark |
| `app_dimens.dart` | 간격 · 반경 · 크기 (`ThemeExtension`) | `Scale` |
| `app_typography.dart` | 서체 · 굵기 | `Typography` |
| `app_theme.dart` | `ThemeData` 조립 + `context` 확장 | — |
| `theme.dart` | barrel | — |

## 사용법

```dart
MaterialApp(
  theme: AppTheme.dark,
  home: const WatchlistScreen(),
)
```

```dart
Text('삼성전자', style: TextStyle(color: context.colors.textPrimary))
SizedBox(height: context.dimens.space4)
```

## 색상 대응표 (`Semantic` / Dark)

| Figma 변수 | Dart 필드 | 참조 원시값 | Hex |
|---|---|---|---|
| `surface/base` | `surfaceBase` | `neutral/950` | `#0F0F0E` |
| `surface/raised` | `surfaceRaised` | `neutral/900` | `#161614` |
| `surface/sunken` | `surfaceSunken` | `neutral/800` | `#1C1C19` |
| `surface/overlay` | `surfaceOverlay` | `neutral/700` | `#23231F` |
| `text/primary` | `textPrimary` | `neutral/0` | `#FAF9F5` |
| `text/secondary` | `textSecondary` | `neutral/200` | `#B4B2A9` |
| `text/tertiary` | `textTertiary` | `neutral/300` | `#888780` |
| `text/disabled` | `textDisabled` | `neutral/400` | `#5A5952` |
| `border/subtle` | `borderSubtle` | `neutral/700` | `#23231F` |
| `border/strong` | `borderStrong` | `neutral/500` | `#3D3D37` |
| `price/up/text` | `priceUpText` | `red/400` | `#FF5B5B` |
| `price/up/bg` | `priceUpBg` | `red/alpha-12` | `#FF5B5B` 12% |
| `price/down/text` | `priceDownText` | `blue/400` | `#4D9BEE` |
| `price/down/bg` | `priceDownBg` | `blue/alpha-12` | `#4D9BEE` 12% |
| `price/flat/text` | `priceFlatText` | `neutral/200` | `#B4B2A9` |
| `price/flat/bg` | `priceFlatBg` | `neutral/700` | `#23231F` |
| `chart/line/up` | `chartLineUp` | `red/400` | `#FF5B5B` |
| `chart/line/down` | `chartLineDown` | `blue/400` | `#4D9BEE` |
| `chart/line/flat` | `chartLineFlat` | `neutral/200` | `#B4B2A9` |
| `chart/area/up` | `chartAreaUp` | `red/alpha-12` | `#FF5B5B` 12% |
| `chart/area/down` | `chartAreaDown` | `blue/alpha-12` | `#4D9BEE` 12% |
| `chart/baseline` | `chartBaseline` | `neutral/400` | `#5A5952` |
| `chart/axis-label` | `chartAxisLabel` | `neutral/300` | `#888780` |
| `chart/volume-bar` | `chartVolumeBar` | `neutral/500` | `#3D3D37` |
| `accent/default` | `accentDefault` | `violet/500` | `#8B7CF6` |
| `accent/bg` | `accentBg` | `violet/alpha-12` | `#8B7CF6` 12% |
| `favorite/active` | `favoriteActive` | `gold/500` | `#F5B544` |
| `favorite/inactive` | `favoriteInactive` | `neutral/400` | `#5A5952` |
| `nav/active` | `navActive` | `neutral/0` | `#FAF9F5` |
| `nav/inactive` | `navInactive` | `neutral/300` | `#888780` |
| `feedback/warning` | `feedbackWarning` | `amber/500` | `#E8973A` |
| `feedback/skeleton` | `feedbackSkeleton` | `neutral/700` | `#23231F` |
| `search/highlight` | `searchHighlight` | `violet/500` | `#8B7CF6` |

`alpha-12`는 해당 색상의 12% 불투명도입니다. (`0.12 × 255 = 31 = 0x1F`)

등락 색상은 국내 시장 관행을 따릅니다. **상승은 빨강, 하락은 파랑**입니다.

## 간격 · 크기 대응표 (`Scale`)

| Figma 변수 | Dart 필드 | 값 |
|---|---|---|
| `space/1` | `space1` | 4 |
| `space/2` | `space2` | 8 |
| `space/3` | `space3` | 12 |
| `space/4` | `space4` | 16 |
| `space/5` | `space5` | 20 |
| `space/6` | `space6` | 24 |
| `radius/sm` | `radiusSm` | 4 |
| `radius/md` | `radiusMd` | 8 |
| `radius/lg` | `radiusLg` | 12 |
| `border/hairline` | `borderHairline` | 1 |
| `icon/sm` | `iconSm` | 16 |
| `icon/md` | `iconMd` | 20 |
| `size/row-min` | `rowMinHeight` | 56 |
| `size/tabbar` | `tabBarHeight` | 56 |

## 서체 (`Typography`)

| Figma 변수 | Dart | 값 |
|---|---|---|
| `font/family/base` | `AppTypography.fontFamily` | `Noto Sans KR` |
| `font/style/regular` | `AppTypography.regular` | `FontWeight.w400` |
| `font/style/medium` | `AppTypography.medium` | `FontWeight.w500` |
| `font/style/bold` | `AppTypography.bold` | `FontWeight.w700` |

**글자 크기와 행간은 토큰으로 정의되어 있지 않습니다.**
Figma가 서체와 굵기만 변수로 관리하고 있어서, 크기는 각 화면의 텍스트 레이어에서 직접 확인해 주세요.
