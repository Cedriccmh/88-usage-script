#!/bin/bash

# 88code Usage Script Installer
# Compatible with Linux and macOS

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  88code 中转站用量查询工具 - 安装向导${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    else
        print_error "不支持的操作系统: $OSTYPE"
        exit 1
    fi
}

# Check Node.js
check_node() {
    if ! command -v node &> /dev/null; then
        print_error "未检测到 Node.js"
        echo ""
        print_info "请先安装 Node.js："
        echo "  - Linux: sudo apt install nodejs"
        echo "  - macOS: brew install node"
        echo "  - 或访问: https://nodejs.org/"
        exit 1
    fi

    NODE_VERSION=$(node -v)
    print_success "检测到 Node.js $NODE_VERSION"
}

# Check Claude settings
check_claude_settings() {
    CLAUDE_SETTINGS="$HOME/.claude/settings.json"

    if [ ! -f "$CLAUDE_SETTINGS" ]; then
        print_warning "未找到 Claude 配置文件"
        echo ""
        print_info "请确保已安装 Claude Code 并配置了 API 密钥"
        echo "  配置文件位置: $CLAUDE_SETTINGS"
        echo ""
        read -p "是否继续安装？(y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        print_success "找到 Claude 配置文件"
    fi
}

# Install script
install_script() {
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    SOURCE_SCRIPT="$SCRIPT_DIR/bin/check-88code-usage"

    if [ ! -f "$SOURCE_SCRIPT" ]; then
        print_error "未找到脚本文件: $SOURCE_SCRIPT"
        exit 1
    fi

    # Determine installation method
    echo ""
    print_info "请选择安装方式："
    echo "  1) 安装到用户目录 ~/bin (推荐，无需 sudo)"
    echo "  2) 安装到系统目录 /usr/local/bin (需要 sudo)"
    echo "  3) 仅创建符号链接"
    echo ""
    read -p "请输入选项 (1-3): " -n 1 -r INSTALL_METHOD
    echo ""

    case $INSTALL_METHOD in
        1)
            install_to_user_bin
            ;;
        2)
            install_to_system_bin
            ;;
        3)
            create_symlink
            ;;
        *)
            print_error "无效的选项"
            exit 1
            ;;
    esac
}

# Install to ~/bin
install_to_user_bin() {
    BIN_DIR="$HOME/bin"

    print_info "创建 $BIN_DIR 目录..."
    mkdir -p "$BIN_DIR"

    print_info "复制脚本到 $BIN_DIR..."
    cp "$SOURCE_SCRIPT" "$BIN_DIR/check-88code-usage"
    chmod +x "$BIN_DIR/check-88code-usage"

    print_info "创建短命令别名..."
    ln -sf "$BIN_DIR/check-88code-usage" "$BIN_DIR/88usage"

    INSTALL_PATH="$BIN_DIR"
    update_shell_config

    print_success "安装完成！"
    print_install_info
}

# Install to /usr/local/bin
install_to_system_bin() {
    BIN_DIR="/usr/local/bin"

    print_info "复制脚本到 $BIN_DIR (需要 sudo)..."
    sudo cp "$SOURCE_SCRIPT" "$BIN_DIR/check-88code-usage"
    sudo chmod +x "$BIN_DIR/check-88code-usage"

    print_info "创建短命令别名..."
    sudo ln -sf "$BIN_DIR/check-88code-usage" "$BIN_DIR/88usage"

    INSTALL_PATH="$BIN_DIR"

    print_success "安装完成！"
    print_install_info
}

# Create symlink
create_symlink() {
    BIN_DIR="$HOME/bin"

    print_info "创建 $BIN_DIR 目录..."
    mkdir -p "$BIN_DIR"

    print_info "创建符号链接..."
    ln -sf "$SOURCE_SCRIPT" "$BIN_DIR/check-88code-usage"
    ln -sf "$SOURCE_SCRIPT" "$BIN_DIR/88usage"

    INSTALL_PATH="$BIN_DIR"
    update_shell_config

    print_success "符号链接创建完成！"
    print_install_info
}

# Update shell configuration
update_shell_config() {
    # Detect shell
    CURRENT_SHELL=$(basename "$SHELL")

    case "$CURRENT_SHELL" in
        bash)
            SHELL_CONFIG="$HOME/.bashrc"
            ;;
        zsh)
            SHELL_CONFIG="$HOME/.zshrc"
            ;;
        *)
            print_warning "未知的 shell: $CURRENT_SHELL"
            return
            ;;
    esac

    # Check if PATH already includes ~/bin
    if ! echo "$PATH" | grep -q "$HOME/bin"; then
        print_info "更新 $SHELL_CONFIG..."

        # Check if already added
        if ! grep -q 'export PATH="$HOME/bin:$PATH"' "$SHELL_CONFIG" 2>/dev/null; then
            echo '' >> "$SHELL_CONFIG"
            echo '# Added by 88-usage-script installer' >> "$SHELL_CONFIG"
            echo 'export PATH="$HOME/bin:$PATH"' >> "$SHELL_CONFIG"
            print_success "已添加到 PATH"
        else
            print_info "PATH 已配置"
        fi
    else
        print_success "PATH 已包含 ~/bin"
    fi
}

# Print installation info
print_install_info() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    print_success "安装成功！"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    print_info "安装位置: ${INSTALL_PATH}"
    echo ""
    print_info "使用方法："
    echo "  ${GREEN}88usage${NC}              # 查询用量"
    echo "  ${GREEN}88usage --help${NC}       # 查看帮助"
    echo "  ${GREEN}88usage --version${NC}    # 查看版本"
    echo ""

    if [[ "$INSTALL_PATH" == "$HOME/bin" ]]; then
        print_warning "请重新加载 shell 配置或打开新终端："
        echo "  ${YELLOW}source $SHELL_CONFIG${NC}"
        echo ""
        print_info "或者现在就可以使用完整路径："
        echo "  ${GREEN}$INSTALL_PATH/88usage${NC}"
    else
        print_info "您现在可以直接使用："
        echo "  ${GREEN}88usage${NC}"
    fi
    echo ""
}

# Main installation flow
main() {
    print_header

    print_info "检测操作系统..."
    detect_os
    print_success "操作系统: $OS"
    echo ""

    print_info "检查依赖..."
    check_node
    check_claude_settings
    echo ""

    print_info "开始安装..."
    install_script
}

# Run
main
