# Сборка прошивки RNode для платы tern-nRF52840 ProMicro (Windows PowerShell 5.1+).
#
#   .\tern\build.ps1 -Setup                — один раз: ядро adafruit:nrf52 и библиотеки
#   .\tern\build.ps1 -Module M30S          — сборка для E22-xxxM30S (1 Вт), батарея 2S
#   .\tern\build.ps1 -Module M33S -Battery 3S  — E22-xxxM33S (2 Вт), батарея 3S
# Результат: tern\build\rnode_firmware_tern_promicro_<модуль>_<батарея>.uf2
#
# Модуль указывается обязательно: от него зависит, какую мощность прошивка подаёт с чипа на усилитель.
# Пакет нашей платы (tern\arduino\hardware) и библиотеки ставятся в папку tern\arduino,
# общие настройки arduino-cli на компьютере не меняются.

param(
    [switch]$Setup,
    [ValidateSet('M30S', 'M33S')]
    [string]$Module,
    [ValidateSet('2S', '3S')]
    [string]$Battery = '2S'
)

$ErrorActionPreference = 'Stop'

$TernDir  = $PSScriptRoot
$RepoDir  = Split-Path $TernDir -Parent
$BuildDir = Join-Path $TernDir 'build'
$Fqbn     = 'tern:nrf52:tern_promicro'
$BoardModel = '0x5A' # BOARD_TERN_PROMICRO в Boards.h

$env:ARDUINO_DIRECTORIES_USER = Join-Path $TernDir 'arduino'
$env:ARDUINO_BOARD_MANAGER_ADDITIONAL_URLS = 'https://adafruit.github.io/arduino-board-index/package_adafruit_index.json'
$env:ARDUINO_LIBRARY_ENABLE_UNSAFE_INSTALL = 'true'

# Терминал, открытый до установки, не видит обновлённый PATH — тогда берём путь установки winget
if (-not (Get-Command arduino-cli -ErrorAction SilentlyContinue)) {
    $cliDir = Join-Path $env:ProgramFiles 'Arduino CLI'
    if (Test-Path (Join-Path $cliDir 'arduino-cli.exe')) {
        $env:Path = "$cliDir;$env:Path"
    } else {
        throw 'arduino-cli не найден. Установите: winget install ArduinoSA.CLI (и перезапустите терминал).'
    }
}

# Нужен arduino-cli >= 1.0.4 (флаг runtime.use_core_platform_path_for_runtime_platform_path в boards.txt).
# Вывод версии локализован («Version:» / «Версия:»), поэтому ищем просто первое число вида x.y.z.
$verText = (arduino-cli version) -join ' '
if ($verText -match '(\d+)\.(\d+)\.(\d+)') {
    $ver = [version]"$($Matches[1]).$($Matches[2]).$($Matches[3])"
    if ($ver -lt [version]'1.0.4') { throw "arduino-cli $ver слишком старый, нужен 1.0.4 или новее." }
}

if ($Setup) {
    arduino-cli core update-index
    arduino-cli core install adafruit:nrf52
    $libs = @(
        'Adafruit SSD1306',
        'Adafruit SH110X',
        'Adafruit ST7735 and ST7789 Library',
        'Adafruit NeoPixel',
        'XPowersLib',
        'Crypto',
        'GxEPD2'
    )
    foreach ($lib in $libs) { arduino-cli lib install $lib }
    Write-Host 'Готово: ядро и библиотеки установлены.' -ForegroundColor Green
    return
}

if (-not $Module) {
    throw 'Укажите модуль E22: -Module M30S (1 Вт) или -Module M33S (2 Вт).'
}

$flags = "-DBOARD_MODEL=$BoardModel -DTERN_E22_$Module"
if ($Battery -eq '3S') { $flags += ' -DTERN_BATTERY_3S' }

New-Item -ItemType Directory -Force $BuildDir | Out-Null

arduino-cli compile --fqbn $Fqbn `
    --build-property "compiler.cpp.extra_flags=$flags" `
    --output-dir $BuildDir `
    $RepoDir
if ($LASTEXITCODE -ne 0) { throw 'Ошибка компиляции.' }

# hex -> uf2 (для прошивки перетаскиванием на диск NRF52BOOT)
$coreRoot = Join-Path $env:LOCALAPPDATA 'Arduino15\packages\adafruit\hardware\nrf52'
$core = Get-ChildItem $coreRoot -Directory | Sort-Object { [version]$_.Name } | Select-Object -Last 1
$uf2conv = Join-Path $core.FullName 'tools\uf2conv\uf2conv.py'
$hex = Join-Path $BuildDir 'RNode_Firmware.ino.hex'
$uf2 = Join-Path $BuildDir "rnode_firmware_tern_promicro_$($Module.ToLower())_$($Battery.ToLower()).uf2"

python $uf2conv -f 0xADA52840 -c -o $uf2 $hex
if ($LASTEXITCODE -ne 0) { throw 'Ошибка преобразования в UF2.' }

Write-Host "Готово: $uf2" -ForegroundColor Green
