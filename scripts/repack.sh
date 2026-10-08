#!/usr/bin/env bash
#
# repack.sh — 本地重打包骨架（示意版，尚未最终确定）
#
# 用途：以官方渠道获取的 DiPlay APK 为输入，在本地完成 patch 与重签名，
#       产出仅供本人使用的测试包。
#
# 重要：本仓库不分发、不托管任何可用 APK，也不包含任何认证身份资产。
#       身份资产（offline-mfi/identity.pk8, certificate.p7b）本来就存在于
#       你输入的官方 APK 中，本脚本不产生、不复制、不上传它们。
#
# 前置：apktool、apksigner（Android SDK build-tools）、zipalign
#
set -euo pipefail

INPUT_APK=""
OUTPUT_APK=""
KEYSTORE="${ANDROID_KEYSTORE_PATH:-}"
KEYSTORE_PASS="${ANDROID_KEYSTORE_PASSWORD:-}"
KEY_ALIAS="${ANDROID_KEY_ALIAS:-}"
KEY_PASS="${ANDROID_KEY_PASSWORD:-}"
WORKDIR="$(mktemp -d)"
PATCH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../patches" && pwd)"

usage() {
  cat <<'EOF'
用法: ./scripts/repack.sh -i <输入官方APK> -o <输出APK>

环境变量（签名用，切勿提交到 Git）：
  ANDROID_KEYSTORE_PATH
  ANDROID_KEYSTORE_PASSWORD
  ANDROID_KEY_ALIAS
  ANDROID_KEY_PASSWORD
EOF
  exit 1
}

while getopts ":i:o:h" opt; do
  case "$opt" in
    i) INPUT_APK="$OPTARG" ;;
    o) OUTPUT_APK="$OPTARG" ;;
    h|*) usage ;;
  esac
done

[[ -f "$INPUT_APK" ]] || { echo "输入 APK 不存在: $INPUT_APK"; exit 1; }
[[ -n "$OUTPUT_APK" ]] || usage

echo "[1/5] 反编译: $INPUT_APK"
apktool d -f "$INPUT_APK" -o "$WORKDIR/decoded"

echo "[2/5] 校验输入包含身份资产（不复制、不导出）"
# 只做存在性检查，绝不把这两个文件写出仓库
if ! unzip -l "$INPUT_APK" | grep -q "offline-mfi/identity.pk8"; then
  echo "警告: 输入 APK 未包含 offline-mfi/identity.pk8，产出的包将无法完成 CarPlay 认证。"
fi

echo "[3/5] 应用 E01 补丁"
# patch 以 .patch 形式放在 patches/ 目录，逐个应用
if [[ -d "$PATCH_DIR" ]]; then
  for p in "$PATCH_DIR"/*.patch; do
    [[ -e "$p" ]] || continue
    echo "  应用 $p"
    (cd "$WORKDIR/decoded" && patch -p1 --forward < "$p") \
      || echo "  补丁 $p 应用失败，请检查是否已被上游合入"
  done
fi

echo "[4/5] 重新打包"
apktool b "$WORKDIR/decoded" -o "$WORKDIR/unsigned.apk"
zipalign -p 4 "$WORKDIR/unsigned.apk" "$WORKDIR/aligned.apk"

echo "[5/5] 签名"
if [[ -n "$KEYSTORE" && -f "$KEYSTORE" ]]; then
  apksigner sign \
    --ks "$KEYSTORE" \
    --ks-pass "pass:$KEYSTORE_PASS" \
    --ks-key-alias "$KEY_ALIAS" \
    --key-pass "pass:$KEY_PASS" \
    --out "$OUTPUT_APK" \
    "$WORKDIR/aligned.apk"
  echo "完成: $OUTPUT_APK"
  echo
  echo "注意：签名与官方包不同，不能覆盖升级，需先卸载旧包。"
  echo "卸载前请先导出诊断报告。"
else
  echo "未设置 keystore 环境变量，跳过签名，输出未签名包: $WORKDIR/aligned.apk"
  exit 2
fi

rm -rf "$WORKDIR"
