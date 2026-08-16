#!/bin/bash
# speccheck.command - PC spec checker (macOS, Pythonなし)
# 使い方: ダブルクリック、または ターミナルで  bash speccheck.command
# ダブルクリックで開けない場合は、右クリック→開く、または
#   chmod +x speccheck.command   を一度実行してください。

echo "=================================================="
echo "  PC スペック調査 (macOS)"
echo "=================================================="
echo

echo "=== OS ==="
OSVER=$(sw_vers -productName 2>/dev/null)
OSNUM=$(sw_vers -productVersion 2>/dev/null)
echo "OS         : ${OSVER} ${OSNUM}"
echo

echo "=== CPU / チップ ==="
CHIP=$(sysctl -n machdep.cpu.brand_string 2>/dev/null)
CORES=$(sysctl -n hw.logicalcpu 2>/dev/null)
echo "CPU/チップ : ${CHIP:-?}"
echo "論理コア数 : ${CORES:-?}"
echo

echo "=== メモリ (RAM) ==="
MEMBYTES=$(sysctl -n hw.memsize 2>/dev/null)
if [ -n "$MEMBYTES" ]; then
    RAMGB=$(( MEMBYTES / 1073741824 ))
    echo "総RAM      : 約 ${RAMGB} GB"
else
    RAMGB=0
    echo "総RAM      : ?"
fi
echo

echo "=== GPU ==="
system_profiler SPDisplaysDataType 2>/dev/null | grep -E "Chipset Model|Total Number of Cores" | sed 's/^ *//'
if echo "$CHIP" | grep -q "Apple"; then
    echo
    echo "※ Apple Silicon はユニファイドメモリ。"
    echo "  上記の総RAMがそのままGPUで使える容量の目安になります。"
fi
echo

echo "=================================================="
echo "  ローカルLLM 目安 (Gemma / Q4量子化)"
echo "=================================================="
echo "検出メモリ : 約 ${RAMGB} GB"
echo
if   [ "$RAMGB" -lt 8 ];  then echo "おすすめ   : 1B ～ 4B (Q4)。軽量モデル中心。"
elif [ "$RAMGB" -lt 16 ]; then echo "おすすめ   : 4B ～ 12B (Q4) あたりが快適。"
elif [ "$RAMGB" -lt 32 ]; then echo "おすすめ   : 12B が快適。27B も動くが余裕は少なめ。"
elif [ "$RAMGB" -lt 64 ]; then echo "おすすめ   : 27B (Q4) が快適に動作。"
else                           echo "おすすめ   : 27B を高品質量子化(Q6/Q8)でも余裕。"
fi
echo
echo "(GPU搭載機はVRAM容量が実際のボトルネックになる点に注意)"
echo
echo "完了。"
echo
read -n 1 -s -r -p "何かキーを押すと閉じます..."
echo
