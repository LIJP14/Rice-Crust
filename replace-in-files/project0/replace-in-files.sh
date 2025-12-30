#!/bin/bash

# ===========================
# 批量替换文件中的占位符（Bash 3.2 兼容版）
# 支持 Linux 和 macOS（即使使用 /bin/bash）
# ===========================

set -euo pipefail

# TARGET_DIR="${1:-./dist}"
# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
#TARGET_DIR="${1:-$SCRIPT_DIR}"
TARGET_DIR="$SCRIPT_DIR"

PREFIX="/xizang"

# 解析命令行参数
while [ $# -gt 0 ]; do
  case "$1" in
    -d|--dir)
      if [ $# -lt 2 ]; then
        echo "❌ Error: '$1' requires a directory argument." >&2
        exit 1
      fi
      TARGET_DIR="$2"
      shift 2
      ;;
    --dir=*)
      TARGET_DIR="${1#*=}"
      shift
      ;;
    -p|--prefix)
      if [ $# -lt 2 ]; then
        echo "❌ Error: '$1' requires a prefix argument." >&2
        exit 1
      fi
      PREFIX="$2"
      shift 2
      ;;
    --prefix=*)
      PREFIX="${1#*=}"
      shift
      ;;
    -h|--help)
      cat <<EOF
Usage: $0 [OPTIONS]

Options:
  -d, --dir DIR         Target directory to process (default: script's directory)
  -p, --prefix PREFIX   URL path prefix (default: /xizang)
  -h, --help            Show this help

Examples:
  $0
  $0 -d ./dist -p /xinjiang
  $0 --dir=/home/web/dist --prefix=/xinjiang
EOF
      exit 0
      ;;
    *)
      echo "❌ Error: Unknown argument '$1'. Use --help for usage." >&2
      exit 1
      ;;
  esac
done

PREFIX="${PREFIX%/}"  # 清理尾部斜杠


if [ ! -d "$TARGET_DIR" ]; then
  echo "❌ Error: Directory '$TARGET_DIR' does not exist." >&2
  exit 1
fi



# === 定义替换规则：使用平行数组（兼容 Bash 3.2）===
SEARCHES=(
  "/davp/dashboard-api"
  "/davp/dashboard"
  "/davp-dashboard"
)

REPLACES=(
  "${PREFIX}${SEARCHES[0]}"
  "${PREFIX}${SEARCHES[1]}"
  "${PREFIX}${SEARCHES[2]}"
)

# === 检测 sed 类型 ===
if sed --version >/dev/null 2>&1; then
  SED_IS_GNU=1
else
  SED_IS_GNU=0
fi

# === 转义字符串用于 sed ===
escape_sed_str() {
  # 转义 \, &, /, 新行等（基本安全）
  printf '%s\n' "$1" | sed -e 's/[&/\]/\\&/g'
}

# === 替换单个文件中的所有占位符 ===
process_file() {
  local file="$1"
  echo "  📄 $file"

  i=0
  while [ $i -lt ${#SEARCHES[@]} ]; do
    search="${SEARCHES[$i]}"
    replace="${REPLACES[$i]}"
    esc_search="$(escape_sed_str "$search")"
    esc_replace="$(escape_sed_str "$replace")"

    if [ "$SED_IS_GNU" = 1 ]; then
      # GNU sed: 使用 \b 单词边界
      # 1. 中间匹配：前后非单词字符
      sed -E -i "s|([^[:alnum:]_])${esc_search}([^[:alnum:]_])|\1${esc_replace}\2|g" "$file"
      # 2. 行首 + 非单词后缀
      sed -E -i "s|^${esc_search}([^[:alnum:]_])|${esc_replace}\1|g" "$file"
      # 3. 行尾 + 非单词前缀
      sed -E -i "s|([^[:alnum:]_])${esc_search}$|\1${esc_replace}|g" "$file"
      # 4. 整行完全匹配
      sed -E -i "s|^${esc_search}$|${esc_replace}|g" "$file"
    else
      # BSD sed (macOS): 模拟单词边界
      # 1. 中间匹配：前后非单词字符
      sed -E -i '' "s|([^[:alnum:]_])${esc_search}([^[:alnum:]_])|\1${esc_replace}\2|g" "$file"
      # 2. 行首 + 非单词后缀
      sed -E -i '' "s|^${esc_search}([^[:alnum:]_])|${esc_replace}\1|g" "$file"
      # 3. 行尾 + 非单词前缀
      sed -E -i '' "s|([^[:alnum:]_])${esc_search}$|\1${esc_replace}|g" "$file"
      # 4. 整行完全匹配
      sed -E -i '' "s|^${esc_search}$|${esc_replace}|g" "$file"
    fi

    i=$((i + 1))
  done
}

# === 主逻辑 ===
echo "🔧 Replacing placeholders in $TARGET_DIR..."

# 创建临时文件列表
temp_list=$(mktemp)
trap 'rm -f "$temp_list"' EXIT

# 使用 while 循环逐个处理文件（避免子 shell 变量丢失问题）
find "$TARGET_DIR" -type f \( -name "*.html" -o -name "*.js" -o -name "*.json" -o -name "*.css" \) -print0 > "$temp_list"
while IFS= read -r -d '' file; do
  process_file "$file"
done < "$temp_list"
echo "✅ Done!"
echo ""





# 2. 删除旧 .gz（仅针对 temp_list 中的文件）
## === 清理：删除 TARGET_DIR 下所有 .gz 文件 ===
#find "$TARGET_DIR" -type f -name "*.gz" -delete
echo "🗑️  Removing old .gz files (only for processed files)..."
while IFS= read -r -d '' file; do
  gz_file="$file.gz"
  if [ -f "$gz_file" ]; then
    rm -f "$gz_file"
    echo "  🗑️  Deleted: $gz_file"
  fi
done < "$temp_list"
echo "✅ Done!"
echo ""





# 3. 生成新 .gz（兼容 macOS/Linux）
echo "📦 Creating new .gz files..."
while IFS= read -r -d '' file; do
  if [ "${file##*.}" != "gz" ]; then  # 再次确保不是 .gz 文件
    # 仅处理大于 4KB 的文件
    if [ "$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file")" -gt 4096 ]; then
        gzip -c "$file" > "$file.gz"
        echo "  📦️  Created: $file.gz"
      fi
  fi
done < "$temp_list"
echo "✅ Done!"