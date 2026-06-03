# Created by Huozheng

# 自动获取管理员权限
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process PowerShell -Verb RunAs -ArgumentList "-NoProfile -NoExit -File `"$PSCommandPath`""
    exit
}

Write-Host " 脚本已运行在 Administrator 权限下。`n" -ForegroundColor Green

Write-Host " ==================================================================" -ForegroundColor Yellow
Write-Host "               模型选择：1-DeepSeek | 2-Xiaomi mimo" -ForegroundColor Yellow
Write-Host " ==================================================================" -ForegroundColor Yellow

# 获取模型选择
$modelChoice = Read-Host " 请输入选择项"

if ($modelChoice -eq "1") {
    Write-Host " 你选择了 DeepSeek 模型。`n`n" -ForegroundColor Green
} elseif ($modelChoice -eq "2") {
    Write-Host " ==================================================================" -ForegroundColor Yellow
    Write-Host "         mimo 系列模型选择：1-mimo-v2.5-pro | 2-mimo-v2.5" -ForegroundColor Yellow
    Write-Host "  mimo-v2.5-pro 不支持多模态；mimo-v2.5 支持图片、视频、音频输入。" -ForegroundColor White
    Write-Host " ==================================================================" -ForegroundColor Yellow
    $mimoChoice = Read-Host " 请输入选择项"
    if ($mimoChoice -eq "1") {
      Write-Host " 你选择了 Xiaomi mimo-v2.5-pro 模型。`n`n" -ForegroundColor Green
    } else {
      Write-Host " 你选择了 Xiaomi mimo-v2.5 模型。`n`n" -ForegroundColor Green
    }
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
$claudeDir = "C:\Users\$env:USERNAME\.claude"
if (-Not (Test-Path -Path $claudeDir)) {
    New-Item -Path $claudeDir -ItemType Directory -Force | Out-Null
}
$settingsPath = "$claudeDir\settings.json"

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

$xiaomiMimov25Config = @"
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.xiaomimimo.com/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "$api",
    "ANTHROPIC_MODEL": "mimo-v2.5",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "mimo-v2.5",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "mimo-v2.5",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "mimo-v2.5"
  }
}
"@

$xiaomiMimov25pConfig = @"
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
  [System.IO.File]::WriteAllText($settingsPath, $deepseekConfig, [System.Text.UTF8Encoding]::new($false))
} else {
  if ($mimoChoice -eq "1") {
    [System.IO.File]::WriteAllText($settingsPath, $xiaomiMimov25pConfig, [System.Text.UTF8Encoding]::new($false))
  } else {
    [System.IO.File]::WriteAllText($settingsPath, $xiaomiMimov25Config, [System.Text.UTF8Encoding]::new($false))
  }
}

[Environment]::SetEnvironmentVariable("Path", "$env:Path;C:\Users\$env:USERNAME\.local\bin", "User")

Write-Host " 请重新启动 Claude 以应用新的配置。" -ForegroundColor Yellow

Write-Host "`n 按任意键退出..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
