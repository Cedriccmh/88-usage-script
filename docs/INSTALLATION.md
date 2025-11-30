# 安装指南

## 系统要求

- **Node.js**: 14.0.0 或更高版本
- **操作系统**: Linux, macOS, 或 Windows
- **Claude Code**: 已安装并配置（可选，但推荐）

## 安装方法

### 方法一：使用安装向导（推荐）

#### Linux / macOS

```bash
# 1. 克隆仓库
git clone https://github.com/Cedriccmh/88-usage-script.git
cd 88-usage-script

# 2. 运行安装向导
chmod +x install.sh
./install.sh
```

安装向导会引导您完成以下步骤：
1. 检测操作系统和依赖
2. 选择安装位置
3. 配置 PATH 环境变量
4. 创建短命令别名

#### Windows

```powershell
# 1. 克隆仓库
git clone https://github.com/Cedriccmh/88-usage-script.git
cd 88-usage-script

# 2. 运行安装向导
.\install.ps1
```

**注意：** 如果提示"无法加载，因为在此系统上禁止运行脚本"，请以管理员身份运行 PowerShell 并执行：
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 方法二：手动安装

#### Linux / macOS

```bash
# 1. 复制脚本到用户 bin 目录
mkdir -p ~/bin
cp bin/check-88code-usage ~/bin/
chmod +x ~/bin/check-88code-usage

# 2. 创建短命令别名
ln -s ~/bin/check-88code-usage ~/bin/88usage

# 3. 添加到 PATH（如果尚未添加）
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc  # 或 ~/.bashrc
source ~/.zshrc  # 或 source ~/.bashrc
```

#### Windows

```powershell
# 1. 创建安装目录
$binDir = "$env:USERPROFILE\bin"
New-Item -ItemType Directory -Path $binDir -Force

# 2. 复制脚本
Copy-Item "bin\check-88code-usage" "$binDir\check-88code-usage"
Copy-Item "bin\check-88code-usage" "$binDir\88usage"

# 3. 添加到 PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
$newPath = "$binDir;$currentPath"
[Environment]::SetEnvironmentVariable("Path", $newPath, "User")

# 4. 重启 PowerShell
```

### 方法三：直接运行（无需安装）

```bash
# Linux / macOS
node /path/to/88-usage-script/bin/check-88code-usage

# Windows
node C:\path\to\88-usage-script\bin\check-88code-usage
```

## 验证安装

安装完成后，打开新的终端窗口并运行：

```bash
88usage --version
```

如果显示版本号，说明安装成功！

## 配置

工具会自动读取 Claude Code 的配置文件：

**配置文件位置：**
- Linux/macOS: `~/.claude/settings.json`
- Windows: `%USERPROFILE%\.claude\settings.json`

**配置示例：**
```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "88_your_api_key_here",
    "ANTHROPIC_BASE_URL": "https://www.88code.org/api"
  }
}
```

如果您尚未安装 Claude Code，需要手动创建此配置文件。

## 安装位置选项

### 1. 用户目录安装（推荐）

**优点：**
- 无需 sudo/管理员权限
- 不影响其他用户
- 易于更新和删除

**位置：**
- Linux/macOS: `~/bin/`
- Windows: `%USERPROFILE%\bin\`

### 2. 系统目录安装

**优点：**
- 对所有用户可用
- 无需配置 PATH

**缺点：**
- 需要 sudo/管理员权限
- 更新和删除需要权限

**位置：**
- Linux: `/usr/local/bin/`
- macOS: `/usr/local/bin/`
- Windows: `C:\Program Files\88code-usage\`

### 3. 符号链接

**优点：**
- 节省空间
- 便于开发调试
- 修改源文件立即生效

**缺点：**
- Windows 需要开发者模式或管理员权限

## 卸载

### Linux / macOS

```bash
# 删除脚本
rm ~/bin/check-88code-usage
rm ~/bin/88usage

# 从 shell 配置中移除 PATH（可选）
# 编辑 ~/.zshrc 或 ~/.bashrc，删除相关行
```

### Windows

```powershell
# 删除脚本
Remove-Item "$env:USERPROFILE\bin\check-88code-usage"
Remove-Item "$env:USERPROFILE\bin\88usage"

# 从 PATH 中移除（可选）
# 使用系统设置 > 环境变量，手动移除
```

## 常见问题

### Q: 为什么运行 `88usage` 提示命令未找到？

**A:** PATH 环境变量尚未更新。请尝试：
1. 重启终端/PowerShell
2. 运行 `source ~/.zshrc`（Linux/macOS）
3. 使用完整路径运行

### Q: Windows 上提示"无法运行脚本"

**A:** PowerShell 执行策略限制。以管理员身份运行：
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Q: 需要 sudo 权限吗？

**A:** 不需要。推荐安装到用户目录（选项 1），无需 sudo。

### Q: 如何更新工具？

**A:**
```bash
# 拉取最新代码
cd 88-usage-script
git pull

# 重新运行安装向导
./install.sh  # Linux/macOS
.\install.ps1  # Windows
```

## 技术支持

如遇问题，请：
1. 查看 [README.md](../README.md) 中的故障排除部分
2. 提交 [GitHub Issue](https://github.com/Cedriccmh/88-usage-script/issues)
