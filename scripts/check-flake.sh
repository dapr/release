#!/usr/bin/env bash
# Smoke-test the dapr/release flake on the current host (Linux, macOS, or WSL).
# Usage: ./scripts/check-flake.sh
set -euo pipefail

cd "$(dirname "$0")/.."

if ! command -v nix >/dev/null 2>&1; then
  echo "error: nix is not installed or not on PATH" >&2
  echo "       install via https://nixos.org/download or https://zero-to-nix.com" >&2
  exit 1
fi

NIX_FLAGS=(--print-build-logs --extra-experimental-features 'nix-command flakes')

echo "==> nix flake check"
nix "${NIX_FLAGS[@]}" flake check

echo "==> building dev shell"
nix "${NIX_FLAGS[@]}" develop --command true

echo "==> verifying tools in dev shell"
nix "${NIX_FLAGS[@]}" develop --command bash -eu -o pipefail -c '
  printf "  ansible : %s\n" "$(ansible --version | head -n1)"
  printf "  python  : %s\n" "$(python --version)"
  printf "  go      : %s\n" "$(go version)"
  printf "  tofu    : %s\n" "$(tofu version | head -n1)"
  printf "  kubectl : %s\n" "$(kubectl version --client=true -o yaml | awk "/gitVersion/ {print \$2; exit}")"
'

echo "==> ok ($(uname -s) $(uname -m))"
