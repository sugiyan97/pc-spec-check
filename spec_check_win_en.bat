@echo off
setlocal

set "PS1=%TEMP%\speccheck_%RANDOM%.ps1"

> "%PS1%" echo $ErrorActionPreference='SilentlyContinue'
>>"%PS1%" echo Write-Host '=================================================='
>>"%PS1%" echo Write-Host '  PC Spec Check (Windows)'
>>"%PS1%" echo Write-Host '=================================================='
>>"%PS1%" echo Write-Host ''
>>"%PS1%" echo Write-Host '=== OS ==='
>>"%PS1%" echo $os=(Get-CimInstance Win32_OperatingSystem).Caption
>>"%PS1%" echo Write-Host ('OS            : ' + $os)
>>"%PS1%" echo Write-Host ''
>>"%PS1%" echo Write-Host '=== CPU ==='
>>"%PS1%" echo $cpu=(Get-CimInstance Win32_Processor)
>>"%PS1%" echo Write-Host ('CPU           : ' + $cpu.Name)
>>"%PS1%" echo Write-Host ('Logical cores : ' + $cpu.NumberOfLogicalProcessors)
>>"%PS1%" echo Write-Host ''
>>"%PS1%" echo Write-Host '=== RAM ==='
>>"%PS1%" echo $ramB=(Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory
>>"%PS1%" echo $ramGB=[math]::Round($ramB/1GB)
>>"%PS1%" echo Write-Host ('Total RAM     : approx ' + $ramGB + ' GB')
>>"%PS1%" echo Write-Host ''
>>"%PS1%" echo Write-Host '=== GPU ==='
>>"%PS1%" echo if (Get-Command nvidia-smi -ErrorAction SilentlyContinue) {
>>"%PS1%" echo   nvidia-smi --query-gpu=name,memory.total --format=csv,noheader ^| ForEach-Object { Write-Host ('GPU           : ' + $_) }
>>"%PS1%" echo } else {
>>"%PS1%" echo   Get-CimInstance Win32_VideoController ^| ForEach-Object { Write-Host ('GPU           : ' + $_.Name) }
>>"%PS1%" echo   Write-Host '(Note: Windows VRAM value may be wrong above 4GB.'
>>"%PS1%" echo   Write-Host ' Check nvidia-smi or Task Manager for accurate VRAM.)'
>>"%PS1%" echo }
>>"%PS1%" echo Write-Host ''
>>"%PS1%" echo Write-Host '=================================================='
>>"%PS1%" echo Write-Host '  Local LLM guide (Gemma / Q4 quant)'
>>"%PS1%" echo Write-Host '=================================================='
>>"%PS1%" echo Write-Host ('Detected RAM  : approx ' + $ramGB + ' GB')
>>"%PS1%" echo Write-Host ''
>>"%PS1%" echo if ($ramGB -lt 8) { Write-Host 'Recommend     : 1B - 4B (Q4). Lightweight models.' }
>>"%PS1%" echo elseif ($ramGB -lt 16) { Write-Host 'Recommend     : 4B - 12B (Q4) comfortable.' }
>>"%PS1%" echo elseif ($ramGB -lt 32) { Write-Host 'Recommend     : 12B comfortable. 27B works but tight.' }
>>"%PS1%" echo elseif ($ramGB -lt 64) { Write-Host 'Recommend     : 27B (Q4) runs comfortably.' }
>>"%PS1%" echo else { Write-Host 'Recommend     : 27B at high quant (Q6/Q8) with room.' }
>>"%PS1%" echo Write-Host ''
>>"%PS1%" echo Write-Host '(On GPU machines, VRAM is the real bottleneck.)'
>>"%PS1%" echo Write-Host ''
>>"%PS1%" echo Write-Host 'Done.'

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%"
del "%PS1%" >nul 2>&1

echo.
pause
