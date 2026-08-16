@echo off
chcp 65001 >nul
setlocal

set "PS1=%TEMP%\speccheck_%RANDOM%.ps1"

> "%PS1%" echo $ErrorActionPreference='SilentlyContinue'
>>"%PS1%" echo Write-Host '=================================================='
>>"%PS1%" echo Write-Host '  PC スペック調査 (Windows)'
>>"%PS1%" echo Write-Host '=================================================='
>>"%PS1%" echo Write-Host ''
>>"%PS1%" echo Write-Host '=== OS ==='
>>"%PS1%" echo $os=(Get-CimInstance Win32_OperatingSystem).Caption
>>"%PS1%" echo Write-Host ('OS         : ' + $os)
>>"%PS1%" echo Write-Host ''
>>"%PS1%" echo Write-Host '=== CPU ==='
>>"%PS1%" echo $cpu=(Get-CimInstance Win32_Processor)
>>"%PS1%" echo Write-Host ('CPU        : ' + $cpu.Name)
>>"%PS1%" echo Write-Host ('Logical cores : ' + $cpu.NumberOfLogicalProcessors)
>>"%PS1%" echo Write-Host ''
>>"%PS1%" echo Write-Host '=== メモリ (RAM) ==='
>>"%PS1%" echo $ramB=(Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory
>>"%PS1%" echo $ramGB=[math]::Round($ramB/1GB)
>>"%PS1%" echo Write-Host ('総RAM      : 約 ' + $ramGB + ' GB')
>>"%PS1%" echo Write-Host ''
>>"%PS1%" echo Write-Host '=== GPU ==='
>>"%PS1%" echo if (Get-Command nvidia-smi -ErrorAction SilentlyContinue) {
>>"%PS1%" echo   nvidia-smi --query-gpu=name,memory.total --format=csv,noheader ^| ForEach-Object { Write-Host ('GPU        : ' + $_) }
>>"%PS1%" echo } else {
>>"%PS1%" echo   Get-CimInstance Win32_VideoController ^| ForEach-Object { Write-Host ('GPU        : ' + $_.Name) }
>>"%PS1%" echo   Write-Host '(注: WindowsのVRAM値は4GB超で正しく出ない場合あり。'
>>"%PS1%" echo   Write-Host '     正確な値は nvidia-smi / タスクマネージャーで確認)'
>>"%PS1%" echo }
>>"%PS1%" echo Write-Host ''
>>"%PS1%" echo Write-Host '=================================================='
>>"%PS1%" echo Write-Host '  ローカルLLM 目安 (Gemma / Q4量子化)'
>>"%PS1%" echo Write-Host '=================================================='
>>"%PS1%" echo Write-Host ('検出メモリ : 約 ' + $ramGB + ' GB')
>>"%PS1%" echo Write-Host ''
>>"%PS1%" echo if ($ramGB -lt 8) { Write-Host 'おすすめ   : 1B ～ 4B (Q4)。軽量モデル中心。' }
>>"%PS1%" echo elseif ($ramGB -lt 16) { Write-Host 'おすすめ   : 4B ～ 12B (Q4) あたりが快適。' }
>>"%PS1%" echo elseif ($ramGB -lt 32) { Write-Host 'おすすめ   : 12B が快適。27B も動くが余裕は少なめ。' }
>>"%PS1%" echo elseif ($ramGB -lt 64) { Write-Host 'おすすめ   : 27B (Q4) が快適に動作。' }
>>"%PS1%" echo else { Write-Host 'おすすめ   : 27B を高品質量子化(Q6/Q8)でも余裕。' }
>>"%PS1%" echo Write-Host ''
>>"%PS1%" echo Write-Host '(GPU搭載機はVRAM容量が実際のボトルネックになる点に注意)'
>>"%PS1%" echo Write-Host ''
>>"%PS1%" echo Write-Host '完了。'

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%"
del "%PS1%" >nul 2>&1

echo.
pause
