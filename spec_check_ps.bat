@echo off
chcp 65001 >nul
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"$ErrorActionPreference='SilentlyContinue';" ^
"Write-Host '==================================================';" ^
"Write-Host '  PC スペック調査 (Windows)';" ^
"Write-Host '==================================================';" ^
"Write-Host '';" ^
"Write-Host '=== OS ===';" ^
"$os=(Get-CimInstance Win32_OperatingSystem).Caption;" ^
"Write-Host ('OS         : ' + $os);" ^
"Write-Host '';" ^
"Write-Host '=== CPU ===';" ^
"$cpu=(Get-CimInstance Win32_Processor);" ^
"Write-Host ('CPU        : ' + $cpu.Name);" ^
"Write-Host ('論理コア数 : ' + $cpu.NumberOfLogicalProcessors);" ^
"Write-Host '';" ^
"Write-Host '=== メモリ (RAM) ===';" ^
"$ramB=(Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory;" ^
"$ramGB=[math]::Round($ramB/1GB);" ^
"Write-Host ('総RAM      : 約 ' + $ramGB + ' GB');" ^
"Write-Host '';" ^
"Write-Host '=== GPU ===';" ^
"if (Get-Command nvidia-smi -ErrorAction SilentlyContinue) {" ^
"  nvidia-smi --query-gpu=name,memory.total --format=csv,noheader | ForEach-Object { Write-Host ('GPU        : ' + $_) }" ^
"} else {" ^
"  Get-CimInstance Win32_VideoController | ForEach-Object { Write-Host ('GPU        : ' + $_.Name) };" ^
"  Write-Host '(注: WindowsのVRAM値は4GB超で正しく出ない場合あり。';" ^
"  Write-Host '     正確な値は nvidia-smi / タスクマネージャーで確認)'" ^
"}" ^
"Write-Host '';" ^
"Write-Host '==================================================';" ^
"Write-Host '  ローカルLLM 目安 (Gemma / Q4量子化)';" ^
"Write-Host '==================================================';" ^
"Write-Host ('検出メモリ : 約 ' + $ramGB + ' GB');" ^
"Write-Host '';" ^
"if ($ramGB -lt 8) { Write-Host 'おすすめ   : 1B ～ 4B (Q4)。軽量モデル中心。' }" ^
"elseif ($ramGB -lt 16) { Write-Host 'おすすめ   : 4B ～ 12B (Q4) あたりが快適。' }" ^
"elseif ($ramGB -lt 32) { Write-Host 'おすすめ   : 12B が快適。27B も動くが余裕は少なめ。' }" ^
"elseif ($ramGB -lt 64) { Write-Host 'おすすめ   : 27B (Q4) が快適に動作。' }" ^
"else { Write-Host 'おすすめ   : 27B を高品質量子化(Q6/Q8)でも余裕。' }" ^
"Write-Host '';" ^
"Write-Host '(GPU搭載機はVRAM容量が実際のボトルネックになる点に注意)';" ^
"Write-Host '';" ^
"Write-Host '完了。'"
echo.
pause
