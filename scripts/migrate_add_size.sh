#!/usr/bin/env bash
# Migration script to add size column to clipboard_items table

set -euo pipefail

DB_PATH="${1:-$HOME/.local/share/quickshell/clipboard.db}"

echo "Migrating database: $DB_PATH"

# Check if column already exists
if sqlite3 "$DB_PATH" "PRAGMA table_info(clipboard_items);" | grep -q "size"; then
    echo "Column 'size' already exists. Skipping migration."
    exit 0
fi

echo "Adding 'size' column to clipboard_items table..."

sqlite3 "$DB_PATH" <<'EOSQL'
.timeout 5000
BEGIN TRANSACTION;

-- Add the size column
ALTER TABLE clipboard_items ADD COLUMN size INTEGER NOT NULL DEFAULT 0;

-- Update existing rows with calculated sizes
-- For images, use binary file size
UPDATE clipboard_items 
SET size = (
    SELECT LENGTH(READFILE(binary_path))
    FROM (SELECT binary_path FROM clipboard_items AS ci WHERE ci.id = clipboard_items.id) 
    WHERE binary_path IS NOT NULL AND binary_path != ''
)
WHERE is_image = 1 AND binary_path IS NOT NULL AND binary_path != '';

-- For files (text/uri-list), try to get file size from filesystem
-- This is handled in the shell script below

-- For text items, use length of full_content
UPDATE clipboard_items 
SET size = LENGTH(COALESCE(full_content, preview))
WHERE is_image = 0 AND mime_type != 'text/uri-list';

COMMIT;
EOSQL

echo "Migration completed successfully!"

# For files, we need to update sizes using shell
DATA_DIR="${2:-$HOME/.local/share/quickshell/clipboard-data}"
echo "Updating file sizes for text/uri-list items..."

sqlite3 "$DB_PATH" <<'EOSQL' | while IFS='|' read -r id file_uri; do
    if [ -n "$file_uri" ]; then
        file_path=$(echo "$file_uri" | sed 's|^file://||' | tr -d '\r')
        if [ -f "$file_path" ]; then
            file_size=$(stat -c%s "$file_path" 2>/dev/null || echo 0)
            sqlite3 "$DB_PATH" "UPDATE clipboard_items SET size = $file_size WHERE id = $id;"
        fi
    fi
done
.timeout 5000
.mode list
SELECT id, full_content FROM clipboard_items WHERE mime_type = 'text/uri-list';
EOSQL

echo "File sizes updated!"
