#!/bin/bash

# ============================================================
# xuan 项目迁移脚本 - 拆分为独立仓库 + Submodules
# ============================================================

set -e  # 遇到错误立即退出

# 配置
GITHUB_USER="weijingtai"
BASE_DIR="/Users/jingtaiwei/Git/Public"
SOURCE_DIR="$BASE_DIR/xuan"
WORK_DIR="$BASE_DIR/xuan-migration"

# 仓库列表
REPOS=(
    "xuan-storage"
    "xuan-common"
    "xuan-account"
    "xuan-qimendunjia"
    "xuan-qizhengsiyu"
    "xuan-taiyishenshu"
    "xuan-daliuren"
    "xuan-tiebanshenshu"
)

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ============================================================
# Part 1: 本地准备
# ============================================================
prepare_local() {
    log_info "========== Part 1: 本地准备 =========="

    # 创建工作目录
    if [ -d "$WORK_DIR" ]; then
        log_warn "工作目录已存在: $WORK_DIR"
        read -p "是否删除并重新创建? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$WORK_DIR"
        else
            log_error "请手动处理工作目录后重试"
            exit 1
        fi
    fi

    mkdir -p "$WORK_DIR"
    log_info "创建工作目录: $WORK_DIR"

    # 1. 创建 xuan-storage
    log_info "准备 xuan-storage..."
    mkdir -p "$WORK_DIR/xuan-storage"
    cp -r "$SOURCE_DIR/persistence_core" "$WORK_DIR/xuan-storage/core"
    cp -r "$SOURCE_DIR/persistence_drift" "$WORK_DIR/xuan-storage/drift"
    cp -r "$SOURCE_DIR/persistence_firebase" "$WORK_DIR/xuan-storage/firebase"

    # 创建 storage 的根 pubspec.yaml
    cat > "$WORK_DIR/xuan-storage/pubspec.yaml" << 'EOF'
name: xuan_storage
description: Storage modules for xuan project (core/drift/firebase)
version: 1.0.0
publish_to: 'none'

environment:
  sdk: '>=3.0.2 <4.0.0'
EOF

    # 2. 创建 xuan-common
    log_info "准备 xuan-common..."
    cp -r "$SOURCE_DIR/common" "$WORK_DIR/xuan-common"

    # 修改 common 的 pubspec.yaml - persistence 依赖改为 git
    # 这个需要手动处理，因为 sed 不好处理多行

    # 3. 创建业务模块
    log_info "准备 xuan-account..."
    cp -r "$SOURCE_DIR/account" "$WORK_DIR/xuan-account"

    log_info "准备 xuan-qimendunjia..."
    cp -r "$SOURCE_DIR/qimendunjia" "$WORK_DIR/xuan-qimendunjia"

    log_info "准备 xuan-qizhengsiyu..."
    cp -r "$SOURCE_DIR/qizhengsiyu" "$WORK_DIR/xuan-qizhengsiyu"

    log_info "准备 xuan-taiyishenshu..."
    cp -r "$SOURCE_DIR/taiyishenshu" "$WORK_DIR/xuan-taiyishenshu"

    log_info "准备 xuan-daliuren..."
    cp -r "$SOURCE_DIR/daliuren" "$WORK_DIR/xuan-daliuren"

    log_info "准备 xuan-tiebanshenshu..."
    cp -r "$SOURCE_DIR/tiebanshenshu" "$WORK_DIR/xuan-tiebanshenshu"

    log_info "Part 1 完成! 文件已准备到: $WORK_DIR"
    log_info "请执行 Part 2 修改依赖关系"
}

# ============================================================
# Part 2: 修改依赖关系
# ============================================================
update_dependencies() {
    log_info "========== Part 2: 修改依赖关系 =========="

    # 修改 xuan-common 的 persistence 依赖
    log_info "更新 xuan-common/pubspec.yaml..."

    COMMON_PUBSPEC="$WORK_DIR/xuan-common/pubspec.yaml"

    # 使用 Python 来修改 YAML（更可靠）
    python3 << EOF
import re

pubspec_path = "$COMMON_PUBSPEC"
with open(pubspec_path, 'r') as f:
    content = f.read()

# 替换 persistence_core 的 path 依赖为 git 依赖
content = re.sub(
    r'persistence_core:\s*\n\s*path:\s*\.\./persistence_core',
    '''persistence_core:
    git:
      url: https://github.com/$GITHUB_USER/xuan-storage.git
      path: core''',
    content
)

with open(pubspec_path, 'w') as f:
    f.write(content)

print("Updated: " + pubspec_path)
EOF

    # 修改各业务模块的 common 依赖
    for module in account qimendunjia qizhengsiyu taiyishenshu daliuren tiebanshenshu; do
        MODULE_PUBSPEC="$WORK_DIR/xuan-$module/pubspec.yaml"
        if [ -f "$MODULE_PUBSPEC" ]; then
            log_info "更新 xuan-$module/pubspec.yaml..."

            python3 << EOF
import re

pubspec_path = "$MODULE_PUBSPEC"
with open(pubspec_path, 'r') as f:
    content = f.read()

# 替换 common 的 path 依赖为 git 依赖
content = re.sub(
    r'common:\s*\n\s*path:\s*\.\./common',
    '''common:
    git:
      url: https://github.com/$GITHUB_USER/xuan-common.git
      ref: main''',
    content
)

# 替换 persistence_core 的 path 依赖（如果有）
content = re.sub(
    r'persistence_core:\s*\n\s*path:\s*\.\./persistence_core',
    '''persistence_core:
    git:
      url: https://github.com/$GITHUB_USER/xuan-storage.git
      path: core''',
    content
)

with open(pubspec_path, 'w') as f:
    f.write(content)

print("Updated: " + pubspec_path)
EOF
        fi
    done

    log_info "Part 2 完成! 依赖关系已更新"
    log_info "请执行 Part 3 初始化 Git 仓库"
}

# ============================================================
# Part 3: 初始化 Git 仓库
# ============================================================
init_git_repos() {
    log_info "========== Part 3: 初始化 Git 仓库 =========="

    for repo in "${REPOS[@]}"; do
        log_info "初始化 $repo..."
        cd "$WORK_DIR/$repo"

        # 删除旧的 .git（如果存在）
        rm -rf .git

        # 初始化新仓库
        git init
        git add .
        git commit -m "init: migrate from xuan monorepo"
        git branch -M main

        log_info "$repo 初始化完成"
    done

    log_info "Part 3 完成! 所有仓库已初始化"
    log_info ""
    log_info "=========================================="
    log_info "接下来请在 GitHub 创建以下空仓库:"
    log_info "=========================================="
    for repo in "${REPOS[@]}"; do
        echo "  https://github.com/$GITHUB_USER/$repo"
    done
    log_info ""
    log_info "创建完成后，执行 Part 4 推送到远程"
}

# ============================================================
# Part 4: 推送到远程
# ============================================================
push_to_remote() {
    log_info "========== Part 4: 推送到远程 =========="

    for repo in "${REPOS[@]}"; do
        log_info "推送 $repo..."
        cd "$WORK_DIR/$repo"

        git remote add origin "https://github.com/$GITHUB_USER/$repo.git" 2>/dev/null || true
        git push -u origin main

        log_info "$repo 推送完成"
    done

    log_info "Part 4 完成! 所有仓库已推送"
}

# ============================================================
# Part 5: 改造主项目为 submodule
# ============================================================
setup_main_project() {
    log_info "========== Part 5: 改造主项目 =========="

    cd "$SOURCE_DIR"

    # 备份当前状态
    log_warn "即将删除以下目录并替换为 submodule:"
    echo "  - common"
    echo "  - account"
    echo "  - qimendunjia"
    echo "  - qizhengsiyu"
    echo "  - taiyishenshu"
    echo "  - daliuren"
    echo "  - tiebanshenshu"
    echo "  - persistence_core"
    echo "  - persistence_drift"
    echo "  - persistence_firebase"

    read -p "确认继续? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_error "用户取消"
        exit 1
    fi

    # 创建 storage 目录并添加为 submodule
    rm -rf persistence_core persistence_drift persistence_firebase
    git rm -rf persistence_core persistence_drift persistence_firebase 2>/dev/null || true
    git submodule add "https://github.com/$GITHUB_USER/xuan-storage.git" storage

    # 删除旧目录并添加 submodule
    for module in common account qimendunjia qizhengsiyu taiyishenshu daliuren tiebanshenshu; do
        rm -rf "$module"
        git rm -rf "$module" 2>/dev/null || true
        git submodule add "https://github.com/$GITHUB_USER/xuan-$module.git" "$module"
    done

    # 更新主项目的 pubspec.yaml
    log_info "更新主项目 pubspec.yaml..."

    python3 << EOF
import re

pubspec_path = "$SOURCE_DIR/pubspec.yaml"
with open(pubspec_path, 'r') as f:
    content = f.read()

# persistence 依赖改为 storage 下的 path
content = re.sub(
    r'persistence_core:\s*\n\s*path:\s*\./persistence_core',
    '''persistence_core:
    path: ./storage/core''',
    content
)
content = re.sub(
    r'persistence_drift:\s*\n\s*path:\s*\./persistence_drift',
    '''persistence_drift:
    path: ./storage/drift''',
    content
)
content = re.sub(
    r'persistence_firebase:\s*\n\s*path:\s*\./persistence_firebase',
    '''persistence_firebase:
    path: ./storage/firebase''',
    content
)

with open(pubspec_path, 'w') as f:
    f.write(content)

print("Updated: " + pubspec_path)
EOF

    git add .
    git commit -m "refactor: migrate to git submodules

- xuan-storage: persistence_core/drift/firebase
- xuan-common: shared module
- xuan-account, xuan-qimendunjia, xuan-qizhengsiyu
- xuan-taiyishenshu, xuan-daliuren, xuan-tiebanshenshu

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"

    log_info "Part 5 完成! 主项目已改造为 submodule 结构"
}

# ============================================================
# 主菜单
# ============================================================
show_menu() {
    echo ""
    echo "=========================================="
    echo "  xuan 项目迁移脚本"
    echo "=========================================="
    echo "1) Part 1: 本地准备 (复制代码)"
    echo "2) Part 2: 修改依赖关系"
    echo "3) Part 3: 初始化 Git 仓库"
    echo "4) Part 4: 推送到远程 (需先创建 GitHub 仓库)"
    echo "5) Part 5: 改造主项目为 submodule"
    echo "6) 执行全部 (Part 1-3)"
    echo "0) 退出"
    echo ""
    read -p "请选择: " choice

    case $choice in
        1) prepare_local ;;
        2) update_dependencies ;;
        3) init_git_repos ;;
        4) push_to_remote ;;
        5) setup_main_project ;;
        6) prepare_local && update_dependencies && init_git_repos ;;
        0) exit 0 ;;
        *) log_error "无效选择" ;;
    esac

    show_menu
}

# 运行
show_menu
