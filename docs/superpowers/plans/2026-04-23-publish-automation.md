# Publish Automation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a tag-triggered GitHub Actions workflow that runs quality gates, publishes to pub.dev via OIDC, and creates a GitHub Release automatically.

**Architecture:** Single workflow file (`.github/workflows/publish.yml`) fires on `v*.*.*` tag push. Steps run in order: flutter setup → tag↔pubspec version check → `pub get` → `analyze` → `test --exclude-tags screenshot` → `dart pub publish --dry-run` → re-publish guard (pub.dev API lookup) → `dart pub publish --force` → `gh release create --generate-notes`. Any earlier step failure prevents the actual publish call, so pub.dev state is only touched after all gates pass.

**Tech Stack:** GitHub Actions, `subosito/flutter-action@v2` (Flutter 3.32.7), `dart pub publish` (OIDC via `id-token: write`), `gh` CLI.

**Spec:** `docs/superpowers/specs/2026-04-23-publish-automation-design.md`

**Branch:** `feat/publish-automation` (already active)

---

## File Structure

**Create:**
- `.github/workflows/publish.yml` — the new tag-triggered publish workflow. Single responsibility: run quality gates and publish pixel_ui to pub.dev on `v*.*.*` tag push.

**Modify:**
- `CLAUDE.md` — replace the "배포 리듬 (버전 bump 시)" section (lines 37-53) with the new automated rhythm.
- `docs/ROADMAP.md` — replace the "공통 배포 리듬 (모든 버전 공통)" section (lines 324-340) with a terse version that points to CLAUDE.md.

**No test files.** Workflow logic that needs verification (tag-vs-pubspec check, pub.dev API guard) is tested inline as shell scripts during Task 1. The workflow itself can only be end-to-end validated by an actual tag push, which happens on the next real release per the spec.

---

## Task 1: Create publish.yml workflow file

**Files:**
- Create: `.github/workflows/publish.yml`

**Rationale for one-task scope:** A workflow YAML is a single cohesive unit — splitting by section would create incomplete files that fail to parse. Instead, write the whole file, then validate parse and test the embedded shell logic locally before committing.

- [ ] **Step 1: Create the workflow file**

Write `.github/workflows/publish.yml` with this exact content:

```yaml
name: Publish to pub.dev
run-name: "Publish ${{ github.ref_name }}"

on:
  push:
    tags:
      - 'v[0-9]+.[0-9]+.[0-9]+*'

jobs:
  publish:
    runs-on: ubuntu-latest
    permissions:
      id-token: write   # pub.dev OIDC
      contents: write   # gh release create
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.32.7'
          channel: 'stable'

      - name: Verify tag matches pubspec version
        run: |
          TAG_VERSION="${GITHUB_REF_NAME#v}"
          FILE_VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
          if [ "$TAG_VERSION" != "$FILE_VERSION" ]; then
            echo "::error::Tag $GITHUB_REF_NAME does not match pubspec.yaml version ($FILE_VERSION)"
            exit 1
          fi
          echo "Tag $GITHUB_REF_NAME matches pubspec.yaml version"

      - name: Pub get
        run: flutter pub get

      - name: Analyze
        run: flutter analyze

      - name: Test (exclude screenshot goldens)
        run: flutter test --exclude-tags screenshot

      - name: Publish dry-run
        run: dart pub publish --dry-run

      - name: Guard against re-publish
        run: |
          TAG_VERSION="${GITHUB_REF_NAME#v}"
          if curl -fsSL "https://pub.dev/api/packages/pixel_ui" \
             | grep -q "\"version\":\"$TAG_VERSION\""; then
            echo "::error::Version $TAG_VERSION already published on pub.dev"
            exit 1
          fi
          echo "Version $TAG_VERSION not yet on pub.dev, proceeding"

      - name: Publish
        run: dart pub publish --force

      - name: Create GitHub Release
        run: gh release create "$GITHUB_REF_NAME" --generate-notes --title "$GITHUB_REF_NAME"
        env:
          GH_TOKEN: ${{ github.token }}
```

- [ ] **Step 2: Validate YAML parses**

Run:
```bash
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/publish.yml'))" && echo "YAML ok"
```

Expected output: `YAML ok`

If it fails, fix the syntax error before proceeding.

- [ ] **Step 3: Test the tag↔pubspec version check logic locally**

This verifies the shell script inside the "Verify tag matches pubspec version" step behaves correctly for both match and mismatch cases.

Run:
```bash
cd ~/dev/byeonghopark/pixel_ui
CURRENT=$(grep '^version:' pubspec.yaml | awk '{print $2}')
echo "pubspec version: $CURRENT"

# Positive case: tag matches pubspec
GITHUB_REF_NAME="v$CURRENT"
TAG_VERSION="${GITHUB_REF_NAME#v}"
FILE_VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
[ "$TAG_VERSION" = "$FILE_VERSION" ] && echo "MATCH ok" || echo "MATCH FAILED"

# Negative case: tag mismatches pubspec
GITHUB_REF_NAME="v99.99.99"
TAG_VERSION="${GITHUB_REF_NAME#v}"
FILE_VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
[ "$TAG_VERSION" != "$FILE_VERSION" ] && echo "MISMATCH detected ok" || echo "MISMATCH FAILED"
```

Expected output (exact lines, `$CURRENT` substituted):
```
pubspec version: 0.2.0
MATCH ok
MISMATCH detected ok
```

If either line is not "ok", the shell logic is wrong — fix and re-run.

- [ ] **Step 4: Test the re-publish guard logic against live pub.dev**

This verifies the curl+grep against pub.dev's API correctly detects an existing version and correctly reports a non-existing version. Uses the live API because the format is stable.

Run:
```bash
# Positive case: 0.2.0 is already published
TAG_VERSION="0.2.0"
curl -fsSL "https://pub.dev/api/packages/pixel_ui" \
  | grep -q "\"version\":\"$TAG_VERSION\"" && echo "EXISTING detected ok" || echo "EXISTING FAILED"

# Negative case: 99.99.99 does not exist
TAG_VERSION="99.99.99"
curl -fsSL "https://pub.dev/api/packages/pixel_ui" \
  | grep -q "\"version\":\"$TAG_VERSION\"" && echo "FALSE POSITIVE" || echo "NONEXISTENT ok"

# Substring-match regression: 0.2.0 must not match "0.2.00" or similar partial
TAG_VERSION="0.2"
curl -fsSL "https://pub.dev/api/packages/pixel_ui" \
  | grep -q "\"version\":\"$TAG_VERSION\"" && echo "SUBSTRING BUG" || echo "NO SUBSTRING MATCH ok"
```

Expected output:
```
EXISTING detected ok
NONEXISTENT ok
NO SUBSTRING MATCH ok
```

If any line shows FAILED, FALSE POSITIVE, or SUBSTRING BUG, the grep pattern is wrong — the closing `\"` in `"\"version\":\"$TAG_VERSION\""` is what prevents substring false matches. Fix and re-run.

- [ ] **Step 5: Commit**

Run:
```bash
git add .github/workflows/publish.yml
git commit -m "ci: add tag-triggered publish workflow with OIDC"
```

---

## Task 2: Update CLAUDE.md release rhythm section

**Files:**
- Modify: `CLAUDE.md` (the "배포 리듬 (버전 bump 시)" section)

- [ ] **Step 1: Replace the release rhythm section**

Open `CLAUDE.md`. Find the section that starts with `## 배포 리듬 (버전 bump 시)` and ends just before `## 파일 무결성 규칙`.

Replace the entire section (from `## 배포 리듬 (버전 bump 시)` up to but not including `## 파일 무결성 규칙`) with the following markdown (quadruple-backtick fence here is just this plan's wrapper — paste the contents between the fences, preserving the inner triple-backtick ```text``` block):

````markdown
## 배포 리듬 (버전 bump 시)

배포는 `v*.*.*` 태그 push 시 `.github/workflows/publish.yml`이 자동 수행한다. 수동 publish 명령은 실행하지 않는다.

```text
1. 코드 변경 → 테스트 추가/업데이트
2. (선택) 로컬 빠른 피드백: fvm flutter analyze && fvm flutter test --exclude-tags screenshot
3. pubspec.yaml version bump + CHANGELOG.md 엔트리 맨 위 추가
4. git commit -am "chore: bump version to X.Y.Z"
5. git tag -a vX.Y.Z -m "vX.Y.Z — summary"
6. git push origin main vX.Y.Z        # publish.yml 자동 시작
7. Actions 탭에서 워크플로 성공 확인
8. https://pub.dev/packages/pixel_ui 에서 새 버전·README·CHANGELOG 렌더링 확인
```

**자동 실행되는 검증**: tag↔pubspec 버전 일치 → `flutter analyze` → `flutter test --exclude-tags screenshot` → `dart pub publish --dry-run` → pub.dev 중복 배포 차단 → `dart pub publish --force` → `gh release create --generate-notes`.

**원칙**: `dart pub publish`는 취소 불가 (30일 retract만). CHANGELOG와 version bump를 신중히 검토한 뒤 태그 push.

**OIDC 인증**: `.github/workflows/publish.yml`의 `permissions: id-token: write`와 pub.dev Admin 탭의 Automated publishing 설정(`BottlePumpkin/pixel_ui`, tag pattern `v{{version}}`)이 함께 동작. 로컬 `pub-credentials.json` 의존성 없음.
````

- [ ] **Step 2: Verify the replacement**

Run:
```bash
grep -A 2 "^## 배포 리듬" CLAUDE.md | head -5
grep -c "pub-credentials.json" CLAUDE.md
```

Expected: the first command shows the new section header. The second command returns `0` (the old credentials-check step is gone).

- [ ] **Step 3: Commit**

Run:
```bash
git add CLAUDE.md
git commit -m "docs(CLAUDE): replace manual release rhythm with publish.yml automation"
```

---

## Task 3: Update ROADMAP.md release rhythm section

**Files:**
- Modify: `docs/ROADMAP.md` (the "🛠 공통 배포 리듬 (모든 버전 공통)" section)

- [ ] **Step 1: Replace the 공통 배포 리듬 section**

Open `docs/ROADMAP.md`. Find the section that starts with `## 🛠 공통 배포 리듬 (모든 버전 공통)` and ends just before `## ⚠️ 잠재 함정`.

Replace the entire section (from the heading through the closing `---` separator, up to but not including `## ⚠️ 잠재 함정`) with the following markdown (quadruple-backtick fence here is just this plan's wrapper — paste the contents between the fences, preserving the inner triple-backtick ```text``` block):

````markdown
## 🛠 공통 배포 리듬 (모든 버전 공통)

`.github/workflows/publish.yml`이 태그 push를 감지해 자동 배포한다. 요약:

```text
1. 코드 변경 + 테스트
2. pubspec.yaml version bump + CHANGELOG.md 엔트리
3. git commit → git tag -a vX.Y.Z → git push origin main vX.Y.Z
4. Actions 탭에서 성공 확인 → pub.dev 렌더링 확인
```

자동으로 실행되는 게이트·세부 절차·OIDC 구성은 `CLAUDE.md`의 "배포 리듬" 섹션 참조.

---
````

- [ ] **Step 2: Verify the replacement**

Run:
```bash
grep -A 2 "^## 🛠 공통 배포 리듬" docs/ROADMAP.md | head -5
grep -c "pub-credentials.json" docs/ROADMAP.md
```

Expected: the first command shows the new terse section. The second command returns `0`.

- [ ] **Step 3: Commit**

Run:
```bash
git add docs/ROADMAP.md
git commit -m "docs(ROADMAP): point release rhythm to CLAUDE.md + publish.yml"
```

---

## Task 4: Push branch and open PR

**Files:** None modified — this is the delivery step.

- [ ] **Step 1: Verify local state is clean and branch is ahead of main**

Run:
```bash
git status
git log --oneline origin/main..HEAD
```

Expected: `git status` shows "nothing to commit, working tree clean". The log shows exactly 4 commits (spec + publish.yml + CLAUDE.md + ROADMAP.md).

If any commits are missing or the tree is dirty, do not proceed — resolve first.

- [ ] **Step 2: Push the branch**

Run:
```bash
git push -u origin feat/publish-automation
```

Expected: push succeeds; remote branch `feat/publish-automation` created.

- [ ] **Step 3: Open PR**

Run:
```bash
gh pr create --title "ci: tag-triggered pub.dev publish automation" --body "$(cat <<'EOF'
## Summary
- Add `.github/workflows/publish.yml`: on `v*.*.*` tag push, runs analyze + test + dry-run + pub.dev duplicate guard, then publishes via OIDC and creates a GitHub Release with auto-generated notes.
- Update `CLAUDE.md` and `docs/ROADMAP.md` release rhythm sections to reflect the automated flow (no more local `dart pub publish`, no more credentials email check).

Spec: `docs/superpowers/specs/2026-04-23-publish-automation-design.md`

## Test plan
- [x] YAML parses (`python3 -c "import yaml; yaml.safe_load(...)"`)
- [x] Tag↔pubspec version check: match/mismatch cases verified locally
- [x] pub.dev duplicate guard: existing version detected, nonexistent version passes, no substring false-positive
- [ ] End-to-end: first real tag push after merge validates OIDC, `--force` publish, and `gh release create`. Spec explicitly defers e2e to the next substantive release to avoid a semver-hygiene-breaking empty version bump.
EOF
)"
```

Expected: PR URL printed.

- [ ] **Step 4: Verify the workflow file is visible and parses on GitHub**

Run:
```bash
gh pr view --web
```

In the opened PR page, check the "Files changed" tab — GitHub parses the workflow YAML and will surface errors inline if any. No inline errors = YAML is well-formed per GitHub's parser (stricter than `yaml.safe_load`).

If GitHub shows a parse error, iterate on the file locally and push a fix commit.
