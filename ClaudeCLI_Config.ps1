# Created by Huozheng

# 自动获取管理员权限
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process PowerShell -Verb RunAs -ArgumentList "-NoProfile -NoExit -File `"$PSCommandPath`""
    exit
}

Write-Host " 脚本已运行在 Administrator 权限下。`n" -ForegroundColor Green

Write-Host " ===========================================" -ForegroundColor Yellow
Write-Host "    模型选择：1-DeepSeek | 2-Xiaomi Mimo" -ForegroundColor Yellow
Write-Host " ===========================================" -ForegroundColor Yellow

# 获取模型选择
$modelChoice = Read-Host " 请输入选择项"

if ($modelChoice -eq 1) {
    Write-Host " 你选择了 DeepSeek 模型。`n`n" -ForegroundColor Green
} elseif ($modelChoice -eq 2) {
    Write-Host " 你选择了 Xiaomi Mimo 模型。`n`n" -ForegroundColor Green
} else {
    Write-Host " 无效的选择，请输入 1 或 2。" -ForegroundColor Red
    exit
}

Write-Host " ===========================================" -ForegroundColor Yellow
Write-Host "   API Key 配置：请输入以 sk 开头的 API Key" -ForegroundColor Yellow
Write-Host " ===========================================" -ForegroundColor Yellow

# 获取 API Key
$api = Read-Host " 请输入API Key"

# 编辑 Claude 配置文件
Set-Location "C:\Users\$env:USERNAME\.claude"
$settingsPath = ".\settings.json"

# 如果 settings.json 文件不存在，创建一个新的空文件
if (-Not (Test-Path -Path $settingsPath)) {
    New-Item -Path $settingsPath -ItemType File -Force
}

$deepseekConfig = @"
{
  "autoUpdatesChannel": "latest",
  "theme": "auto",
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.deepseek.com/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "$api",
    "ANTHROPIC_MODEL": "deepseek-v4-pro[1m]",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "deepseek-v4-pro[1m]",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "deepseek-v4-pro[1m]",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "deepseek-v4-flash",
    "CLAUDE_CODE_SUBAGENT_MODEL": "deepseek-v4-flash",
    "CLAUDE_CODE_EFFORT_LEVEL": "max"
  },
  "effortLevel": "max"
}
"@

$xiaomiMimoConfig = @"
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.xiaomimimo.com/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "$api",
    "ANTHROPIC_MODEL": "mimo-v2.5-pro",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "mimo-v2.5-pro",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "mimo-v2.5-pro",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "mimo-v2.5-pro"
  }
}
"@

if ($modelChoice -eq "1") {
  Set-Content -Path $settingsPath -Value $deepseekConfig -Encoding UTF8
} else {
  Set-Content -Path $settingsPath -Value $xiaomiMimoConfig -Encoding UTF8
}

[Environment]::SetEnvironmentVariable("Path", "$env:Path;C:\Users\$env:USERNAME\.local\binnn", "User")

Write-Host " 请重新启动 Claude 以应用新的配置。" -ForegroundColor Yellow

Write-Host "`n 按任意键退出..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
