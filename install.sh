#!/usr/bin/env bash
set -euo pipefail

REPO="${CLAUDE_CODE_TOKEN_USAGE_DASHBOARD_REPO:-JamesDBartlett3/claude-code-token-usage-dashboard}"
REF="${CLAUDE_CODE_TOKEN_USAGE_DASHBOARD_REF:-main}"
ARCHIVE_URL="${CLAUDE_CODE_TOKEN_USAGE_DASHBOARD_ARCHIVE_URL:-https://github.com/${REPO}/archive/refs/heads/${REF}.tar.gz}"

work_dir="$(mktemp -d "${TMPDIR:-/tmp}/claude-code-token-usage-dashboard-XXXXXX")"
cleanup() {
  rm -rf "$work_dir"
}
trap cleanup EXIT

download() {
  local url="$1"
  local output="$2"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$output"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$output" "$url"
  else
    echo "ERROR: curl or wget is required." >&2
    exit 1
  fi
}

find_python() {
  if command -v python3 >/dev/null 2>&1; then
    command -v python3
    return
  fi
  if command -v python >/dev/null 2>&1; then
    command -v python
    return
  fi
  echo "ERROR: Python 3.10+ is required." >&2
  exit 1
}

echo "Downloading ${REPO} (${REF})..."
archive_path="$work_dir/repo.tar.gz"
download "$ARCHIVE_URL" "$archive_path"

echo "Extracting installer..."
tar -xzf "$archive_path" -C "$work_dir"

installer_path="$(find "$work_dir" -type f -name install.py -print -quit)"
if [[ -z "$installer_path" ]]; then
  echo "ERROR: install.py was not found in the downloaded archive." >&2
  exit 1
fi

python_exe="$(find_python)"
echo "Running installer with ${python_exe}..."
"$python_exe" "$installer_path"
