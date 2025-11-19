#!/usr/bin/env bash
# Insert clipboard item into database
# Usage: clipboard_insert.sh <db_path> <hash> <mime_type> <is_image> <binary_path> <size>
# Content is read from stdin

set -euo pipefail

DB_PATH="$1"
HASH="$2"
MIME_TYPE="$3"
IS_IMAGE="$4"
BINARY_PATH="$5"
SIZE="${6:-0}"

# Read content from stdin and strip carriage returns
CONTENT=$(cat | tr -d '\r')

# Don't insert empty content for text items
if [ "$IS_IMAGE" = "0" ] && [ -z "$CONTENT" ]; then
    exit 0
fi

# Create preview
if [ "$IS_IMAGE" = "1" ]; then
    PREVIEW="[Image]"
elif [ ${#CONTENT} -gt 100 ]; then
    PREVIEW="${CONTENT:0:97}..."
else
    PREVIEW="$CONTENT"
fi

# Get timestamp in milliseconds
TIMESTAMP=$(date +%s)000

# Escape single quotes by replacing ' with ''
ESCAPED_PREVIEW="${PREVIEW//\'/\'\'}"
ESCAPED_CONTENT="${CONTENT//\'/\'\'}"

sqlite3 "$DB_PATH" <<EOSQL
.timeout 5000
INSERT INTO clipboard_items 
(content_hash, mime_type, preview, full_content, is_image, binary_path, size, created_at, updated_at) 
VALUES ('$HASH', '$MIME_TYPE', '$ESCAPED_PREVIEW', '$ESCAPED_CONTENT', $IS_IMAGE, '$BINARY_PATH', $SIZE, $TIMESTAMP, $TIMESTAMP)
ON CONFLICT(content_hash) DO UPDATE SET
updated_at = $TIMESTAMP;
EOSQL
