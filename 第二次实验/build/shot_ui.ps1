# 用无头 Chrome 把 ui_src 下的 HTML 原型渲染成 PNG
# 用法：pwsh -File shot_ui.ps1
$ErrorActionPreference = "Continue"
$root = Split-Path -Parent $PSScriptRoot          # 第二次实验/
$src  = Join-Path $root "ui_src"
$dst  = Join-Path $root "实验2_241220173_乔轶\UI界面"
New-Item -ItemType Directory -Force $dst | Out-Null

$chrome = @(
  "C:\Program Files\Google\Chrome\Application\chrome.exe",
  "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $chrome) { throw "找不到 Chrome/Edge" }

# 文件 → 输出名 / 画布 / 缩放
$shots = @(
  @("01_login.html",             "界面01_登录注册.png",        390, 844, 2),
  @("02_home.html",              "界面02_买家首页_商品搜索.png", 390, 844, 2),
  @("03_detail.html",            "界面03_商品详情_预约.png",    390, 844, 2),
  @("04_my_reservations.html",   "界面04_我的预约.png",        390, 844, 2),
  @("05_order.html",             "界面05_订单详情.png",        390, 844, 2),
  @("06_messages.html",          "界面06_消息通知.png",        390, 844, 2),
  @("07_seller_products.html",   "界面07_卖家商品管理.png",    390, 844, 2),
  @("08_publish.html",           "界面08_发布商品.png",        390, 844, 2),
  @("09_seller_reservations.html","界面09_卖家预约确认.png",   390, 844, 2),
  @("10_admin_audit.html",       "界面10_管理员_商品审核.png",  1440, 900, 1.5),
  @("11_admin_reports.html",     "界面11_管理员_举报与封禁.png", 1440, 900, 1.5),
  @("12_admin_stats.html",       "界面12_管理员_统计报表.png",  1440, 900, 1.5),
  @("13_admin_logs.html",        "界面13_操作记录查询.png",    1440, 900, 1.5)
)

foreach ($s in $shots) {
  $in  = (Join-Path $src $s[0]) -replace '\\','/'
  $out = Join-Path $dst $s[1]
  $profile = Join-Path $env:TEMP ("shot-" + [guid]::NewGuid().ToString("N").Substring(0,8))
  & $chrome --headless=new --no-sandbox --disable-gpu --hide-scrollbars `
      --force-device-scale-factor=$($s[4]) --window-size="$($s[2]),$($s[3])" `
      --user-data-dir="$profile" --screenshot="$out" "file:///$in" 2>$null | Out-Null
  if (Test-Path $out) {
    $len = [math]::Round((Get-Item $out).Length / 1KB)
    Write-Output ("OK  {0}  ({1} KB)" -f $s[1], $len)
  } else {
    Write-Output ("FAIL {0}" -f $s[1])
  }
}

