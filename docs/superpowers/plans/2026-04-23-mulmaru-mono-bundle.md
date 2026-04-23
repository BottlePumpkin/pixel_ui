# Mulmaru Mono Bundle Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship pixel_ui 0.2.1 adding a bundled `MulmaruMono` font family and `PixelText.mulmaruMono(...)` factory, mirroring the existing Proportional API, while validating `publish.yml` end-to-end via the first real tag push.

**Architecture:** Single additive change to a package that already bundles `Mulmaru.ttf` and exposes `PixelText.mulmaru(...)`. The new font ships as a second TTF in `assets/fonts/`, registered as a second entry in the `pubspec.yaml` `flutter.fonts` list. The new factory method is a byte-for-byte sibling of `mulmaru(...)` with `fontFamily` flipped to `'MulmaruMono'`. No internal refactor, no new files beyond the TTF asset and spec/plan docs.

**Tech Stack:** Flutter (SDK `^3.8.0`), Dart, `flutter_test` for unit tests, existing `publish.yml` for release automation.

**Spec:** `docs/superpowers/specs/2026-04-23-mulmaru-mono-bundle-design.md`

**Branch:** `feat/mulmaru-mono` (already active)

---

## File Structure

**Create:**
- `assets/fonts/MulmaruMono.ttf` — TTF binary extracted from upstream v1.0 release. Single responsibility: the font asset Flutter loads at runtime. Not regenerated or touched by any code.

**Modify:**
- `pubspec.yaml` — add a second entry under `flutter.fonts` for the new family; bump `version` 0.2.0 → 0.2.1.
- `lib/src/pixel_text.dart` — add `mulmaruMonoFontFamily` const and `mulmaruMono(...)` factory. File remains the single home of the `PixelText` namespace; no split.
- `test/pixel_text_test.dart` — add a new `group('PixelText.mulmaruMono', …)` with the same 5-case shape as the existing `mulmaru` tests.
- `README.md` — add "Monospaced variant" subsection inside existing `### Typography`; update `## Bundled Font` wording from singular to plural.
- `CHANGELOG.md` — prepend `## 0.2.1 — 2026-04-23` entry with Added section.
- `docs/ROADMAP.md` — mark §D complete; collapse stale Section A (0.1.1) and Section C (CI) per M3/M4 piggyback.

**No new source files.** The `PixelText` class is a static namespace; adding a symmetric factory is an in-place addition, not a new unit. Splitting `pixel_text.dart` into separate Proportional/Mono files would fragment a cohesive namespace for no gain.

---

## Task 1: Add MulmaruMono.ttf asset

**Files:**
- Create: `assets/fonts/MulmaruMono.ttf`

- [ ] **Step 1: Download v1.0 release zip and extract the TTF**

Run from the repo root:

```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui
cd /tmp
curl -fsSL -o MulmaruMono.zip "https://github.com/mushsooni/mulmaru/releases/download/v1.0/MulmaruMono.zip"
unzip -o MulmaruMono.zip MulmaruMono.ttf
mv MulmaruMono.ttf /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui/assets/fonts/MulmaruMono.ttf
rm MulmaruMono.zip
```

- [ ] **Step 2: Verify SHA256 matches spec**

Run:
```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui
shasum -a 256 assets/fonts/MulmaruMono.ttf
```

Expected exact output:
```
34a1641eb4e94449b26192321e8e0c2bd4f07ef3674fac8abed33d8953a7f70d  assets/fonts/MulmaruMono.ttf
```

If the hash differs, the upstream release was modified or the download was corrupted. Stop and investigate — do NOT proceed with a mismatched hash.

- [ ] **Step 3: Verify file size and rough sanity**

Run:
```bash
ls -la assets/fonts/MulmaruMono.ttf
file assets/fonts/MulmaruMono.ttf
```

Expected: `-rw-r--r-- ... 1583396 ... assets/fonts/MulmaruMono.ttf` and `TrueType Font data` (or similar) from `file`.

- [ ] **Step 4: Commit**

```bash
git add assets/fonts/MulmaruMono.ttf
git commit -m "feat: bundle MulmaruMono.ttf from mushsooni/mulmaru v1.0 release"
```

---

## Task 2: Register MulmaruMono family in pubspec.yaml

**Files:**
- Modify: `pubspec.yaml:42-46`

Do NOT bump `version` yet. Version bump ships together with CHANGELOG in Task 6 so the two changes cannot diverge.

- [ ] **Step 1: Add the new font family**

Edit `pubspec.yaml`. The existing `flutter` section (lines 42-46) currently reads:

```yaml
flutter:
  fonts:
    - family: Mulmaru
      fonts:
        - asset: assets/fonts/Mulmaru.ttf
```

Replace with:

```yaml
flutter:
  fonts:
    - family: Mulmaru
      fonts:
        - asset: assets/fonts/Mulmaru.ttf
    - family: MulmaruMono
      fonts:
        - asset: assets/fonts/MulmaruMono.ttf
```

- [ ] **Step 2: Verify pub get still resolves**

Run:
```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui
fvm flutter pub get
```

Expected: `Got dependencies!` (or `Resolving dependencies...` followed by `Got dependencies!`), no asset errors.

- [ ] **Step 3: Verify the font is discoverable via `dart pub publish --dry-run`**

Run:
```bash
fvm dart pub publish --dry-run 2>&1 | tail -20
```

Expected: the output ends with `Package has 0 warnings.` AND the file list near the top includes `assets/fonts/MulmaruMono.ttf`. If warnings about missing assets or unknown files appear, stop and fix.

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml
git commit -m "feat: register MulmaruMono font family in pubspec"
```

---

## Task 3: Add PixelText.mulmaruMono() API (TDD)

**Files:**
- Modify: `test/pixel_text_test.dart`
- Modify: `lib/src/pixel_text.dart`

- [ ] **Step 1: Write the failing tests**

Add the following `group` block to `test/pixel_text_test.dart` immediately after the existing `group('PixelText namespace', …)` closing brace (line 58), inside the `main()` function (before its closing brace on line 59):

```dart
  group('PixelText.mulmaruMono', () {
    test('mulmaruMonoFontFamily constant is MulmaruMono', () {
      expect(PixelText.mulmaruMonoFontFamily, 'MulmaruMono');
    });

    test('mulmaruMono() returns TextStyle with MulmaruMono font settings', () {
      final style = PixelText.mulmaruMono(fontSize: 20, color: const Color(0xFFAA0000));
      expect(style.fontFamily, 'MulmaruMono');
      expect(style.fontSize, 20);
      expect(style.color, const Color(0xFFAA0000));
      expect(style.height, 1.0);
      expect(style.shadows, isNull);
    });

    test('mulmaruMono() applies single shadow when shadowColor given', () {
      final style = PixelText.mulmaruMono(
        shadowColor: const Color(0xFF000000),
        shadowOffset: const Offset(2, 2),
      );
      expect(style.shadows, hasLength(1));
      expect(style.shadows!.first.offset, const Offset(2, 2));
      expect(style.shadows!.first.color, const Color(0xFF000000));
    });

    test('mulmaruMono() omits shadows when neither shadowColor nor shadows given', () {
      final style = PixelText.mulmaruMono();
      expect(style.shadows, isNull);
    });

    test('mulmaruMono() uses explicit shadows list over shadowColor', () {
      const customShadows = [
        Shadow(offset: Offset(3, 3), color: Color(0xFFFF0000)),
        Shadow(offset: Offset(1, 1), color: Color(0xFF00FF00)),
      ];
      final style = PixelText.mulmaruMono(
        shadowColor: const Color(0xFF000000),
        shadows: customShadows,
      );
      expect(style.shadows, equals(customShadows));
    });

    test('mulmaruMono() passes through fontWeight and letterSpacing', () {
      final style = PixelText.mulmaruMono(
        fontWeight: FontWeight.w500,
        letterSpacing: 3.4,
      );
      expect(style.fontWeight, FontWeight.w500);
      expect(style.letterSpacing, 3.4);
    });
  });
```

- [ ] **Step 2: Run the new tests to verify they fail**

Run:
```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui
fvm flutter test test/pixel_text_test.dart -r expanded
```

Expected: the 6 new tests inside `group('PixelText.mulmaruMono', ...)` all FAIL with compile errors referencing undefined `PixelText.mulmaruMonoFontFamily` / `PixelText.mulmaruMono`. The existing `PixelText namespace` group (7 tests) continues to pass. Do not proceed until failures are confirmed to be "method not defined" (not some other compilation issue).

- [ ] **Step 3: Add the API in lib/src/pixel_text.dart**

Open `lib/src/pixel_text.dart`. Add the following block inside the `abstract class PixelText { … }` body, placed immediately after the existing `mulmaru(...)` method's closing brace (the file's last `}` before the class close — around line 56):

```dart
  /// Font family name of the bundled Mulmaru Mono (monospaced) font.
  static const String mulmaruMonoFontFamily = 'MulmaruMono';

  /// Returns a [TextStyle] configured for the bundled Mulmaru Mono pixel font.
  ///
  /// Identical semantics to [mulmaru] — see that method for shadow resolution
  /// rules and default justification.
  static TextStyle mulmaruMono({
    double fontSize = 16,
    Color color = const Color(0xFF000000),
    Color? shadowColor,
    Offset shadowOffset = const Offset(1, 1),
    double height = 1.0,
    FontWeight? fontWeight,
    double? letterSpacing,
    List<Shadow>? shadows,
  }) {
    final resolvedShadows = shadows ??
        (shadowColor != null
            ? <Shadow>[Shadow(offset: shadowOffset, color: shadowColor)]
            : null);

    return TextStyle(
      fontFamily: mulmaruMonoFontFamily,
      package: mulmaruPackage,
      fontSize: fontSize,
      color: color,
      height: height,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      shadows: resolvedShadows,
    );
  }
```

- [ ] **Step 4: Run tests to verify they all pass**

Run:
```bash
fvm flutter test test/pixel_text_test.dart -r expanded
```

Expected: all 13 tests pass (7 existing + 6 new). No failures, no skipped.

- [ ] **Step 5: Run analyze to confirm no lints regressed**

Run:
```bash
fvm flutter analyze
```

Expected: `No issues found!` or equivalent exit 0 output.

- [ ] **Step 6: Commit**

```bash
git add lib/src/pixel_text.dart test/pixel_text_test.dart
git commit -m "feat: add PixelText.mulmaruMono() factory mirroring mulmaru()"
```

---

## Task 4: Update README.md (Typography section + Bundled Font wording)

**Files:**
- Modify: `README.md:127-146` (Typography section) and `README.md:167-171` (Bundled Font section)

- [ ] **Step 1: Append Monospaced variant subsection to Typography**

Locate line 146 in `README.md`, the closing triple-backtick of the existing Typography code block. The current content from line 127 is:

```markdown
### Typography

The package bundles the Mulmaru proportional pixel font. Use the factory helper:

[triple-backtick]dart
Text('달려라', style: PixelText.mulmaru(fontSize: 20, color: Colors.white));
[triple-backtick]

Or compose a custom `TextStyle` using the exposed constants:

[triple-backtick]dart
Text(
  'hello',
  style: TextStyle(
    fontFamily: PixelText.mulmaruFontFamily,
    package: PixelText.mulmaruPackage,
    fontSize: 18,
  ),
);
[triple-backtick]
```

Insert a blank line after line 146's closing ``` then append:

```markdown

#### Monospaced variant

For code, terminal-style UI, or fixed-width layouts, use `PixelText.mulmaruMono`:

[triple-backtick]dart
Text(
  'HP 042/100',
  style: PixelText.mulmaruMono(fontSize: 12, color: Colors.white),
)
[triple-backtick]
```

(Replace `[triple-backtick]` with literal triple backticks in the file.)

- [ ] **Step 2: Update Bundled Font section wording to plural**

Locate `README.md:169`:

```
This package bundles the [Mulmaru](https://github.com/mushsooni/mulmaru) pixel font by **mushsooni**, distributed under the SIL Open Font License 1.1.
```

Replace with:

```
This package bundles the [Mulmaru](https://github.com/mushsooni/mulmaru) pixel fonts (proportional + monospaced variants) by **mushsooni**, distributed under the SIL Open Font License 1.1.
```

- [ ] **Step 3: Verify README edits locally**

Run:
```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui
grep -n "Monospaced variant" README.md
grep -n "proportional + monospaced variants" README.md
```

Expected: both commands print exactly one matching line.

- [ ] **Step 4: Commit**

```bash
git add README.md
git commit -m "docs(README): add Mono variant example and update Bundled Font wording"
```

---

## Task 5: Update docs/ROADMAP.md (§D complete + M3/M4 piggyback)

**Files:**
- Modify: `docs/ROADMAP.md`

This task makes three coordinated edits to the ROADMAP: mark §D done, collapse the stale 0.1.1 section (M3), and update Section C's CI description (M4). Do them in one commit.

- [ ] **Step 1: Collapse Section A (0.1.1 — already shipped) [M3]**

Open `docs/ROADMAP.md`. Find the heading `## 🎯 0.1.1 — 가장 가까운 다음 배포` (around line 11) and replace the entire section (from that heading through the `---` separator before `## 🎯 0.2.0 — 중기 로드맵`) with:

```markdown
## ✅ 0.1.1 — 완료 (2026-04-22)

- pub.dev 리스팅에 스크린샷 5장 추가 (hero · corners · shadows · buttons · texture)
- README `## Gallery` 섹션 + `doc/screenshots/` 자산 추가
- `tool/update_screenshots.sh`로 골든 기반 재생성 자동화

배포는 `CHANGELOG.md`의 0.1.1 엔트리 참조.

---
```

- [ ] **Step 2: Collapse Section C (CI workflow — already shipped) [M4]**

Find the heading `### C. CI 워크플로우 추가` inside the `## 🎯 0.2.0 — 중기 로드맵` section (around line 91) and replace the entire subsection (from `### C. CI 워크플로우 추가` through the final line of its yaml block and any closing prose, up to but NOT including `### D. Mulmaru Mono 번들 추가`) with:

```markdown
### ✅ C. CI 워크플로우 — 완료

- PR #1: `.github/workflows/test.yml` (analyze + test + `dart pub publish --dry-run` on push/PR)
- PR #1: `PixelShapePainter` 골든 테스트 스위트 (`test/pixel_shape_painter_golden_test.dart`)
- Platform build matrix: `.github/workflows/build.yml` (6 OS/target 조합)
- PR #2: `.github/workflows/publish.yml` (태그 push 시 OIDC 자동 배포 + GitHub Release)

이후 모든 배포는 publish.yml 태그 트리거로 진행.

```

- [ ] **Step 3: Mark Section D (Mulmaru Mono bundle) complete**

Find the heading `### D. Mulmaru Mono 번들 추가` (now around line ~95 after the Section C collapse). Replace the heading line with:

```markdown
### ✅ D. Mulmaru Mono 번들 — 완료 (0.2.1, 2026-04-23)
```

Leave the rest of Section D's body (the detailed work plan) intact as a historical record — it documents the approach taken.

- [ ] **Step 4: Update the "우선순위 제안" list**

Find the `## 우선순위 제안` section near the end of the file. Replace the numbered list with:

```markdown
1. ~~A (스크린샷 0.1.1)~~ — 완료
2. ~~C (CI)~~ — 완료 (test.yml + publish.yml + build.yml)
3. ~~D (Mulmaru Mono)~~ — 완료 (0.2.1)
4. **E (골든 테스트)** — 이미 부분 도입 (PixelShapePainter), 스크린샷 자동화와 연계 고려
5. F (스크린샷 자동화) — 릴리스 주기 확립 후
6. G (플랫폼 확장) — 1.0 직전 마지막 준비
```

- [ ] **Step 5: Verify ROADMAP edits**

Run:
```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui
grep -c "^## ✅ 0.1.1" docs/ROADMAP.md
grep -c "^### ✅ C. CI 워크플로우" docs/ROADMAP.md
grep -c "^### ✅ D. Mulmaru Mono" docs/ROADMAP.md
```

Expected: each command returns `1`.

- [ ] **Step 6: Commit**

```bash
git add docs/ROADMAP.md
git commit -m "docs(ROADMAP): mark 0.1.1/CI/Mulmaru Mono complete; prune stale procedure blocks"
```

---

## Task 6: Version bump + CHANGELOG + final sanity

**Files:**
- Modify: `pubspec.yaml:4` (version line)
- Modify: `CHANGELOG.md` (prepend new entry)

Do NOT split these. `pubspec.yaml` version and CHANGELOG top entry must land together to keep pub.dev Versions tab and the published version in sync.

- [ ] **Step 1: Bump pubspec.yaml version**

Edit `pubspec.yaml`. Change line 4 from:

```yaml
version: 0.2.0
```

to:

```yaml
version: 0.2.1
```

- [ ] **Step 2: Prepend CHANGELOG entry**

Open `CHANGELOG.md`. The file starts with `# Changelog` then a blank line then `## 0.2.0 — 2026-04-23`. Insert a new section between the `# Changelog` heading and `## 0.2.0`:

```markdown
## 0.2.1 — 2026-04-23

### Added
- Bundled `MulmaruMono` font family (SIL OFL 1.1) for code, terminal-style UI, and fixed-width layouts.
- `PixelText.mulmaruMono(...)` factory and `PixelText.mulmaruMonoFontFamily` constant. Signature identical to `PixelText.mulmaru(...)`.

### Notes
- Font source: [mushsooni/mulmaru v1.0 release](https://github.com/mushsooni/mulmaru/releases/tag/v1.0). SHA256 `34a1641eb4e94449b26192321e8e0c2bd4f07ef3674fac8abed33d8953a7f70d`.

```

The blank line between this new section and the existing `## 0.2.0` must be preserved.

- [ ] **Step 3: Run full local sanity — analyze + test + dry-run**

Run:
```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui
fvm flutter analyze
fvm flutter test --exclude-tags screenshot
fvm dart pub publish --dry-run
```

Expected:
- `flutter analyze`: `No issues found!`
- `flutter test --exclude-tags screenshot`: `All tests passed!` (13 tests in pixel_text_test.dart plus whatever else is in the suite)
- `dart pub publish --dry-run`: the final line is `Package has 0 warnings.` The asset list includes `assets/fonts/MulmaruMono.ttf`.

If any fails, fix before proceeding. These are the exact same gates `publish.yml` will run after the tag push, so a local pass predicts a CI pass.

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml CHANGELOG.md
git commit -m "chore: bump version to 0.2.1"
```

---

## Task 7: Push branch + open PR

**Files:** None modified — delivery step.

- [ ] **Step 1: Verify local state is clean and branch is ahead of main**

Run:
```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui
git status
git log --oneline origin/main..HEAD
```

Expected: `git status` shows "nothing to commit, working tree clean". The log shows 7 commits (spec + 6 task commits): design spec, font asset, pubspec font registration, API + tests, README, ROADMAP, version bump.

If any commits are missing or the tree is dirty, do not proceed — resolve first.

- [ ] **Step 2: Push the branch**

Run:
```bash
git push -u origin feat/mulmaru-mono
```

Expected: push succeeds; remote branch `feat/mulmaru-mono` created.

- [ ] **Step 3: Open PR**

Run:
```bash
gh pr create --title "feat: bundle MulmaruMono font and add PixelText.mulmaruMono() (v0.2.1)" --body "$(cat <<'EOF'
## Summary
- Bundle `MulmaruMono.ttf` (from [mushsooni/mulmaru v1.0](https://github.com/mushsooni/mulmaru/releases/tag/v1.0)) alongside the existing proportional `Mulmaru.ttf`.
- Add `PixelText.mulmaruMono(...)` factory + `PixelText.mulmaruMonoFontFamily` constant with signature identical to `PixelText.mulmaru(...)`.
- Bump `pubspec.yaml` version 0.2.0 → 0.2.1 (non-breaking; Dart pre-1.0 convention auto-picks up under `^0.2.0`).
- Piggyback doc cleanup: mark 0.1.1, Section C (CI), and Section D (Mono) complete in `docs/ROADMAP.md`; prune stale manual-publish procedure blocks left over from pre-publish.yml era.

Spec: `docs/superpowers/specs/2026-04-23-mulmaru-mono-bundle-design.md`
Plan: `docs/superpowers/plans/2026-04-23-mulmaru-mono-bundle.md`

## What validates post-merge
This release is the **first real tag push** through the new `.github/workflows/publish.yml` (merged in #2). The tag `v0.2.1` will trigger OIDC auth → analyze → test → dry-run → pub.dev duplicate guard → `dart pub publish --force` → `gh release create`. If any step fails, pub.dev stays at 0.2.0 and the failure is recoverable.

## Font provenance
- Source: https://github.com/mushsooni/mulmaru/releases/download/v1.0/MulmaruMono.zip
- SHA256: `34a1641eb4e94449b26192321e8e0c2bd4f07ef3674fac8abed33d8953a7f70d`
- Size: 1,583,396 bytes
- License: SIL OFL 1.1 (same as existing `Mulmaru.ttf`, covered by existing `OFL.txt`)

## Test plan
- [x] `fvm flutter analyze` — 0 issues
- [x] `fvm flutter test --exclude-tags screenshot` — all 13 pixel_text tests pass (7 existing + 6 new)
- [x] `fvm dart pub publish --dry-run` — 0 warnings, `assets/fonts/MulmaruMono.ttf` in file list
- [ ] Post-merge: tag `v0.2.1` push triggers `publish.yml`, new version appears on https://pub.dev/packages/pixel_ui, GitHub Release `v0.2.1` created with auto-generated notes.
EOF
)"
```

Expected: PR URL printed. The PR will show ~10 commits (spec commit from feat/publish-automation if present + 7 new commits on this branch).

- [ ] **Step 4: Do NOT tag yet**

The tag `v0.2.1` MUST be created AFTER the PR merges to main. Creating the tag on this feature branch would push it to origin where the workflow would fire on a branch that hasn't been reviewed. This is deferred to Task 8.

Report back with the PR URL and wait for user review / merge decision.

---

## Task 8: Post-merge — tag v0.2.1 and validate automation

**Files:** None modified — release trigger.

**Prerequisite:** PR from Task 7 is squash-merged to `main` via GitHub UI or `gh pr merge`. The merge commit subject should follow the repo convention (e.g., `feat: bundle MulmaruMono font and add PixelText.mulmaruMono() (v0.2.1) (#N)`).

- [ ] **Step 1: Sync local main**

Run:
```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui
git checkout main
git pull --ff-only origin main
```

Expected: `main` now includes the squash-merged commit from the PR. `git log -1 --oneline` shows the merge subject.

- [ ] **Step 2: Verify merged version is 0.2.1**

Run:
```bash
grep '^version:' pubspec.yaml
```

Expected: `version: 0.2.1`. If it shows 0.2.0, the merge lost the bump — stop and investigate.

- [ ] **Step 3: Create annotated tag**

Run:
```bash
git tag -a v0.2.1 -m "v0.2.1 — bundle Mulmaru Mono"
```

Expected: no output (success).

- [ ] **Step 4: Push the tag**

Run:
```bash
git push origin v0.2.1
```

Expected: push succeeds. Immediately after, visit https://github.com/BottlePumpkin/pixel_ui/actions — the `Publish to pub.dev` workflow should show a new running job within ~5 seconds.

- [ ] **Step 5: Monitor the workflow**

Run:
```bash
gh run watch
```

Or visit the Actions tab in the browser. Expected sequence of step statuses:
- Checkout ✓
- Flutter setup ✓
- Verify tag matches pubspec version ✓ (0.2.1 == 0.2.1)
- Pub get ✓
- Analyze ✓
- Test (exclude screenshot goldens) ✓
- Publish dry-run ✓
- Guard against re-publish ✓ (0.2.1 is new)
- Publish ✓ (this is the first real OIDC publish — watch for auth errors)
- Create GitHub Release ✓

If the job succeeds, proceed to Step 6. If it fails:
- Before Publish step: tag can be deleted and re-pushed after fixing (`git tag -d v0.2.1 && git push origin :refs/tags/v0.2.1` locally/remotely, then re-tag).
- At Publish step: pub.dev may or may not have the version. Check https://pub.dev/packages/pixel_ui versions page. If 0.2.1 is up, skip to Step 6 and manually run `gh release create v0.2.1 --generate-notes`. If not, investigate OIDC config then re-tag.

- [ ] **Step 6: Verify pub.dev and GitHub Release**

Visit:
- https://pub.dev/packages/pixel_ui — version badge should show `0.2.1` (shields.io cache may take ~5 min).
- https://pub.dev/packages/pixel_ui/versions — `0.2.1` listed with today's date.
- https://pub.dev/packages/pixel_ui/changelog — 0.2.1 entry renders with the Added/Notes sections.
- https://github.com/BottlePumpkin/pixel_ui/releases/tag/v0.2.1 — Release exists with auto-generated notes.

- [ ] **Step 7: Smoke test the bundled Mono font in the example app**

Optional but recommended — visually confirm the new font works end-to-end.

Run:
```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui/example
fvm flutter pub upgrade pixel_ui
```

Expected: example's `pubspec.lock` now pins `pixel_ui: 0.2.1` (or whichever newest). Then:
```bash
fvm flutter run -d "iPhone 15 Pro"
```

Use the showcase to eyeball — if the example has no Mono example yet, you can just confirm the app still runs without missing-font errors. No code change needed in `example/` for this release.

- [ ] **Step 8: Report completion**

Summarize:
- `v0.2.1` tag pushed, workflow green, pub.dev shows 0.2.1, GitHub Release created.
- `publish.yml` validated end-to-end on its first real run.
- If any issue surfaced (expected: none), record it for a follow-up hardening PR.

This closes the Mulmaru Mono bundle project.
