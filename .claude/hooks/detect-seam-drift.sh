#!/usr/bin/env bash
# detect-seam-drift.sh
#
# Usage:
#   ./detect-seam-drift.sh --full              # Scan all registered seams
#   ./detect-seam-drift.sh --seam SEAM-NNN     # Check one seam by ID
#
# Exit codes:
#   0 — No drift detected
#   1 — Drift detected (see output for details)
#   2 — Usage error or missing prerequisites
#
# Called by:
#   - CI on push to main / integration branch (--full)
#   - Agents before releasing a seam lock (--seam SEAM-NNN)
#
# Protocol doc: .claude/docs/seam-drift-detection.md

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
INTERFACES_FILE="$REPO_ROOT/memory/evergreen/core-interfaces.md"
REPORT_DIR="$REPO_ROOT/production/drift-reports"
DATE="$(date +%Y-%m-%d)"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

usage() {
  echo "Usage: $0 --full | --seam SEAM-NNN"
  exit 2
}

log_warn() { echo "WARN: $*" >&2; }
log_info() { echo "INFO: $*"; }

# Extract all SEAM IDs registered in core-interfaces.md
get_registered_seams() {
  grep -oP '(?<=### )(SEAM-\d+)' "$INTERFACES_FILE" 2>/dev/null || true
}

# Extract the Signature block for a given SEAM-ID
# Prints the raw signature lines between ```...``` following "#### Signature"
get_registered_signature() {
  local seam_id="$1"
  # Use awk to extract lines between the Signature header and its closing ```
  awk -v seam="$seam_id" '
    /^### / { in_seam = ($0 ~ seam) }
    in_seam && /^#### Signature/ { in_sig = 1; next }
    in_sig && /^```/ { if (opened) { exit } else { opened = 1; next } }
    in_sig && opened { print }
  ' "$INTERFACES_FILE"
}

# Search source tree for a function/signal/class matching the first identifier
# in a signature line. Returns "file:linenum:matchedline" or empty.
find_signature_in_source() {
  local first_token="$1"
  # Search .gd, .cs, .cpp, .h files; exclude tests and generated code
  grep -rn --include="*.gd" --include="*.cs" --include="*.cpp" --include="*.h" \
    -l "$first_token" \
    "$REPO_ROOT/src" 2>/dev/null | head -5 || true
}

# ---------------------------------------------------------------------------
# Drift check for a single seam
# ---------------------------------------------------------------------------

check_seam() {
  local seam_id="$1"
  local drift_found=0

  local sig
  sig="$(get_registered_signature "$seam_id")"

  if [ -z "$sig" ]; then
    log_warn "$seam_id has no Signature block — skipped"
    return 0
  fi

  # Extract the primary identifier (first word of first non-empty sig line)
  local first_line
  first_line="$(echo "$sig" | grep -v '^$' | head -1)"
  local primary_token
  primary_token="$(echo "$first_line" | grep -oP '[\w_]+' | head -1)"

  if [ -z "$primary_token" ]; then
    log_warn "$seam_id: could not extract primary token from signature — skipped"
    return 0
  fi

  local found_files
  found_files="$(find_signature_in_source "$primary_token")"

  if [ -z "$found_files" ]; then
    # No source file found — could be unimplemented or file not yet in src/
    log_warn "$seam_id: no source file found containing '$primary_token' — skipped"
    return 0
  fi

  # For each file that contains the primary token, extract the actual signature
  # and do a line-by-line comparison with the registered signature.
  # This is a best-effort heuristic; exact matching requires engine-specific tooling.
  while IFS= read -r src_file; do
    local actual_sig
    actual_sig="$(grep -n "$primary_token" "$src_file" | head -5 || true)"

    # Simple check: does the registered signature text appear verbatim in the file?
    local sig_line
    while IFS= read -r sig_line; do
      [ -z "$sig_line" ] && continue
      # Strip leading whitespace for comparison
      local trimmed
      trimmed="$(echo "$sig_line" | sed 's/^[[:space:]]*//')"
      if ! grep -qF "$trimmed" "$src_file" 2>/dev/null; then
        echo ""
        echo "  [$seam_id]"
        echo "    Registry line not found in source:"
        echo "      Expected: $trimmed"
        echo "      File:     $src_file"
        echo "    Run './detect-seam-drift.sh --seam $seam_id' for details."
        drift_found=1
        break
      fi
    done <<< "$sig"
    [ "$drift_found" -eq 1 ] && break
  done <<< "$found_files"

  return "$drift_found"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

if [ $# -lt 1 ]; then usage; fi

MODE=""
TARGET_SEAM=""

case "$1" in
  --full)  MODE="full" ;;
  --seam)
    MODE="single"
    TARGET_SEAM="${2:-}"
    [ -z "$TARGET_SEAM" ] && usage
    ;;
  *) usage ;;
esac

if [ ! -f "$INTERFACES_FILE" ]; then
  echo "ERROR: $INTERFACES_FILE not found. Cannot run drift detection."
  exit 2
fi

# ---------------------------------------------------------------------------
# Run checks
# ---------------------------------------------------------------------------

total=0
drift_count=0
drift_output=""

if [ "$MODE" = "single" ]; then
  seams=("$TARGET_SEAM")
else
  mapfile -t seams < <(get_registered_seams)
fi

if [ "${#seams[@]}" -eq 0 ]; then
  log_info "No registered seams found in $INTERFACES_FILE — nothing to check."
  exit 0
fi

for seam_id in "${seams[@]}"; do
  total=$((total + 1))
  if ! result="$(check_seam "$seam_id" 2>&1)"; then
    drift_count=$((drift_count + 1))
    drift_output="${drift_output}${result}"
  elif [ -n "$result" ]; then
    # Warnings from check_seam
    echo "$result" >&2
  fi
done

# ---------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------

if [ "$drift_count" -eq 0 ]; then
  echo "OK: $total seam(s) checked, 0 drift items."
  exit 0
else
  echo ""
  echo "DRIFT DETECTED: $drift_count seam(s) out of sync with core-interfaces.md"
  echo "$drift_output"
  echo ""
  echo "See .claude/docs/seam-drift-detection.md for the agent response protocol."

  # Archive report
  mkdir -p "$REPORT_DIR"
  REPORT_FILE="$REPORT_DIR/${DATE}-full-scan.txt"
  {
    echo "Drift scan: $DATE"
    echo "Seams checked: $total"
    echo "Drift items: $drift_count"
    echo ""
    echo "$drift_output"
  } > "$REPORT_FILE"
  echo "Report written to: $REPORT_FILE"

  exit 1
fi
