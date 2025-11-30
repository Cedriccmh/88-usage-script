# 88code Usage Script Installer for Windows
# Requires PowerShell 5.1 or higher

#Requires -Version 5.1

# Error handling
$ErrorActionPreference = "Stop"

# Colors (using Write-Host with -ForegroundColor)
function Print-Header {
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "  88code 中转站用量查询工具 - 安装向导" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
}

function Print-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Print-Error {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Print-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor Blue
}

function Print-Warning {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow
}

# Check if running as Administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Check Node.js
function Test-NodeJs {
    try {
        $nodeVersion = node --version
        Print-Success "检测到 Node.js $nodeVersion"
        return $true
    } catch {
        Print-Error "未检测到 Node.js"
        Write-Host ""
        Print-Info "请先安装 Node.js："
        Write-Host "  - 访问: https://nodejs.org/" -ForegroundColor White
        Write-Host "  - 或使用 winget: winget install OpenJS.NodeJS" -ForegroundColor White
        return $false
    }
}

# Check Claude settings
function Test-ClaudeSettings {
    $claudeSettings = "$env:USERPROFILE\.claude\settings.json"

    if (-not (Test-Path $claudeSettings)) {
        Print-Warning "未找到 Claude 配置文件"
        Write-Host ""
        Print-Info "请确保已安装 Claude Code 并配置了 API 密钥"
        Write-Host "  配置文件位置: $claudeSettings" -ForegroundColor White
        Write-Host ""
        $continue = Read-Host "是否继续安装？(y/n)"
        if ($continue -ne 'y') {
            exit 1
        }
    } else {
        Print-Success "找到 Claude 配置文件"
    }
}

# Install script
function Install-Script {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $sourceScript = Join-Path $scriptDir "bin\check-88code-usage"

    if (-not (Test-Path $sourceScript)) {
        Print-Error "未找到脚本文件: $sourceScript"
        exit 1
    }

    Write-Host ""
    Print-Info "请选择安装方式："
    Write-Host "  1) 安装到用户目录 (推荐)" -ForegroundColor White
    Write-Host "  2) 安装到系统目录 (需要管理员权限)" -ForegroundColor White
    Write-Host "  3) 仅创建符号链接" -ForegroundColor White
    Write-Host ""

    $choice = Read-Host "请输入选项 (1-3)"

    switch ($choice) {
        "1" { Install-ToUserDir -SourceScript $sourceScript }
        "2" { Install-ToSystemDir -SourceScript $sourceScript }
        "3" { Create-Symlink -SourceScript $sourceScript }
        default {
            Print-Error "无效的选项"
            exit 1
        }
    }
}

# Install to user directory
function Install-ToUserDir {
    param([string]$SourceScript)

    $binDir = "$env:USERPROFILE\bin"

    Print-Info "创建 $binDir 目录..."
    New-Item -ItemType Directory -Path $binDir -Force | Out-Null

    Print-Info "复制脚本到 $binDir..."
    Copy-Item $SourceScript "$binDir\check-88code-usage" -Force
    Copy-Item $SourceScript "$binDir\88usage" -Force

    $script:InstallPath = $binDir
    Update-PathEnvironment

    Print-Success "安装完成！"
    Show-InstallInfo
}

# Install to system directory
function Install-ToSystemDir {
    param([string]$SourceScript)

    if (-not (Test-Administrator)) {
        Print-Error "需要管理员权限"
        Print-Info "请右键点击 PowerShell 并选择 '以管理员身份运行'"
        exit 1
    }

    $binDir = "$env:ProgramFiles\88code-usage"

    Print-Info "创建 $binDir 目录..."
    New-Item -ItemType Directory -Path $binDir -Force | Out-Null

    Print-Info "复制脚本到 $binDir..."
    Copy-Item $SourceScript "$binDir\check-88code-usage" -Force
    Copy-Item $SourceScript "$binDir\88usage" -Force

    $script:InstallPath = $binDir
    Update-PathEnvironment -System

    Print-Success "安装完成！"
    Show-InstallInfo
}

# Create symlink
function Create-Symlink {
    param([string]$SourceScript)

    $binDir = "$env:USERPROFILE\bin"

    Print-Info "创建 $binDir 目录..."
    New-Item -ItemType Directory -Path $binDir -Force | Out-Null

    Print-Info "创建符号链接..."

    # Remove existing files/links
    Remove-Item "$binDir\check-88code-usage" -Force -ErrorAction SilentlyContinue
    Remove-Item "$binDir\88usage" -Force -ErrorAction SilentlyContinue

    # Create symlinks (requires admin or developer mode)
    try {
        New-Item -ItemType SymbolicLink -Path "$binDir\check-88code-usage" -Target $SourceScript -Force | Out-Null
        New-Item -ItemType SymbolicLink -Path "$binDir\88usage" -Target $SourceScript -Force | Out-Null
    } catch {
        Print-Warning "无法创建符号链接，将使用复制方式"
        Copy-Item $SourceScript "$binDir\check-88code-usage" -Force
        Copy-Item $SourceScript "$binDir\88usage" -Force
    }

    $script:InstallPath = $binDir
    Update-PathEnvironment

    Print-Success "安装完成！"
    Show-InstallInfo
}

# Update PATH environment variable
function Update-PathEnvironment {
    param([switch]$System)

    if ($System) {
        $target = [System.EnvironmentVariableTarget]::Machine
        $pathName = "系统"
    } else {
        $target = [System.EnvironmentVariableTarget]::User
        $pathName = "用户"
    }

    $currentPath = [Environment]::GetEnvironmentVariable("Path", $target)

    if ($currentPath -notlike "*$script:InstallPath*") {
        Print-Info "更新 $pathName PATH 环境变量..."
        $newPath = "$script:InstallPath;$currentPath"
        [Environment]::SetEnvironmentVariable("Path", $newPath, $target)
        Print-Success "已添加到 PATH"

        # Update current session
        $env:Path = "$script:InstallPath;$env:Path"
    } else {
        Print-Success "PATH 已包含安装目录"
    }
}

# Show installation info
function Show-InstallInfo {
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Print-Success "安装成功！"
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
    Print-Info "安装位置: $script:InstallPath"
    Write-Host ""
    Print-Info "使用方法："
    Write-Host "  88usage              # 查询用量" -ForegroundColor Green
    Write-Host "  88usage --help       # 查看帮助" -ForegroundColor Green
    Write-Host "  88usage --version    # 查看版本" -ForegroundColor Green
    Write-Host ""

    if ($script:InstallPath -like "*$env:USERPROFILE*") {
        Print-Warning "请重启 PowerShell 或打开新的 PowerShell 窗口使 PATH 生效"
        Write-Host ""
        Print-Info "或者您现在可以使用完整路径："
        Write-Host "  $script:InstallPath\88usage" -ForegroundColor Green
    } else {
        Print-Info "您现在可以在新的 PowerShell 窗口中使用："
        Write-Host "  88usage" -ForegroundColor Green
    }
    Write-Host ""

    Print-Info "在当前会话中测试："
    Write-Host "  node $script:InstallPath\88usage" -ForegroundColor Yellow
    Write-Host ""
}

# Main installation flow
function Main {
    Print-Header

    Print-Info "检测操作系统..."
    Print-Success "操作系统: Windows"
    Write-Host ""

    Print-Info "检查依赖..."
    if (-not (Test-NodeJs)) {
        exit 1
    }
    Test-ClaudeSettings
    Write-Host ""

    Print-Info "开始安装..."
    Install-Script
}

# Run
Main
