# spec_check

PC のスペック（CPU / メモリ / GPU）を調べ、ローカルで動かせる **Gemma**（Q4量子化）のおおよそのサイズ目安を表示する簡易ツールです。

Windows / macOS / Linux に対応。Python 版と、Python なしで動く OS ネイティブ版を用意しています。

## ファイル一覧

| ファイル | 対象OS | Python | 実行方法 |
|---|---|---|---|
| `spec_check.py` | Windows / Mac / Linux | 必要 | `python spec_check.py` |
| `spec_check.bat` | Windows | 不要 | ダブルクリック |
| `spec_check.command` | macOS | 不要 | ダブルクリック |
| `spec_check.sh` | macOS / Linux | 不要 | `bash spec_check.sh` |

`spec_check.command` と `spec_check.sh` は中身が同一です。ダブルクリックで動かしたいなら `.command`、テキストとして中身を見たり編集・コピーしたいなら `.sh` を使ってください。

## 使い方

### Python 版（全OS共通）

```bash
python spec_check.py
```

`python` で動かない場合は次を試してください。

- Windows: `py spec_check.py`
- Mac / Linux: `python3 spec_check.py`

### Windows（Python なし）

`spec_check.bat` をダブルクリックするだけです。ウィンドウは自動で閉じません（`pause` あり）。

### macOS（Python なし）

`spec_check.command` をダブルクリックします。「開発元を確認できない」と出て開けない場合は、右クリック →「開く」を選んでください。

ダブルクリックで動かない場合は、ターミナルで一度だけ実行権限を付けてから開くと確実です。

```bash
chmod +x spec_check.command
```

コピーや中身確認をしたい場合は `spec_check.sh` を使い、ターミナルから実行します。

```bash
bash spec_check.sh
```

## 出力内容

- OS
- CPU 名 / 論理コア数
- 総メモリ（RAM）
- GPU 名（NVIDIA GPU があれば VRAM も表示）
- 検出メモリ量にもとづく Gemma サイズの目安

出力例（イメージ）:

```
=== メモリ (RAM) ===
総RAM      : 約 32 GB

=== GPU ===
GPU        : NVIDIA GeForce RTX 4090, 24576 MiB

ローカルLLM 目安 (Gemma / Q4量子化)
検出メモリ : 約 32 GB
おすすめ   : 27B (Q4) が快適に動作。
```

## Gemma サイズの目安

判定は総メモリ量を基準にした簡易的なものです。

| メモリ | おすすめ（Q4量子化） |
|---|---|
| 8 GB 未満 | 1B ～ 4B |
| 8 ～ 16 GB | 4B ～ 12B |
| 16 ～ 32 GB | 12B（27B も可、余裕は少なめ） |
| 32 ～ 64 GB | 27B |
| 64 GB 以上 | 27B（Q6/Q8 でも余裕） |

## 注意点

- **GPU で動かす場合、実際のボトルネックは VRAM 容量です。** 本ツールの判定は総 RAM 基準のため、GPU 搭載機ではあくまで参考値として見てください。
- **Apple Silicon** はユニファイドメモリのため、総 RAM がそのまま GPU で使える容量の目安になります。
- **Windows の VRAM 表示**は 4GB を超えると正しく出ないことがある既知の制限があります。`nvidia-smi` があればそちらの値を優先します。正確な値はタスクマネージャーでも確認できます。
- **`spec_check.bat` について**: 内部で `wmic` を使用しています。新しい Windows 11 では `wmic` が非推奨・削除されつつあり、値が空になる場合があります。その場合は `spec_check.py`（PowerShell ベース）を利用してください。

## 動作の仕組み

各スクリプトは OS 標準のコマンドでスペックを取得しています。

- Windows: `wmic`（bat）/ `Get-CimInstance`（py）、GPU は可能なら `nvidia-smi`
- macOS: `sysctl`、`system_profiler`
- Linux: `/proc/cpuinfo`、`/proc/meminfo`、`nvidia-smi` または `lspci`

外部ライブラリのインストールは不要です。
