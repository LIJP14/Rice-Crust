#!/bin/bash

# ===========================
# 每个子项目打包后的 dist 目录中都包含有一个 replace-in-files.sh 脚本
# 将该脚本放到 nginx 指定的静态资源目录中
# 自动执行当前目录下所有子目录中的 replace-in-files.sh
# ===========================

set -euo pipefail

# 获取脚本所在目录（父目录）
PARENT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "🔍 Scanning subdirectories in: $PARENT_DIR"



## 一、单个目录
#SCRIPT_0="$PARENT_DIR/davp-web-home/dist/replace-in-files.sh"
#if [ -f "$SCRIPT_0" ]; then
##  echo "🚀 Running: $SCRIPT_0"
#  chmod +x "$SCRIPT_0"  # 确保可执行
#  "$SCRIPT_0" --prefix /jiangsu # 指定参数
##  echo "✅ Completed: $(basename "$PARENT_DIR")"
#  echo
#else
#  echo "⚠️ '$SCRIPT_0' not found"
#fi


# 二、使用 find 获取所有直接子目录（不递归深层）
# -maxdepth 1：只找一级子目录
# -type d：只找目录
# 注意：按字母顺序处理（可预测）
found=0
while IFS= read -r -d '' subdir; do
  script_path="$subdir/replace-in-files.sh"

  if [ -f "$script_path" ]; then
    found=$((found + 1))
    echo "🚀 Running: $script_path"
    chmod +x "$script_path"  # 确保可执行
    "$script_path" "$@" # 加 "$@" 让所有子脚本使用相同的参数: ./run-all_replace-in-files.sh -p /jiangsu
    echo "✅ Completed: $(basename "$subdir")"
    echo
  fi
done < <(find "$PARENT_DIR" -maxdepth 1 -type d -mindepth 1 -print0)

if [ "$found" -eq 0 ]; then
  echo "⚠️  No subdirectory contains 'replace-files.sh'."
else
  echo "🎉 Successfully ran $found script(s)."
fi