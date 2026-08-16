#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
speccheck.py - PC spec checker (Windows / macOS / Linux)
ローカルLLM(Gemma等)を動かす際の目安確認用。
標準ライブラリのみ。追加インストール不要。

使い方:
    python speccheck.py
    (Windowsで python が無い場合は py speccheck.py)
"""

import platform
import subprocess
import shutil
import os
import re


def run(cmd):
    """コマンドを実行して標準出力を返す。失敗時は空文字。"""
    try:
        out = subprocess.check_output(
            cmd, shell=True, stderr=subprocess.DEVNULL,
            text=True, encoding="utf-8", errors="ignore"
        )
        return out.strip()
    except Exception:
        return ""


def human_gb(num_bytes):
    try:
        return f"{int(num_bytes) / (1024**3):.1f} GB"
    except Exception:
        return "?"


def section(title):
    print("\n" + "=" * 50)
    print(f"  {title}")
    print("=" * 50)


def get_windows():
    section("CPU")
    cpu = run('powershell -NoProfile -Command "(Get-CimInstance Win32_Processor).Name"')
    cores = run('powershell -NoProfile -Command "(Get-CimInstance Win32_Processor).NumberOfLogicalProcessors"')
    print(f"CPU        : {cpu or '?'}")
    print(f"論理コア数 : {cores or '?'}")

    section("メモリ (RAM)")
    ram = run('powershell -NoProfile -Command "(Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory"')
    print(f"総RAM      : {human_gb(ram) if ram else '?'}")

    section("GPU")
    # まず nvidia-smi を試す (VRAMが正確)
    if shutil.which("nvidia-smi"):
        smi = run('nvidia-smi --query-gpu=name,memory.total --format=csv,noheader')
        if smi:
            for line in smi.splitlines():
                print(f"GPU        : {line.strip()}")
    else:
        gpus = run('powershell -NoProfile -Command "Get-CimInstance Win32_VideoController | ForEach-Object { $_.Name }"')
        print(f"GPU        : {gpus or '?'}")
        print("(注: WindowsのVRAM値は4GB超で正しく出ない場合あり。")
        print("     正確な値は nvidia-smi / タスクマネージャーで確認)")

    return ram


def get_macos():
    section("CPU / チップ")
    chip = run("sysctl -n machdep.cpu.brand_string")
    cores = run("sysctl -n hw.logicalcpu")
    print(f"CPU/チップ : {chip or '?'}")
    print(f"論理コア数 : {cores or '?'}")

    section("メモリ (RAM)")
    mem = run("sysctl -n hw.memsize")
    print(f"総RAM      : {human_gb(mem) if mem else '?'}")

    section("GPU")
    gpu = run('system_profiler SPDisplaysDataType 2>/dev/null | grep -E "Chipset Model|Total Number of Cores"')
    print(gpu or "GPU        : ?")
    if "Apple" in (chip or ""):
        print("\n※ Apple Silicon はユニファイドメモリ。")
        print("  上記の総RAMがそのままGPUで使える容量の目安になります。")

    return mem


def get_linux():
    section("CPU")
    cpu = run("grep -m1 'model name' /proc/cpuinfo | cut -d: -f2")
    cores = run("nproc")
    print(f"CPU        : {cpu.strip() or '?'}")
    print(f"論理コア数 : {cores or '?'}")

    section("メモリ (RAM)")
    mem_kb = run("grep MemTotal /proc/meminfo | awk '{print $2}'")
    mem = int(mem_kb) * 1024 if mem_kb.isdigit() else 0
    print(f"総RAM      : {human_gb(mem) if mem else '?'}")

    section("GPU")
    if shutil.which("nvidia-smi"):
        smi = run('nvidia-smi --query-gpu=name,memory.total --format=csv,noheader')
        for line in smi.splitlines():
            print(f"GPU        : {line.strip()}")
    else:
        gpu = run("lspci | grep -i vga")
        print(f"GPU        : {gpu or '?'}")

    return mem


def advise(total_bytes):
    section("ローカルLLM 目安 (Gemma / Q4量子化)")
    try:
        gb = int(total_bytes) / (1024**3)
    except Exception:
        print("メモリ判定不可。")
        return

    print(f"検出メモリ : 約 {gb:.0f} GB\n")
    print("※ GPUのVRAMで動かすのが理想。以下はメモリ全体からのざっくり目安。\n")

    if gb < 8:
        rec = "1B ～ 4B (Q4)。軽量モデル中心。"
    elif gb < 16:
        rec = "4B ～ 12B (Q4) あたりが快適。"
    elif gb < 32:
        rec = "12B が快適。27B も動くが余裕は少なめ。"
    elif gb < 64:
        rec = "27B (Q4) が快適に動作。"
    else:
        rec = "27B を高品質量子化(Q6/Q8)でも余裕。"
    print(f"おすすめ   : {rec}")
    print("\n(GPU搭載機はVRAM容量が実際のボトルネックになる点に注意)")


def main():
    system = platform.system()
    print("PC スペック調査")
    print(f"OS         : {system} {platform.release()}")

    if system == "Windows":
        mem = get_windows()
    elif system == "Darwin":
        mem = get_macos()
    elif system == "Linux":
        mem = get_linux()
    else:
        print("未対応のOSです。")
        return

    advise(mem)
    print("\n完了。")


if __name__ == "__main__":
    main()
