#!/bin/bash
# SpiceNest 内容 JSON 校验脚本
# 用途：校验内容数据的格式、id 唯一性、related 死链、tags 数量、summary 长度
# 用法：./scripts/validate_content.sh
# 依据：ERROR_PREVENTION.md 第三章 P1 项 #2

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CONTENT_DIR="$PROJECT_DIR/Resources/content"

echo "=== SpiceNest 内容 JSON 校验 ==="
echo ""

cd "$PROJECT_DIR"

python3 << 'PYEOF'
import json
import os
import sys

# 从环境变量获取内容目录，或使用默认相对路径
content_dir = os.environ.get('SPICENEST_CONTENT_DIR', os.path.join(os.getcwd(), 'Resources', 'content'))
errors = []
warnings = []
all_ids = set()
all_items = []

# 1. 读取 index.json
index_path = os.path.join(content_dir, 'index.json')
if not os.path.exists(index_path):
    errors.append(f"index.json 不存在: {index_path}")
else:
    with open(index_path) as f:
        index = json.load(f)
    items = index.get('items', [])
    print(f"index.json: {len(items)} 条内容")

    # 2. 校验每条内容
    for item in items:
        item_id = item.get('id', '')
        item_type = item.get('type', '')

        # id 非空
        if not item_id:
            errors.append(f"内容项 id 为空: {item}")
            continue

        # id 唯一
        if item_id in all_ids:
            errors.append(f"id 重复: {item_id}")
        all_ids.add(item_id)

        # 必需字段
        for field in ['title', 'chineseTitle', 'summary', 'tags', 'related']:
            if field not in item:
                errors.append(f"{item_id}: 缺少字段 {field}")

        # tags ≥ 3
        tags = item.get('tags', [])
        if len(tags) < 3:
            errors.append(f"{item_id}: tags 数量不足 ({len(tags)} < 3)")

        # summary ≤ 40 字
        summary = item.get('summary', '')
        if len(summary) > 40:
            errors.append(f"{item_id}: summary 过长 ({len(summary)} > 40): {summary}")

        all_items.append(item)

# 3. 校验 related 死链
print(f"校验 related 死链...")
for item in all_items:
    item_id = item.get('id', '')
    related = item.get('related', [])
    for rel_id in related:
        if rel_id not in all_ids:
            errors.append(f"{item_id}: related 死链 -> {rel_id}")

# 4. 校验指令详情 JSON
commands_dir = os.path.join(content_dir, 'commands')
if os.path.exists(commands_dir):
    command_files = [f for f in os.listdir(commands_dir) if f.endswith('.json')]
    print(f"指令详情: {len(command_files)} 个文件")
    for cmd_file in command_files:
        filepath = os.path.join(commands_dir, cmd_file)
        with open(filepath) as f:
            detail = json.load(f)
        detail_id = detail.get('id', '')
        if not detail_id:
            errors.append(f"{cmd_file}: 缺少 id 字段")
        if detail_id not in all_ids:
            errors.append(f"{cmd_file}: id {detail_id} 不在 index.json 中")
        # 校验必需字段
        for field in ['syntax', 'parameters', 'examples', 'notes', 'related']:
            if field not in detail:
                errors.append(f"{cmd_file}: 缺少字段 {field}")

# 5. 校验错误详情 JSON
errors_path = os.path.join(content_dir, 'errors', 'common-errors.json')
if os.path.exists(errors_path):
    with open(errors_path) as f:
        error_details = json.load(f)
    print(f"错误详情: {len(error_details)} 条")
    for err in error_details:
        err_id = err.get('id', '')
        if not err_id:
            errors.append(f"错误详情缺少 id: {err}")
            continue
        if err_id not in all_ids:
            errors.append(f"错误详情 id {err_id} 不在 index.json 中")
        # 校验必需字段
        for field in ['errorPattern', 'category', 'cause', 'solutions', 'copyableCommands', 'related']:
            if field not in err:
                errors.append(f"{err_id}: 缺少字段 {field}")

# 6. 输出结果
print("")
if errors:
    print(f"❌ 发现 {len(errors)} 个错误:")
    for e in errors:
        print(f"  - {e}")
    sys.exit(1)
else:
    print("✅ 所有校验通过！")
    print(f"   - {len(all_ids)} 个唯一 id")
    print(f"   - 无 related 死链")
    print(f"   - 所有 tags ≥ 3")
    print(f"   - 所有 summary ≤ 40 字")
    sys.exit(0)
PYEOF
