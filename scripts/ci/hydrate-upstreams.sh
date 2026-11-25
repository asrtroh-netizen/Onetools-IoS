#!/usr/bin/env bash
# Hydrate gitignored upstream repositories inside GitHub Actions from
# upstreams.lock.json, initialize submodules (CI only), and apply patches/*.patch.
#
# Usage:
#   bash scripts/ci/hydrate-upstreams.sh Clash-Client Swipt
#   bash scripts/ci/hydrate-upstreams.sh all
set -euo pipefail

if [[ "${GITHUB_ACTIONS:-}" != "true" && "${ONETOOLS_ALLOW_LOCAL_HYDRATE:-}" != "1" ]]; then
  echo "Refusing to run hydrate-upstreams.sh outside GitHub Actions (protects local zipball submodules)." >&2
  exit 1
fi

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 <Clash-Client|Clash-Core|Swipt|Swiplets|Feather|zsign|all>..." >&2
  exit 1
fi

targets=("$@")
if [[ "${targets[0]}" == "all" ]]; then
  targets=("Clash-Client" "Swipt" "Feather" "Swiplets")
fi

for name in "${targets[@]}"; do
  read -r url rev < <(
    python3 - "$ROOT/upstreams.lock.json" "$name" <<'PY'
import json, sys
entries = json.loads(open(sys.argv[1], encoding="utf-8").read())
target = sys.argv[2]
for item in entries:
    if item["path"] == target:
        print(item["url"], item["revision"])
        sys.exit(0)
raise SystemExit(f"Unknown upstream in lockfile: {target}")
PY
  )

  echo "==> Hydrating $name ($url @ $rev)"
  repo_dir="$ROOT/$name"
  if [[ ! -d "$repo_dir/.git" ]]; then
    rm -rf "$repo_dir"
    git clone --no-checkout "$url" "$repo_dir"
  fi

  git -C "$repo_dir" fetch --depth=1 origin "$rev" || git -C "$repo_dir" fetch origin "$rev"
  git -C "$repo_dir" checkout -f -B onetools "$rev"

  if [[ -f "$repo_dir/.gitmodules" ]]; then
    echo "==> Initializing submodules for $name"
    git -C "$repo_dir" submodule sync --recursive
    git -C "$repo_dir" submodule update --init --recursive --depth=1 \
      || git -C "$repo_dir" submodule update --init --recursive
  fi

  patch_file="$ROOT/patches/$name.patch"
  if [[ -f "$patch_file" && -s "$patch_file" ]]; then
    echo "==> Applying patches/$name.patch to $name"
    git -C "$repo_dir" apply --index --whitespace=nowarn "$patch_file"
    git -C "$repo_dir" -c user.name="onetools-ci" -c user.email="onetools-ci@users.noreply.github.com" \
      commit -m "Apply OneTools patch ($name)"
  fi

  dirty="$(git -C "$repo_dir" status --porcelain --untracked-files=normal)"
  if [[ -n "$dirty" ]]; then
    echo "FAIL: $name working tree is not clean after hydration:" >&2
    echo "$dirty" >&2
    exit 1
  fi
done
