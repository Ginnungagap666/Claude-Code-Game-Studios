#!/usr/bin/env bash
# milestone-archive.sh
#
# Usage: ./milestone-archive.sh <milestone-number>
# Example: ./milestone-archive.sh 3
#
# Called by producer at milestone boundary to archive current-milestone memory
# into memory/archive/milestone-N/ and create fresh current-milestone files.
#
# This script only moves files. All editorial decisions (what to promote to
# evergreen, what to carry forward as risks) are made by the producer and
# technical-director manually after the script runs.

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <milestone-number>"
  exit 1
fi

MILESTONE="$1"
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SOURCE_DIR="$REPO_ROOT/memory/current-milestone"
ARCHIVE_DIR="$REPO_ROOT/memory/archive/milestone-$MILESTONE"

if [ -d "$ARCHIVE_DIR" ]; then
  echo "ERROR: Archive directory already exists: $ARCHIVE_DIR"
  echo "Milestone $MILESTONE has already been archived. Check the directory."
  exit 1
fi

echo "Archiving milestone $MILESTONE..."
mkdir -p "$ARCHIVE_DIR"

# Copy (not move) so the script is idempotent on failure
for f in "$SOURCE_DIR"/*.md; do
  if [ -f "$f" ]; then
    cp "$f" "$ARCHIVE_DIR/"
    echo "  Archived: $(basename "$f")"
  fi
done

echo ""
echo "Archive written to: $ARCHIVE_DIR"
echo ""
echo "Next steps (manual, by producer):"
echo "  1. Clear memory/current-milestone/*.md and start fresh for milestone $((MILESTONE+1))."
echo "  2. Ask technical-director to promote any graduated seams to memory/evergreen/core-interfaces.md."
echo "  3. Ask creative-director to update memory/evergreen/game-pillars.md if pillars were refined."
echo "  4. Log the milestone boundary in .claude/docs/decision-log.md."
echo ""
echo "Done."
