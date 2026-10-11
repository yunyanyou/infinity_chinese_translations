#!/bin/bash
set -u

ROM_ROOT="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="${TMPDIR:-/tmp}/infinity_chinese_translations"
MANIFEST="$STATE_DIR/installed_files"
BACKUP_DIR="$STATE_DIR/backup"

if [ ! -d "$ROM_ROOT/packages" ]; then
    echo "错误：请在 ROM 源码根目录下运行此脚本！"
    exit 1
fi

if [ "${1:-}" = "--revert" ]; then
    if [ ! -f "$MANIFEST" ]; then
        echo "没有安装记录，无需撤销。"
        exit 0
    fi
    while IFS= read -r rel; do
        [ -n "$rel" ] || continue
        if [ -f "$BACKUP_DIR/$rel" ]; then
            cp -v "$BACKUP_DIR/$rel" "$ROM_ROOT/$rel"
        else
            rm -vf "$ROM_ROOT/$rel"
        fi
    done < "$MANIFEST"
    rm -rf "$STATE_DIR"
    echo "撤销完成。"
    exit 0
fi

echo "正在还原中文语言文件到源码树..."
rm -rf "$STATE_DIR"
mkdir -p "$STATE_DIR"
: > "$MANIFEST"
cd "$SCRIPT_DIR" || exit 1
while IFS= read -r src; do
    rel="${src#./}"
    if [ -f "$ROM_ROOT/$rel" ] && [ ! -f "$BACKUP_DIR/$rel" ]; then
        mkdir -p "$(dirname "$BACKUP_DIR/$rel")"
        cp "$ROM_ROOT/$rel" "$BACKUP_DIR/$rel"
    fi
    mkdir -p "$(dirname "$ROM_ROOT/$rel")"
    cp "$src" "$ROM_ROOT/$rel"
    echo "$rel" >> "$MANIFEST"
done < <(find packages -type f | sort)
echo "所有汉化文件已还原成功！"
