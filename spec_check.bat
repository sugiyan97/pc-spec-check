@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

echo ==================================================
echo   PC スペック調査 (Windows)
echo ==================================================
echo.

echo === OS ===
for /f "tokens=2 delims==" %%A in ('wmic os get Caption /value 2^>nul ^| find "="') do set OSNAME=%%A
echo OS         : !OSNAME!
echo.

echo === CPU ===
for /f "tokens=2 delims==" %%A in ('wmic cpu get Name /value 2^>nul ^| find "="') do set CPUNAME=%%A
for /f "tokens=2 delims==" %%A in ('wmic cpu get NumberOfLogicalProcessors /value 2^>nul ^| find "="') do set CORES=%%A
echo CPU        : !CPUNAME!
echo 論理コア数 : !CORES!
echo.

echo === メモリ (RAM) ===
for /f "tokens=2 delims==" %%A in ('wmic ComputerSystem get TotalPhysicalMemory /value 2^>nul ^| find "="') do set RAMBYTES=%%A
set /a RAMGB=!RAMBYTES:~0,-3! / 1048576
echo 総RAM      : 約 !RAMGB! GB
echo.

echo === GPU ===
where nvidia-smi >nul 2>&1
if !errorlevel! == 0 (
    for /f "tokens=*" %%A in ('nvidia-smi --query-gpu^=name^,memory.total --format^=csv^,noheader 2^>nul') do echo GPU        : %%A
) else (
    for /f "tokens=2 delims==" %%A in ('wmic path Win32_VideoController get Name /value 2^>nul ^| find "="') do echo GPU        : %%A
    echo (注: WindowsのVRAM値は4GB超で正しく出ない場合あり。
    echo      正確な値は nvidia-smi / タスクマネージャーで確認)
)
echo.

echo ==================================================
echo   ローカルLLM 目安 (Gemma / Q4量子化)
echo ==================================================
echo 検出メモリ : 約 !RAMGB! GB
echo.
if !RAMGB! LSS 8 (
    echo おすすめ   : 1B ～ 4B (Q4)。軽量モデル中心。
) else if !RAMGB! LSS 16 (
    echo おすすめ   : 4B ～ 12B (Q4) あたりが快適。
) else if !RAMGB! LSS 32 (
    echo おすすめ   : 12B が快適。27B も動くが余裕は少なめ。
) else if !RAMGB! LSS 64 (
    echo おすすめ   : 27B (Q4) が快適に動作。
) else (
    echo おすすめ   : 27B を高品質量子化(Q6/Q8)でも余裕。
)
echo.
echo (GPU搭載機はVRAM容量が実際のボトルネックになる点に注意)
echo.
echo 完了。
pause
