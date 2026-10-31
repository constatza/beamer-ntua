#!/bin/sh
# Checks the failure guarantees of build-course and release-course in a throwaway repo.
# Uses plain `article` documents and a stub `gh`, so it needs only latexmk and git.
set -eu

scripts=$(CDPATH= cd -- "$(dirname "$0")/../scripts" && pwd)
work=$(mktemp -d "${TMPDIR:-/tmp}/course-tooling.XXXXXX")
trap 'rm -rf "$work"' EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }

tex() { printf '\\documentclass{article}\\begin{document}%s\\end{document}\n' "$1"; }

mkdir -p "$work/origin.git" "$work/course"
git -C "$work/origin.git" init -q --bare
cd "$work/course"
git init -q -b main
git remote add origin "$work/origin.git"
mkdir -p presentations/a exercises/e
tex ok >presentations/a/main.tex
tex sheet >exercises/e/main.tex
tex solutions >exercises/e/answers.tex
printf '[topics.t]\nowner = "presentations/a"\nexercises = ["exercises/e"]\n' >TOPICS.toml
git add -A && git -c user.name=t -c user.email=t@t commit -qm init
git tag v1 && git push -q origin main v1

# 1. good build lists exactly the built PDFs
sh "$scripts/build-course" >/dev/null || fail "good build failed"
want="exercise_e.pdf
exercise_e_answers.pdf
presentation_a.pdf"
[ "$(sort dist/MANIFEST)" = "$(echo "$want" | sort)" ] || fail "manifest: $(cat dist/MANIFEST)"

# 2. a broken source must leave no dist/ and no stale .build PDF
printf '\\documentclass{article}\\begin{document}\\undefinedcommand\\end{document}\n' >presentations/a/main.tex
sh "$scripts/build-course" >/dev/null && fail "broken build reported success"
[ ! -e dist ] || fail "dist/ survived a failed build"
[ ! -e presentations/a/.build/main.pdf ] || fail "stale PDF survived a failed build"
tex ok >presentations/a/main.tex

# 3. TOPICS.toml naming a missing path fails the build
printf '[topics.u]\nowner = "exercises/ghost"\n' >>TOPICS.toml
sh "$scripts/build-course" >/dev/null && fail "dangling TOPICS.toml path accepted"
git checkout -q TOPICS.toml

# 4. release uses a stub gh; answers are excluded by default
sh "$scripts/build-course" >/dev/null || fail "rebuild failed"
mkdir "$work/bin"
cat >"$work/bin/gh" <<'EOF'
#!/bin/sh
echo "$*" >>"$GH_LOG"
[ "$1 $2" = "release edit" ] && [ -n "${GH_FAIL_EDIT:-}" ] && exit 1
exit 0
EOF
chmod +x "$work/bin/gh"
export GH_LOG="$work/gh.log" GITHUB_REPOSITORY=o/r PATH="$work/bin:$PATH"
sh "$scripts/release-course" v1 >/dev/null || fail "release failed"
grep -q 'release create v1 --draft' "$GH_LOG" || fail "release not created as draft"
grep -q 'presentation_a.pdf' "$GH_LOG" || fail "deck asset missing"
! grep -q '_answers.pdf' "$GH_LOG" || fail "answers published by default"
grep -q 'release edit v1 --draft=false' "$GH_LOG" || fail "release not published"

# 5. a failing publish deletes the draft; a missing tag is refused
: >"$GH_LOG"
GH_FAIL_EDIT=1 sh "$scripts/release-course" v1 >/dev/null 2>&1 && fail "failed publish reported success"
grep -q 'release delete v1' "$GH_LOG" || fail "draft not deleted after failure"
sh "$scripts/release-course" v9 >/dev/null 2>&1 && fail "untagged release accepted"

echo "course tooling smoke: ok"
