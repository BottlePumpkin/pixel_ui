# pixel_ui Tuner — Consolidated Design

- 작성일: 2026-04-23
- 브랜치: `feat/tuner`
- 상위 스펙(구조): `docs/specs/2026-04-22-tuner-design.md`
- 이 문서의 역할: 상위 스펙의 결정을 **그대로 계승**하되, 시각 품질을 결정하는 **구체 파라미터 3가지**를 추가 확정한다.

## 상위 스펙에서 그대로 가져오는 결정

다음은 `docs/specs/2026-04-22-tuner-design.md` 결정을 재확인만 하고 변경하지 않는다:

- **스코프**: `PixelShapeStyle` 튜너 단일. Dart 코드 생성 + Clipboard 복사.
- **디렉터리**: `tuner/` sibling of `lib/`·`example/`. `publish_to: none`.
- **의존성**: `pixel_ui: path ../`.
- **상태**: 단일 `ValueNotifier<PixelShapeStyle>` + `copyWith`.
- **파일 분해**: `home_page` · `tuner_state` · `preview_panel` · `code_panel` · `code_generator` · `color_hex_parser` · `theme` · `widgets/pixel_section_header` · `widgets/pixel_card` · `controls/{corner,color_hex,border_width,shadow,texture}`.
- **코드 생성 규칙**: preset corner 감지, null 필드 생략, `Color(0xFF…)` 대문자 8자리, 2-space 들여쓰기.
- **배포**: `.github/workflows/deploy-tuner.yml`, GitHub Pages, `--base-href /pixel_ui/`, path-filter 트리거.
- **Flutter**: `3.32.7` 고정 (pixel_ui 다른 워크플로와 일치).
- **테스트**: 순수 함수 단위 테스트만 (`code_generator_test`, `color_hex_parser_test`).
- **마일스톤**: M1 scaffold → M2 controls → M3 code/copy/responsive → M4 deploy.

## 이 문서에서 추가 확정하는 시각 파라미터

상위 스펙의 "**Hybrid (B) — pixel chrome + Material 컨트롤**" 방향을 유지하되, 다음 3가지 파라미터로 시각 품질을 NES.css / Material Theme Builder 레퍼런스 수준으로 끌어올린다.

### R1. Preview를 지배적 크기로 — 레이아웃 비율 30/70

**레퍼런스**: [Material Theme Builder](https://material-foundation.github.io/material-theme-builder/)는 좌측 좁은 컨트롤 패널 + 우측 넓은 preview/export 패널.

**결정**:
- Width > 720px일 때 좌 30% Controls / 우 70% Preview + Code (상위 spec의 50/50 → 30/70)
- Preview 렌더 스케일을 4x → **6x**로 확대 (`logicalWidth: 80` × 6 = 480px 폭)
- ≤ 720px stacked 모드는 변경 없음

**근거**: 튜너의 핵심 가치는 "조정 결과를 시각화해 감을 잡는 것". Preview가 작으면 픽셀 디테일을 확인 불가. Controls는 오른쪽 preview 상태를 빠르게 조작하기 위한 수단이므로 최소 필요 폭만 확보하면 됨. Material Theme Builder도 실사용에서 preview가 화면 지배적 크기를 차지.

### R2. Code 패널 = 어두운 배경 + MulmaruMono

**레퍼런스**: NES.css / 98.css의 "code as terminal output" 감성.

**결정**:
- Code 패널 배경 `Color(0xFF1A1A1A)` (짙은 회색)
- 전경 텍스트 `Color(0xFF9CCC65)` (라임 그린, pixel_ui 브랜드 연두 계열)
- 폰트: **`PixelText.mulmaruMono(fontSize: 12, color: Color(0xFF9CCC65))`** — 방금 번들한 MulmaruMono 첫 실사용
- `SelectableText` 래핑 유지 (수동 복사 fallback)
- `PixelCard` 대신 자체 `DecoratedBox` 사용 (짙은 배경과 밝은 chrome이 충돌하므로)

**근거**: Code는 "복사해서 쓰는 결과물"이라는 메시지를 색 대비로 강화. Mulmaru Mono는 MulmaruMono bundle 투자의 가시적 ROI이기도 함. 라임 그린은 기존 theme의 primary `#5A8A3A`와 동일 계열의 더 밝은 shade.

### R3. PixelCard chrome = 레이어드 border (2px outer + 1px inset highlight)

**레퍼런스**: NES.css의 `box-shadow` 조합으로 구현하는 "raised" 효과. 평면이 아니라 약간 튀어나와 보임.

**결정**:
- 기존 `PixelCard` 단일 2px solid border → **2-layer**:
  - outer: `BorderSide(color: Color(0xFF2A2A2A), width: 2)`
  - inset: 내부에 1px `Color(0xFFFFFFFF30)` top+left 하이라이트
- 구현: `Container`에 outer border + `Padding(1)` + inner `Container`에 top+left `BorderSide` highlight
- 그림자 없음 (Flat pixel 일관성 유지)

```dart
class PixelCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const PixelCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border.fromBorderSide(
          BorderSide(color: Color(0xFF2A2A2A), width: 2),
        ),
      ),
      padding: const EdgeInsets.all(1),
      child: Container(
        padding: padding,
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          border: Border(
            top: BorderSide(color: Color(0x30FFFFFF), width: 1),
            left: BorderSide(color: Color(0x30FFFFFF), width: 1),
          ),
        ),
        child: child,
      ),
    );
  }
}
```

**근거**: 단일 2px solid는 평면적. 레이어드 border는 NES.css의 retro-raised 효과를 값비싼 shadow 없이 구현. 픽셀 게임 UI의 관행이기도 함.

## 비목표 (다시 확인)

- 전면 PixelSlider/PixelTextField 자체 구현 — 0.2+ 로드맵 (튜너 고도화 후 본 패키지로 승격 후보)
- Dark theme toggle — 0.2+
- 비대칭 per-side corner 편집 — 0.2+
- URL 파라미터 공유, 프리셋 갤러리 — 0.2+

## 버전·배포 영향

- **pixel_ui 패키지 무수정**. 튜너는 별도 웹 앱이라 `pubspec.yaml` version bump 없음. pub.dev 배포 트리거 없음.
- `deploy-tuner.yml` 추가로 main push 시 GitHub Pages 자동 배포 가능. 첫 배포 전 사용자가 Settings → Pages → Source를 "GitHub Actions"로 1회 설정 필요.
- README에 Live Tuner 배지 + 링크 추가.

## 결정 요약

| 항목 | 결정 |
|---|---|
| 구조·상태·파일 분해 | 상위 spec 그대로 |
| 스타일 방향 | Hybrid (B) — pixel chrome + Material 컨트롤 |
| 레이아웃 비율 | 좌 30 / 우 70 (preview 지배) |
| Preview 스케일 | 6x (logicalWidth 80 → 480px) |
| Code 패널 | `#1A1A1A` 배경 + `#9CCC65` MulmaruMono |
| PixelCard chrome | 2px outer + 1px inset highlight |
| 본 패키지 version bump | 없음 |
| 배포 | GitHub Pages, `deploy-tuner.yml`, Flutter 3.32.7 |

## 다음 단계

`superpowers:writing-plans`로 M1~M4 마일스톤별 태스크를 가진 구현 계획 작성. R1~R3 파라미터는 해당 마일스톤의 스타일 설정 단계에서 적용.
