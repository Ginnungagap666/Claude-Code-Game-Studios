#!/usr/bin/env bash
# detect-design-staleness.sh
#
# Usage:
#   ./detect-design-staleness.sh --full           # Scan all design docs
#   ./detect-design-staleness.sh --doc DESIGN-NNN # Check one doc by ID
#
# Exit codes:
#   0 — No stale docs
#   1 — Stale docs detected (see output for details)
#   2 — Usage error or missing prerequisites
#
# A design doc is stale when:
#   1. A source file matching its covered-paths has been modified, AND
#   2. The doc has not been updated within its staleness-threshold-days, AND
#   3. No active waiver exists in production/design-doc-waivers.md
#
# Protocol doc: .claude/docs/design-doc-staleness.md

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DESIGN_DIR="$REPO_ROOT/design"
WAIVERS_FILE="$REPO_ROOT/production/design-doc-waivers.md"
TODAY="$(date +%Y-%m-%d)"
TODAY_EPOCH="$(date +%s)"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

usage() {
  echo "Usage: $0 --full | --doc DESIGN-NNN"
  exit 2
}

log_warn() { echo "WARN: $*" >&2; }

date_to_epoch() {
  # Cross-platform date parsing (GNU date)
  date -d "$1" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "$1" +%s 2>/dev/null || echo 0
}

days_between() {
  local d1_epoch="$1"
  local d2_epoch="$2"
  echo $(( (d2_epoch - d1_epoch) / 86400 ))
}

# Extract a YAML front-matter field value from a design doc
get_field() {
  local file="$1"
  local field="$2"
  # Match "field: value" between --- markers
  awk -v f="$field" '
    /^---$/ { if (in_fm) exit; in_fm=1; next }
    in_fm && $0 ~ "^" f ":" { sub("^" f ":[ \t]*", ""); print; exit }
  ' "$file"
}

# Extract covered-paths list from front matter (multi-line YAML list)
get_covered_paths() {
  local file="$1"
  awk '
    /^---$/ { if (in_fm) exit; in_fm=1; next }
    in_fm && /^covered-paths:/ { in_paths=1; next }
    in_paths && /^  - / { sub("^  - ", ""); print }
    in_paths && /^[^ ]/ { exit }
  ' "$file"
}

# Check if a waiver is active for a given DESIGN-NNN
has_active_waiver() {
  local doc_id="$1"
  if [ ! -f "$WAIVERS_FILE" ]; then return 1; fi

  # Find waiver block and check Expires date
  awk -v doc="$doc_id" -v today="$TODAY" '
    /^\*\*Applies to\*\*:/ && $0 ~ doc { found=1 }
    found && /^\*\*Expires\*\*:/ {
      match($0, /[0-9]{4}-[0-9]{2}-[0-9]{2}/)
      exp = substr($0, RSTART, RLENGTH)
      if (exp >= today) { print "active"; exit }
      exit
    }
  ' "$WAIVERS_FILE" | grep -q "active"
}

# Get the most recent git modification date for files matching a glob pattern
most_recent_change_date() {
  local pattern="$1"
  # Use git log to find most recent commit touching matching files
  git -C "$REPO_ROOT" log --pretty=format:"%ad" --date=short \
    -- "$REPO_ROOT/$pattern" 2>/dev/null | head -1 || echo ""
}

# ---------------------------------------------------------------------------
# Check one design doc
# ---------------------------------------------------------------------------

check_doc() {
  local doc_file="$1"
  local stale=0

  local doc_id
  doc_id="$(get_field "$doc_file" "doc-id")"
  if [ -z "$doc_id" ]; then
    log_warn "$(basename "$doc_file"): missing doc-id in front matter — skipped"
    return 0
  fi

  local last_reviewed
  last_reviewed="$(get_field "$doc_file" "last-reviewed")"
  if [ -z "$last_reviewed" ]; then
    log_warn "$doc_id: missing last-reviewed in front matter — skipped"
    return 0
  fi

  local threshold_days
  threshold_days="$(get_field "$doc_file" "staleness-threshold-days")"
  threshold_days="${threshold_days:-14}"

  local owner
  owner="$(get_field "$doc_file" "owner")"

  # Get covered paths
  local covered_paths
  mapfile -t covered_paths < <(get_covered_paths "$doc_file")

  if [ "${#covered_paths[@]}" -eq 0 ]; then
    log_warn "$doc_id: no covered-paths defined — skipped"
    return 0
  fi

  # Check if any covered file was modified more recently than last-reviewed
  local last_reviewed_epoch
  last_reviewed_epoch="$(date_to_epoch "$last_reviewed")"

  local most_recent_code_change=""
  for pattern in "${covered_paths[@]}"; do
    local change_date
    change_date="$(most_recent_change_date "$pattern")"
    if [ -n "$change_date" ] && [[ "$change_date" > "$last_reviewed" ]]; then
      most_recent_code_change="$change_date"
      break
    fi
  done

  if [ -z "$most_recent_code_change" ]; then
    # No code changes since last review
    return 0
  fi

  # Code changed — check if it's within the staleness window
  local change_epoch
  change_epoch="$(date_to_epoch "$most_recent_code_change")"
  local days_since
  days_since="$(days_between "$last_reviewed_epoch" "$TODAY_EPOCH")"

  if [ "$days_since" -le "$threshold_days" ]; then
    return 0  # Still within grace period
  fi

  # Stale — check for active waiver
  if has_active_waiver "$doc_id"; then
    return 0  # Waiver is active
  fi

  # Report staleness
  echo ""
  echo "  [$doc_id] $(basename "$doc_file")"
  echo "    Owner:         ${owner:-unknown}"
  echo "    Last reviewed: $last_reviewed"
  echo "    Days stale:    $days_since (threshold: $threshold_days)"
  echo "    Triggered by:  source change on $most_recent_code_change"
  echo "    Action:        Update doc and increment version, or file a waiver"
  return 1
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

if [ $# -lt 1 ]; then usage; fi

MODE=""
TARGET_DOC=""

case "$1" in
  --full) MODE="full" ;;
  --doc)
    MODE="single"
    TARGET_DOC="${2:-}"
    [ -z "$TARGET_DOC" ] && usage
    ;;
  *) usage ;;
esac

if [ ! -d "$DESIGN_DIR" ]; then
  log_warn "$DESIGN_DIR not found — no design docs to check."
  exit 0
fi

# ---------------------------------------------------------------------------
# Collect docs to check
# ---------------------------------------------------------------------------

stale_count=0
total=0

if [ "$MODE" = "single" ]; then
  # Find doc by doc-id field
  mapfile -t doc_files < <(
    grep -rl "doc-id: $TARGET_DOC" "$DESIGN_DIR" --include="*.md" 2>/dev/null || true
  )
  if [ "${#doc_files[@]}" -eq 0 ]; then
    echo "ERROR: No design doc found with doc-id: $TARGET_DOC"
    exit 2
  fi
else
  # All .md files in design/ tree that have a front-matter block
  mapfile -t doc_files < <(
    grep -rl "^doc-id:" "$DESIGN_DIR" --include="*.md" 2>/dev/null || true
  )
fi

if [ "${#doc_files[@]}" -eq 0 ]; then
  echo "INFO: No registered design docs found in $DESIGN_DIR — nothing to check."
  exit 0
fi

stale_output=""
for doc_file in "${doc_files[@]}"; do
  total=$((total + 1))
  if ! result="$(check_doc "$doc_file" 2>&1)"; then
    stale_count=$((stale_count + 1))
    stale_output="${stale_output}${result}"
  elif [ -n "$result" ]; then
    echo "$result" >&2
  fi
done

# ---------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------

if [ "$stale_count" -eq 0 ]; then
  echo "OK: $total design doc(s) checked, 0 stale."
  exit 0
else
  echo ""
  echo "STALENESS DETECTED: $stale_count design doc(s) out of date"
  echo "$stale_output"
  echo ""
  echo "See .claude/docs/design-doc-staleness.md for the agent response protocol."
  exit 1
fi
