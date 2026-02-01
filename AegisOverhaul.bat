@echo off
setlocal EnableDelayedExpansion

rem コードページをUTF-8に設定
chcp 65001 >nul

rem ===================================================
rem PCメンテナンスおよびネットワーク最適化用バッチスクリプト
rem 作成日: 2025年
rem 概要: Windowsシステムの包括的なメンテナンスと最適化を実行
rem ===================================================

rem 管理者権限の確認
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo 管理者権限が必要です。バッチファイルを右クリックし、「管理者として実行」を選択してください。
    pause
    exit /b
)
echo 管理者権限で実行されています。

cd /d C:

rem ===================================================
rem 作業用サービス停止
rem ===================================================
echo [作業用サービス停止] 作業用サービスのプロセスを停止しています...
for %%P in (explorer.exe Teams.exe ms-teams.exe msedge.exe) do (
    taskkill /f /im %%P >nul 2>&1
)
timeout /t 1 /nobreak >nul


rem ===================================================
rem アプリケーション更新セクション
rem ===================================================
echo [アプリケーション更新] wingetによるアプリケーションの更新を開始...
winget upgrade --all --include-unknown --silent --disable-interactivity --accept-source-agreements --accept-package-agreements
echo  - wingetによるアプリケーションの更新が完了しました

echo [アプリケーション更新] Microsoft Store アプリのリセットを開始...
powershell -Command "Stop-Process -Name StartMenuExperienceHost -Force -ErrorAction SilentlyContinue"
powershell -Command "Get-AppxPackage | ForEach-Object { Add-AppxPackage -DisableDevelopmentMode -Register \"$($_.InstallLocation)\AppXManifest.xml\" -ErrorAction SilentlyContinue }"
powershell -Command "Get-AppxPackage Microsoft.Windows.StartMenuExperienceHost | Reset-AppxPackage"
echo  - すべてのストアアプリのリセットを完了しました

rem ===================================================
rem サービスが使用しているファイルを削除するために停止しています。PC再起動で再開されます。
rem ===================================================
echo [ディスククリーンアップ] Windows Updateキャッシュを削除しています...
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase >nul 2>&1
echo  - Windows Updateキャッシュを削除しました


rem ===================================================
rem MMAgent設定（SysMainが必要）
rem ===================================================
echo [システム最適化] MMAgentを設定しています...
rem メモリ圧縮: メモリ不足時にデータを圧縮してメモリを節約する機能
powershell -Command "Enable-MMAgent -MemoryCompression"
rem ページ結合: 同一内容のメモリページを統合する機能（CPU負荷があるため無効）
powershell -Command "Disable-MMAgent -PageCombining"
rem OperationAPI: 特定の操作シナリオを記録・最適化する機能（ゲーム用途では不要）
powershell -Command "Disable-MMAgent -OperationAPI"
rem MaxOperationAPIFiles: OperationAPIのプリフェッチファイル最大数（OperationAPI無効時は実質無効）
powershell -Command "Set-MMAgent -MaxOperationAPIFiles 256"
rem ApplicationLaunchPrefetching: 過去の起動パターンを学習し必要なファイルを先読みする機能
powershell -Command "Enable-MMAgent -ApplicationLaunchPrefetching"
rem ApplicationPreLaunch: よく使うアプリをバックグラウンドで事前起動する機能（メモリ消費するため無効）
powershell -Command "Disable-MMAgent -ApplicationPreLaunch"
echo  - MMAgentの設定を完了しました

echo [サービス管理] サービスを停止しています...
for %%S in (bits wuauserv usosvc FontCache SysMain wsearch) do (
    net stop "%%S" >nul 2>&1
    echo  - %%S サービスを停止しました
)

rem ===================================================
rem ファイルクリーンアップセクション
rem ===================================================
echo [ファイルクリーンアップ] システム関連の一時ファイルを削除しています...

rem 各種キャッシュディレクトリのクリーンアップ
for %%D in (
    "%APPDATA%\discord\Cache"
    "%APPDATA%\discord\Code Cache"
    "%APPDATA%\discord\GPUCache"
    "%APPDATA%\discord\VideoDecodeStats"
    "%APPDATA%\Microsoft\Office\Recent"
    "%LOCALAPPDATA%\Microsoft\FontCache"
    "%LOCALAPPDATA%\Microsoft\IME\15.0\IMEJP\Cache"
    "%LOCALAPPDATA%\Microsoft\IME\15.0\IMEJP\Watson"
    "%LOCALAPPDATA%\Microsoft\Internet Explorer"
    "%LOCALAPPDATA%\Microsoft\Office\16.0\Wef"
    "%LOCALAPPDATA%\Microsoft\Office\SolutionPackages"
    "%LOCALAPPDATA%\Microsoft\Outlook\HubAppFileCache"
    "%LOCALAPPDATA%\Microsoft\Windows\AppCache"
    "%LOCALAPPDATA%\Microsoft\Windows\Explorer"
    "%LOCALAPPDATA%\Microsoft\Windows\IdentityCache"
    "%LOCALAPPDATA%\Microsoft\Windows\INetCache"
    "%LOCALAPPDATA%\Microsoft\Windows\OneAuth"
    "%LOCALAPPDATA%\Microsoft\Windows\Temporary Internet Files"
    "%LOCALAPPDATA%\Microsoft\Windows\WebCache"
    "%LOCALAPPDATA%\CrashDumps"
    "%LOCALAPPDATA%\D3DSCache"
    "%LOCALAPPDATA%\NuGet"
    "%LOCALAPPDATA%\NVIDIA\DXCache"
    "%LOCALAPPDATA%\Temp"
    "%LOCALAPPDATA%\UnrealEngine"
    "%LOCALAPPDATA%\Microsoft\TokenBroker"
    "%LOCALAPPDATA%\Microsoft\OneAuth"
    "%LOCALAPPDATA%\Microsoft\IdentityCache"
    "%LOCALAPPDATA%\Packages\MSTeams_8wekyb3d8bbwe"
    "%LocalAppData%\Packages\Microsoft.AAD.BrokerPlugin_cw5n1h2txyewy"
    "%ProgramData%\LGHUB\cache"
    "%ProgramData%\Microsoft\EdgeUpdate\Log"
    "%ProgramData%\Microsoft\Network\Downloader"
    "%ProgramData%\Microsoft\Search\Data\Applications\Windows"
    "%ProgramData%\Microsoft\Windows Defender\Definition Updates\Backup"
    "%ProgramData%\Microsoft\Windows Defender\Scans\History\Results\Resource"
    "%ProgramData%\Microsoft\Windows Defender\Support"
    "%ProgramData%\USOShared\Logs"
    "%SystemRoot%\Logs"
    "%SystemRoot%\ServiceProfiles\LocalService\AppData\Local\FontCache"
    "%SystemRoot%\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Cache"
    "%SystemRoot%\System32\catroot2"
    "%SystemRoot%\System32\LogFiles"
    "%SystemRoot%\SystemTemp"
    "%SystemRoot%\Temp"
    "%USERPROFILE%\AppData\LocalLow\Intel"
    "%USERPROFILE%\AppData\LocalLow\Microsoft\CryptnetUrlCache"
    "%USERPROFILE%\Recent"
    "%USERPROFILE%\AppData\Local\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams"
) do (
    call :CleanDirectory "%%~D"
)

rem 不要なディレクトリの削除
echo [ファイルクリーンアップ] 不要なディレクトリを削除しています...
for %%D in (
    "%SystemRoot%\SoftwareDistribution"
    "%SystemRoot%\Prefetch"
    "%USERPROFILE%\.aws"
    "%USERPROFILE%\.config"
    "%USERPROFILE%\.dbus-keyrings"
    "%USERPROFILE%\.dotnet"
    "%USERPROFILE%\.monica-code"
    "%USERPROFILE%\.nuget"
    "%USERPROFILE%\.omnisharp"
    "%USERPROFILE%\.templateengine"
    "%USERPROFILE%\AppData\LocalLow\NVIDIA\PerDriverVersion\DXCache"
    "%USERPROFILE%\Bootstrap Studio Backups"
    "%USERPROFILE%\intellij-chatgpt"
    "C:\$SysReset"
    "C:\AMD"
    "C:\Intel"
    "C:\log"
    "C:\OneDriveTemp"
    "C:\PerfLogs"
    "C:\SWSetup"
    "C:\Windows.old"
) do (
    rmdir /s /q %%D >nul 2>&1
)

rem 特定のファイル削除
echo [ファイルクリーンアップ] キャッシュファイルを削除しています...
for %%F in (
    "%LOCALAPPDATA%\Microsoft\Outlook\*.nst"
    "%LOCALAPPDATA%\Microsoft\Outlook\*.ost"
    "%LOCALAPPDATA%\IconCache.db"
    "%LOCALAPPDATA%\Microsoft\Windows\Explorer\iconcache_*.db"
    "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*.db"
    "%WinDir%\System32\FNTCACHE.DAT"
    "%APPDATA%\Cursor\User\globalStorage\state.vscdb.corrupted.*"
) do (
    del /q /f %%F >nul 2>&1
)

rem ブラウザキャッシュのクリーンアップ
echo [ファイルクリーンアップ] ブラウザキャッシュを削除しています...
for /d %%b in (
    "%LOCALAPPDATA%\BraveSoftware\Brave-Browser"
    "%LOCALAPPDATA%\Microsoft\Edge"
    "%LOCALAPPDATA%\Google\Chrome"
    "%LOCALAPPDATA%\Google\Chrome Beta"
    "%LOCALAPPDATA%\Google\Chrome Dev"
    "%LOCALAPPDATA%\Vivaldi"
    "%LOCALAPPDATA%\Perplexity\Comet"
    ) do (
    if exist "%%~b\Temp" (
        call :CleanDirectory "%%~b\Temp"
    )
    if exist "%%~b\User Data\Safe Browsing" (
        call :CleanDirectory "%%~b\User Data\Safe Browsing"
    )
    if exist "%%~b\User Data\CertificateRevocation" (
        call :CleanDirectory "%%~b\User Data\CertificateRevocation"
    )
    if exist "%%~b\User Data\optimization_guide_model_store" (
        call :CleanDirectory "%%~b\User Data\optimization_guide_model_store"
    )
    if exist "%%~b\User Data\BrowserMetrics" (
        call :CleanDirectory "%%~b\User Data\BrowserMetrics"
    )
    if exist "%%~b\User Data\component_crx_cache" (
        call :CleanDirectory "%%~b\User Data\component_crx_cache"
    )
    if exist "%%~b\User Data\Crashpad" (
        call :CleanDirectory "%%~b\User Data\Crashpad"
    )
    if exist "%%~b\User Data\extensions_crx_cache" (
        call :CleanDirectory "%%~b\User Data\extensions_crx_cache"
    )
    if exist "%%~b\User Data\GraphiteDawnCache" (
        call :CleanDirectory "%%~b\User Data\GraphiteDawnCache"
    )
    if exist "%%~b\User Data\GrShaderCache" (
        call :CleanDirectory "%%~b\User Data\GrShaderCache"
    )
    if exist "%%~b\User Data\ShaderCache" (
        call :CleanDirectory "%%~b\User Data\ShaderCache"
    )
    if exist "%%~b\User Data\WidevineCdm" (
        call :CleanDirectory "%%~b\User Data\WidevineCdm"
    )

    for /d %%p in ("%%~b\User Data\*") do (
        if exist "%%~p\Cache" (
            call :CleanDirectory "%%~p\Cache"
        )
        if exist "%%~p\Code Cache" (
            call :CleanDirectory "%%~p\Code Cache"
        )
        if exist "%%~p\Service Worker" (
            call :CleanDirectory "%%~p\Service Worker"
        )
        if exist "%%~p\File System" (
            call :CleanDirectory "%%~p\File System"
        )
        if exist "%%~p\GPUCache" (
            call :CleanDirectory "%%~p\GPUCache"
        )
        if exist "%%~p\JumpListIconsRecentClosed" (
            call :CleanDirectory "%%~p\JumpListIconsRecentClosed"
        )
        if exist "%%~p\JumpListIconsTopSites" (
            call :CleanDirectory "%%~p\JumpListIconsTopSites"
        )
        if exist "%%~p\IndexedDB" (
            call :CleanDirectory "%%~p\IndexedDB"
        )
        if exist "%%~p\WebStorage" (
            call :CleanDirectory "%%~p\WebStorage"
        )
        if exist "%%~p\DawnGraphiteCache" (
            call :CleanDirectory "%%~p\DawnGraphiteCache"
        )
        if exist "%%~p\DawnWebGPUCache" (
            call :CleanDirectory "%%~p\DawnWebGPUCache"
        )
        if exist "%%~p\Shared Dictionary" (
            call :CleanDirectory "%%~p\Shared Dictionary"
        )
        if exist "%%~p\screen_ai" (
            call :CleanDirectory "%%~p\screen_ai"
        )
        if exist "%%~p\CRXTelemetry" (
            call :CleanDirectory "%%~p\CRXTelemetry"
        )
        if exist "%%~p\Extension State" (
            call :CleanDirectory "%%~p\Extension State"
        )
        if exist "%%~p\VideoDecodeStats" (
            call :CleanDirectory "%%~p\VideoDecodeStats"
        )
        if exist "%%~p\blob_storage" (
            call :CleanDirectory "%%~p\blob_storage"
        )
        if exist "%%~p\Media Cache" (
            call :CleanDirectory "%%~p\Media Cache"
        )
        if exist "%%~p\Reporting and NEL" (
            call :CleanDirectory "%%~p\Reporting and NEL"
        )
        if exist "%%~p\CertificateTransparency" (
            call :CleanDirectory "%%~p\CertificateTransparency"
        )
        if exist "%%~p\DawnCache" (
            call :CleanDirectory "%%~p\DawnCache"
        )
    )
)

rem ゴミ箱を空にする
echo [ファイルクリーンアップ] ゴミ箱を空にしています...
powershell -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"
echo  - ゴミ箱を空にしました

rem ===================================================
rem Windows Defender最適化セクション
rem ===================================================
echo [Windows Defender] 定義ファイル更新を実行しています...
rem Windows Defender の定義ファイル更新を実行
"%ProgramFiles%\Windows Defender\MpCmdRun.exe" -removedefinitions -dynamicsignatures >nul 2>&1
"%ProgramFiles%\Windows Defender\MpCmdRun.exe" -SignatureUpdate >nul 2>&1
echo  - Windows Defender の定義ファイルを更新しました

rem ===================================================
rem システムメンテナンスセクション
rem ===================================================
echo [ディスククリーンアップ] システムトレイアイコンをリセットしています...
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\TrayNotify" /v IconStreams /f >nul 2>&1
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\TrayNotify" /v PastIconsStream /f >nul 2>&1
timeout /t 1 /nobreak >nul
echo  - システムトレイアイコンをリセットしました

echo [レジストリ最適化] Office/Teams/IdentityCRL ログイン情報を削除しています...
reg delete "HKCU\Software\Microsoft\Office\15.0\Common\Identity" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Office\16.0\Common\Identity" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Office\Teams" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\IdentityCRL" /f >nul 2>&1
rem カスタマーエクスペリエンス向上プログラム (CEIP) を無効化
reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d 0 /f >nul 2>&1
rem フィードバックを求める通知を無効化
reg add "HKCU\Software\Microsoft\Siuf\Rules" /v "NumberOfSIUFInPeriod" /t REG_DWORD /d 0 /f >nul 2>&1
echo  - Office/Teams/IdentityCRL/CEIP/Feedback の設定を完了しました

echo [システム最適化] 固定キー機能を無効化しています...
reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v "Flags" /t REG_SZ /d "506" /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\ToggleKeys" /v "Flags" /t REG_SZ /d "58" /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "Flags" /t REG_SZ /d "122" /f >nul 2>&1
echo  - 固定キー機能を無効化しました

echo [システム最適化] GameDVR (録画機能) のみを無効化しています (Win+Gは使用可能)...
rem バックグラウンド録画とキャプチャ機能を無効化
reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
echo  - GameDVR (録画機能) を無効化しました

rem 電力スロットリング無効化（デスクトップPCとしての使い方なら設定はしてもOK）
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v PowerThrottlingOff /t REG_DWORD /d 1 /f >nul 2>&1

rem ===================================================
rem オーディオ最適化セクション（安全性重視版）
rem ===================================================
rem マルチメディアタスク優先度を上げる（効果あるらしい）
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Playback" /v "Priority" /t REG_DWORD /d 6 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Capture" /v "Priority" /t REG_DWORD /d 6 /f >nul 2>&1
echo  - オーディオ優先度最適化を完了しました

rem NVIDIA GPU の MSI MessageNumberLimit を削除（CPU0集中対策）（効果あるらしい）
echo [システム最適化] NVIDIA GPU の割り込み分散設定を最適化しています...
powershell -NoProfile -Command "Get-CimInstance -ClassName Win32_PnPEntity | Where-Object { $_.Name -like '*NVIDIA*' -and $_.DeviceID -like '*VEN_10DE*' } | ForEach-Object { $path = \"HKLM:\SYSTEM\CurrentControlSet\Enum\$($_.DeviceID)\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties\"; if (Test-Path $path) { Remove-ItemProperty -Path $path -Name 'MessageNumberLimit' -ErrorAction SilentlyContinue } }"
echo  - NVIDIA GPU の割り込み分散設定を最適化しました（再起動後に有効になります）

rem ダウンロードフォルダなどが英語になっているのを修復する
regsvr32 shell32.dll /i:U /s
echo  - フォルダ名を修復しました

rem スタートアップフォルダのアプリの起動速度を向上
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v "WaitForIdleState" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v "StartupDelayInMSec" /t REG_DWORD /d 0 /f
echo  - スタートアップフォルダのアプリの起動速度を向上しました

rem リモートデスクトップのFPSを60FPSに設定
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations" /v DWMFRAMEINTERVAL /t REG_DWORD /d 15 /f
echo  - リモートデスクトップのFPSを60FPSに設定しました

rem 電源プランを初期化
powercfg /restoredefaultschemes >nul 2>&1
powercfg /setactive SCHEME_BALANCED >nul 2>&1

rem ディスプレイ消灯時間を設定
powercfg /change monitor-timeout-ac 180
powercfg /change monitor-timeout-dc 30

rem スタンバイ時間を設定
powercfg /change standby-timeout-ac 0
powercfg /change standby-timeout-dc 0

rem 電源ボタンとカバーの動作設定
rem 電源接続時：電源ボタンでシャットダウン (0:何もしない, 1:スリープ, 2:休止, 3:シャットダウン)
powercfg /setacvalueindex SCHEME_CURRENT SUB_BUTTONS PBUTTONACTION 3
rem 電源接続時：カバーを閉じても何もしない
powercfg /setacvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 0
rem バッテリー駆動時：電源ボタンでシャットダウン
powercfg /setdcvalueindex SCHEME_CURRENT SUB_BUTTONS PBUTTONACTION 3
rem バッテリー駆動時：カバーを閉じるとスリープ
powercfg /setdcvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 0
rem 設定を適用
powercfg /setactive SCHEME_CURRENT

echo  - 電源プランをWindows標準にリセットしました

rem 休止状態をオフにする
powercfg /hibernate off
echo  - 休止状態を無効化しました

rem 接続しているすべてのSSDへTRIMコマンドを発行する
defrag /C /L /B
echo  - SSD TRIM コマンドを実行しました

rem 時刻同期の設定と実行
net stop w32time >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" /v "NtpServer" /t REG_SZ /d "ntp.jst.mfeed.ad.jp" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" /v "Type" /t REG_SZ /d "NTP" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v "AnnounceFlags" /t REG_DWORD /d 5 /f
net start w32time >nul 2>&1

rem ===================================================
rem ネットワーク最適化セクション
rem ===================================================
echo [ネットワーク最適化] ネットワーク設定をリセットしています...
rem ネットワークアダプタ詳細設定（ARPオフロード等）を含むネットワーク構成を再検出して既定に戻す
rem 注意: VPN/仮想アダプタ等も再構成されるため、必要に応じて再設定してください
rem netcfg -d

rem DNSキャッシュとHTTPログのクリア
netsh http flush logbuffer
netsh http delete cache

rem プロキシ設定のリセット
netsh winhttp reset proxy
netsh winhttp reset autoproxy

rem ファイアウォールのリセット（現在はコメントアウト）
rem netsh advfirewall reset

rem 重要なTCP/IP設定リセット
netsh winsock reset
netsh int tcp reset
netsh int tcp set global default
netsh int ip reset
route /f
arp -d *

rem IPアドレス操作
nbtstat -R
nbtstat -RR
ipconfig /registerdns
ipconfig /flushdns
ipconfig /release
ipconfig /renew
ipconfig /renew6

echo [ネットワーク最適化] TCP設定を最適化しています...
netsh int tcp set global rsc=enabled
netsh int tcp set global ecncapability=enabled
netsh int tcp set global timestamps=disabled
netsh int tcp set global rss=enabled
netsh int tcp set global fastopen=enabled
netsh int tcp set global autotuninglevel=normal
netsh int ipv6 set global loopbacklargemtu=disable
netsh int ipv4 set global loopbacklargemtu=disable
echo  - TCP設定を最適化しました

rem ===================================================
rem エクスプローラー設定セクション（エクスプローラー停止中に実行）
rem ===================================================
echo [エクスプローラー] フォルダテンプレートを汎用に固定しています...
reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell" /v FolderType /t REG_SZ /d "NotSpecified" /f >nul 2>&1
echo  - すべてのフォルダをGeneral Items（汎用）に統一しました

echo [エクスプローラー] フォルダビュー設定キャッシュをクリアしています...
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\BagMRU" /f >nul 2>&1
echo  - フォルダビュー設定キャッシュをクリアしました

rem ===================================================
rem エクスプローラーの起動プロセスを再開(操作ガード対策)
rem ===================================================
start explorer.exe
echo  - エクスプローラーのキャッシュをクリアし、パフォーマンス設定を最適化しました

rem ===================================================
rem 最終クリーンアップセクション
rem ===================================================
echo [最終クリーンアップ] イベントビューアーのログを削除しています...
powershell -Command "wevtutil el | ForEach-Object { try { wevtutil cl \"$_\" 2>$null } catch {} }"
echo  - イベントビューアーのログを削除しました（一部のシステムログは保護されているため削除できない場合があります）

echo [最終クリーンアップ] Microsoft Store アプリのキャッシュをクリアしています...
WSReset.exe
echo  - Microsoft Store のキャッシュをクリアしました

echo.
echo すべてのリセット処理が完了しました。
echo 一部の設定は再起動後に完全に反映されます。
echo.
echo [再起動] システムを再起動しています...
shutdown /r /f /t 0

endlocal
exit /b

rem ===================================================
rem サブルーチン: ディレクトリクリーンアップ
rem ===================================================
:CleanDirectory
setlocal EnableDelayedExpansion
if not exist "%~1" (
    echo  - スキップ: %~1 ^(存在しません^)
    endlocal
    goto :eof
)

set "TARGET_DIR=%~1"

echo  - クリーンアップ開始: !TARGET_DIR!

pushd "!TARGET_DIR!" >nul 2>&1
if !errorlevel! equ 0 (
    del /q /s /f *.* >nul 2>&1
    for /d %%f in (*) do rmdir /s /q "%%f" >nul 2>&1
    popd >nul 2>&1
    echo  - クリーンアップ完了: !TARGET_DIR!
) else (
    echo  - エラー: !TARGET_DIR! にアクセスできません
)

endlocal
goto :eof
