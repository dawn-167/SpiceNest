#!/bin/bash
# SpiceNest Services 层测试运行脚本
# 用途：编译并运行 SearchService 回归测试
# 用法：./scripts/run_tests.sh
# 依据：ERROR_PREVENTION.md 第三章 P2 项 #5

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TESTS_DIR="$PROJECT_DIR/Tests"
BUILD_DIR="$PROJECT_DIR/.build-test"

echo "=== SpiceNest Services 层测试 ==="
echo ""

# 创建构建目录
mkdir -p "$BUILD_DIR"

# 收集需要编译的 Swift 文件（只编译 Models + Services + 测试文件，不编译 UI 相关）
SWIFT_FILES=$(find "$PROJECT_DIR/Sources/Models" "$PROJECT_DIR/Sources/Services" -name "*.swift" | tr '\n' ' ')
TEST_FILE="$TESTS_DIR/main.swift"

echo "编译测试..."
swiftc $SWIFT_FILES "$TEST_FILE" \
    -o "$BUILD_DIR/SpiceNestTests" \
    -framework Foundation \
    -O

echo "编译完成"
echo ""

# 运行测试
echo "运行测试..."
"$BUILD_DIR/SpiceNestTests" "$PROJECT_DIR/Resources/content"

# 清理
rm -rf "$BUILD_DIR"
