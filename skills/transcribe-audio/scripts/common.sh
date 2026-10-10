#!/usr/bin/env bash

set -euo pipefail

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

cache_root() {
  if [[ -n "${TRANSCRIBE_AUDIO_HOME:-}" ]]; then
    printf '%s\n' "$TRANSCRIBE_AUDIO_HOME"
  elif [[ "$(uname -s)" == "Darwin" ]]; then
    printf '%s\n' "$HOME/Library/Caches/Codex/transcribe-audio"
  else
    printf '%s\n' "${XDG_CACHE_HOME:-$HOME/.cache}/codex/transcribe-audio"
  fi
}

models_dir() {
  printf '%s/models\n' "$(cache_root)"
}

model_path() {
  printf '%s/ggml-%s.bin\n' "$(models_dir)" "$1"
}

print_models() {
  cat <<'EOF'
Available models:
  tiny.en                 75 MiB    fastest English; lowest accuracy
  base.en                142 MiB    faster English
  small.en               466 MiB    default English; established output
  medium.en              1.5 GiB    more accurate English; slower
  small                  466 MiB    default multilingual option
  medium                 1.5 GiB    more accurate multilingual option
  large-v3-turbo-q5_0    547 MiB    strong quantized multilingual option
EOF
}

model_sha1() {
  case "$1" in
    tiny.en) printf '%s\n' 'c78c86eb1a8faa21b369bcd33207cc90d64ae9df' ;;
    base.en) printf '%s\n' '137c40403d78fd54d454da0f9bd998f78703390c' ;;
    small.en) printf '%s\n' 'db8a495a91d927739e50b3fc1cc4c6b8f6c2d022' ;;
    medium.en) printf '%s\n' '8c30f0e44ce9560643ebd10bbe50cd20eafd3723' ;;
    small) printf '%s\n' '55356645c2b361a969dfd0ef2c5a50d530afd8d5' ;;
    medium) printf '%s\n' 'fd9727b6e1217c2f614f9b698455c4ffd82463b4' ;;
    large-v3-turbo-q5_0) printf '%s\n' 'e050f7970618a659205450ad97eb95a18d69c9ee' ;;
    *) return 1 ;;
  esac
}

validate_model() {
  model_sha1 "$1" >/dev/null 2>&1
}

model_is_english_only() {
  case "$1" in
    *.en|*.en-*) return 0 ;;
    *) return 1 ;;
  esac
}

file_sha1() {
  if command -v shasum >/dev/null 2>&1; then
    shasum "$1" | awk '{print $1}'
  elif command -v sha1sum >/dev/null 2>&1; then
    sha1sum "$1" | awk '{print $1}'
  else
    die "shasum or sha1sum is required to verify model downloads"
  fi
}

verify_model() {
  local model="$1"
  local file="$2"
  local expected
  local actual
  expected="$(model_sha1 "$model")" || return 1
  actual="$(file_sha1 "$file")"
  [[ "$actual" == "$expected" ]]
}
