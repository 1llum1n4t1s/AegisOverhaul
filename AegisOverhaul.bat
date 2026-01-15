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
rem エクスプローラー停止（操作ガード対策）
rem ===================================================
echo [エクスプローラー停止] エクスプローラーのプロセスを停止しています...
taskkill /f /im explorer.exe >nul 2>&1
timeout /t 1 /nobreak >nul

rem ===================================================
rem アプリケーション更新セクション
rem ===================================================
echo [アプリケーション更新] wingetによるアプリケーションの更新を開始...
winget upgrade --all --include-unknown --silent --disable-interactivity --accept-source-agreements --accept-package-agreements
echo  - wingetによるアプリケーションの更新が完了しました

echo [アプリケーション更新] Microsoft Store アプリのリセットを開始...
powershell -Command "Get-AppxPackage | ForEach-Object { Add-AppxPackage -DisableDevelopmentMode -Register \"$($_.InstallLocation)\AppXManifest.xml\" -ErrorAction SilentlyContinue }"
echo  - すべてのストアアプリのリセットを完了しました

rem ===================================================
rem サービス管理セクション
rem ===================================================
echo [サービス管理] 不要なサービスを停止しています...
for %%S in (bits wuauserv appidsvc usosvc FontCache SysMain wsearch) do (
    net stop "%%S" 2>nul
    echo  - %%S サービスを停止しました
)

rem ===================================================
rem ファイルクリーンアップセクション
rem ===================================================
echo [ファイルクリーンアップ] システム関連の一時ファイルを削除しています...

rem Discord関連のキャッシュファイル
call :CleanDirectory "%APPDATA%\discord\Cache"
call :CleanDirectory "%APPDATA%\discord\Code Cache"
call :CleanDirectory "%APPDATA%\discord\GPUCache"
call :CleanDirectory "%APPDATA%\discord\VideoDecodeStats"

rem Microsoft関連のキャッシュファイル
call :CleanDirectory "%APPDATA%\Microsoft\Office\Recent"
call :CleanDirectory "%LOCALAPPDATA%\Microsoft\FontCache"
call :CleanDirectory "%LOCALAPPDATA%\Microsoft\IME\15.0\IMEJP\Cache"
call :CleanDirectory "%LOCALAPPDATA%\Microsoft\Internet Explorer"
call :CleanDirectory "%LOCALAPPDATA%\Microsoft\Office\16.0\Wef"
call :CleanDirectory "%LOCALAPPDATA%\Microsoft\Office\SolutionPackages"
call :CleanDirectory "%LOCALAPPDATA%\Microsoft\Outlook\HubAppFileCache"
call :CleanDirectory "%LOCALAPPDATA%\Microsoft\Windows\AppCache"
call :CleanDirectory "%LOCALAPPDATA%\Microsoft\Windows\Explorer"
call :CleanDirectory "%LOCALAPPDATA%\Microsoft\Windows\IdentityCache"
call :CleanDirectory "%LOCALAPPDATA%\Microsoft\Windows\INetCache"
call :CleanDirectory "%LOCALAPPDATA%\Microsoft\Windows\OneAuth"
call :CleanDirectory "%LOCALAPPDATA%\Microsoft\Windows\Temporary Internet Files"
call :CleanDirectory "%LOCALAPPDATA%\Microsoft\Windows\WebCache"

rem システム関連のキャッシュファイル
call :CleanDirectory "%LOCALAPPDATA%\CrashDumps"
call :CleanDirectory "%LOCALAPPDATA%\D3DSCache"
call :CleanDirectory "%LOCALAPPDATA%\NuGet"
call :CleanDirectory "%LOCALAPPDATA%\NVIDIA\DXCache"
call :CleanDirectory "%LOCALAPPDATA%\Temp"
call :CleanDirectory "%LOCALAPPDATA%\UnrealEngine"

rem ProgramData関連のキャッシュファイル
call :CleanDirectory "%ProgramData%\LGHUB\cache"
call :CleanDirectory "%ProgramData%\Microsoft\EdgeUpdate\Log"
call :CleanDirectory "%ProgramData%\Microsoft\Network\Downloader"
call :CleanDirectory "%ProgramData%\Microsoft\Search\Data\Applications\Windows"
call :CleanDirectory "%ProgramData%\Microsoft\Windows Defender\Definition Updates\Backup"
call :CleanDirectory "%ProgramData%\Microsoft\Windows Defender\Scans\History\Results\Resource"
call :CleanDirectory "%ProgramData%\Microsoft\Windows Defender\Support"
call :CleanDirectory "%ProgramData%\USOShared\Logs"

rem Windowsシステム関連のキャッシュファイル
call :CleanDirectory "%SystemRoot%\Logs"
call :CleanDirectory "%SystemRoot%\ServiceProfiles\LocalService\AppData\Local\FontCache"
call :CleanDirectory "%SystemRoot%\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Cache"
call :CleanDirectory "%SystemRoot%\System32\catroot2"
call :CleanDirectory "%SystemRoot%\System32\LogFiles"
call :CleanDirectory "%SystemRoot%\SystemTemp"
call :CleanDirectory "%SystemRoot%\Temp"

rem ユーザー関連のキャッシュファイル
call :CleanDirectory "%USERPROFILE%\AppData\LocalLow\Intel"
call :CleanDirectory "%USERPROFILE%\AppData\LocalLow\Microsoft\CryptnetUrlCache"
call :CleanDirectory "%USERPROFILE%\Recent"
call :CleanDirectory "%USERPROFILE%\AppData\Local\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams"

rem 不要なディレクトリの削除
echo [ファイルクリーンアップ] 不要なディレクトリを削除しています...
rmdir /s /q "%SystemRoot%\SoftwareDistribution" 2>nul
rmdir /s /q "%SystemRoot%\Prefetch" 2>nul
rmdir /s /q "%USERPROFILE%\.aws" 2>nul
rmdir /s /q "%USERPROFILE%\.config" 2>nul
rmdir /s /q "%USERPROFILE%\.dbus-keyrings" 2>nul
rmdir /s /q "%USERPROFILE%\.dotnet" 2>nul
rmdir /s /q "%USERPROFILE%\.monica-code" 2>nul
rmdir /s /q "%USERPROFILE%\.nuget" 2>nul
rmdir /s /q "%USERPROFILE%\.omnisharp" 2>nul
rmdir /s /q "%USERPROFILE%\.templateengine" 2>nul
rmdir /s /q "%USERPROFILE%\AppData\LocalLow\NVIDIA\PerDriverVersion\DXCache" 2>nul
rmdir /s /q "%USERPROFILE%\Bootstrap Studio Backups" 2>nul
rmdir /s /q "%USERPROFILE%\intellij-chatgpt" 2>nul
rmdir /s /q "C:\$SysReset" 2>nul
rmdir /s /q "C:\AMD" 2>nul
rmdir /s /q "C:\Intel" 2>nul
rmdir /s /q "C:\log" 2>nul
rmdir /s /q "C:\OneDriveTemp" 2>nul
rmdir /s /q "C:\PerfLogs" 2>nul
rmdir /s /q "C:\SWSetup" 2>nul
rmdir /s /q "C:\Windows.old" 2>nul

rem 特定のファイル削除
echo [ファイルクリーンアップ] キャッシュファイルを削除しています...
del /q /f "%LOCALAPPDATA%\Microsoft\Outlook\*.nst" 2>nul
del /q /f "%LOCALAPPDATA%\Microsoft\Outlook\*.ost" 2>nul
del /q /f "%LOCALAPPDATA%\IconCache.db" 2>nul
del /q /f "%LOCALAPPDATA%\Microsoft\Windows\Explorer\iconcache_*.db" 2>nul
del /q /f "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*.db" 2>nul

rem echo [ファイルクリーンアップ] 不要なIDE・開発環境フォルダを削除しています...
rem set "FOLDERS_TO_DELETE=.idea"
rem for %%f in (%FOLDERS_TO_DELETE%) do (
rem     echo   - %%f フォルダを検索中...
rem     for /f "delims=" %%i in ('dir /s /b /ad "C:\%%f" 2^>nul') do (
rem         rmdir /s /q "%%i" 2>nul
rem         echo     - %%i を削除しました
rem     )
rem )

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
echo [Windows Defender] 定義ファイル更新とスキャン除外設定の初期化を実行しています...
rem Windows Defender の定義ファイル更新を実行
"%ProgramFiles%\Windows Defender\MpCmdRun.exe" -removedefinitions -dynamicsignatures >nul 2>&1
"%ProgramFiles%\Windows Defender\MpCmdRun.exe" -SignatureUpdate >nul 2>&1
echo  - Windows Defender の定義ファイルを更新しました

rem ===================================================
rem システム最適化セクション
rem ===================================================
echo [システム最適化] 各種システム設定を最適化しています...

rem ダウンロードフォルダなどが英語になっているのを修復する
regsvr32 shell32.dll /i:U /s
echo  - フォルダ名を修復しました

rem ネットワークドライブアクセスの最適化
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "DirectoryCacheLifetime" /t REG_DWORD /d 0 /f >nul 2>&1

rem QoS予約帯域幅を0に設定（エクスプローラーの表示速度向上）
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /t REG_DWORD /d 0 /f >nul 2>&1

rem スタートアップフォルダのアプリの起動速度を向上
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v "WaitForIdleState" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v "StartupDelayInMSec" /t REG_DWORD /d 0 /f
echo  - スタートアップフォルダのアプリの起動速度を向上しました

rem ===================================================
rem MMAgent設定（SysMainが必要）
rem ===================================================
echo [システム最適化] MMAgentを設定しています...
rem SysMainサービスが稼働していることを確認
sc query SysMain | find "RUNNING" >nul
if %errorlevel% neq 0 (
    echo  - SysMainサービスを開始しています...
    net start SysMain 2>nul
    timeout /t 3 /nobreak >nul
)
powershell -NoProfile -Command "try { Enable-MMAgent -MemoryCompression } catch {}"
powershell -NoProfile -Command "try { Enable-MMAgent -PageCombining } catch {}"
powershell -NoProfile -Command "try { Set-MMAgent -MaxOperationAPIFiles 64 } catch {}"
powershell -NoProfile -Command "try { Enable-MMAgent -ApplicationLaunchPrefetching } catch {}"
powershell -NoProfile -Command "try { Enable-MMAgent -OperationAPI } catch {}"
powershell -NoProfile -Command "try { Disable-MMAgent -ApplicationPreLaunch } catch {}"
echo  - MMAgentの設定を完了しました

rem Superfetch設定は現在はSysMainによって管理されているため設定を削除
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /f >nul 2>&1
echo  - Superfetch および Prefetcher の設定を削除しました

rem === oldで設定されたストレージ最適化をWindows標準にリセット ===
echo [システム最適化] ストレージ関連の過度な最適化をリセットしています...

rem SSD TRIM関連設定をリセット
powershell -Command "fsutil behavior set disabledeletenotify 1" >nul 2>&1
echo  - SSD TRIM関連設定をリセットしました

rem ストレージ設定をリセット
powershell -Command "try { Set-StorageSetting -NewDiskPolicy Default -ErrorAction SilentlyContinue } catch {}" >nul 2>&1
echo  - ストレージ設定をWindows標準にリセットしました

rem NTFSメモリ使用量設定をリセット
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v NtfsMemoryUsage /f >nul 2>&1
echo  - NTFSメモリ使用量をWindows標準にリセットしました

rem MPO（マルチプレーンオーバーレイ）を無効化（表示のちらつき対策・安定性向上）
reg add "HKLM\SOFTWARE\Microsoft\Windows\Dwm" /v OverlayTestMode /t REG_DWORD /d 5 /f
echo  - MPO（マルチプレーンオーバーレイ）を無効化しました

rem リモートデスクトップのFPSを60FPSに設定
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations" /v DWMFRAMEINTERVAL /t REG_DWORD /d 15 /f
echo  - リモートデスクトップのFPSを60FPSに設定しました

rem === oldで設定された過度な最適化設定をWindows標準にリセット ===
echo [システム最適化] 過度な最適化設定をWindows標準にリセットしています...

rem シェルバッグ設定をリセット
reg delete "HKCU\Software\Microsoft\Windows\Shell\BagMRU" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\Shell\Bags" /f >nul 2>&1

rem Explorerフォルダーオプション設定をリセット
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "LaunchTo" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Hidden" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSyncProviderNotifications" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAnimations" /f >nul 2>&1

rem ビジュアルエフェクト設定をリセット
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /f >nul 2>&1

rem エクスプローラー表示速度設定をリセット
reg delete "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /f >nul 2>&1
reg delete "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /f >nul 2>&1

rem メモリ関連のレジストリ設定をリセット
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v SessionViewSize /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v DisablePagingExecutive /f >nul 2>&1

rem デスクトップヒープサイズ設定をリセット
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\SubSystems" /v SharedSection /f >nul 2>&1

rem Segment Heap設定をリセット
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Segment Heap" /f >nul 2>&1

rem バックグラウンドアプリ実行設定をリセット
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /f >nul 2>&1

rem Fast Startup設定をリセット
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /f >nul 2>&1

rem Windows 11 Copilot関連設定をリセット
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SystemPaneSuggestionsEnabled /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SoftLandingEnabled /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338388Enabled /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarDa" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarMn" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowCopilotButton" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /f >nul 2>&1
reg delete "HKCU\Software\Policies\Microsoft\Windows\WindowsCopilot" /v "TurnOffWindowsCopilot" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Policies\Microsoft\Dsh" /v "AllowNewsAndInterests" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v "AllowNewsAndInterests" /f >nul 2>&1
reg delete "HKLM\Software\Policies\Microsoft\Windows\WindowsCopilot" /v "TurnOffWindowsCopilot" /f >nul 2>&1

rem プリフェッチファイル数設定をリセット
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v MaxPrefetchFiles /f >nul 2>&1

rem SystemCacheLimit設定をリセット
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v SystemCacheLimit /f >nul 2>&1

rem PoolUsageMaximum設定をリセット
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v PoolUsageMaximum /f >nul 2>&1

rem Direct Storage設定をリセット
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /f >nul 2>&1

rem NVMe最適化をリセット
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\stornvme\Parameters\Device" /v "ForcedPhysicalSectorSizeInBytes" /f >nul 2>&1

rem GPU設定をリセット
reg delete "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /f >nul 2>&1

rem ゲーム優先度設定をリセット
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /f >nul 2>&1

rem Game Mode詳細設定をリセット
reg delete "HKCU\Software\Microsoft\GameBar" /v "UseNexusForGameBarEnabled" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Clock Rate" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /f >nul 2>&1

rem Xbox Game Bar設定をリセット
reg delete "HKCU\System\GameConfigStore" /v GameDVR_Enabled /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\GameBar" /v ShowStartupPanel /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\GameBar" /v Enabled /f >nul 2>&1

rem 電力スロットリング設定をリセット
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v PowerThrottlingOff /f >nul 2>&1

rem タイマー解像度設定をリセット
bcdedit /set useplatformtick no >nul 2>&1
bcdedit /deletevalue disabledynamictick >nul 2>&1
bcdedit /deletevalue tscsyncpolicy >nul 2>&1

rem 電源プランを初期化
powercfg /restoredefaultschemes >nul 2>&1
powercfg /setactive SCHEME_BALANCED >nul 2>&1
echo  - 電源プランをWindows標準にリセットしました

echo  - 過度な最適化設定をWindows標準にリセットしました

rem 休止状態をオフにする
powercfg /hibernate off
echo  - 休止状態を無効化しました

rem 接続しているすべてのSSDへTRIMコマンドを発行する
defrag /C /L /B
echo  - SSD TRIM コマンドを実行しました

rem 時刻同期の設定と実行
net stop w32time 2>nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" /v "NtpServer" /t REG_SZ /d "ntp.jst.mfeed.ad.jp" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" /v "Type" /t REG_SZ /d "NTP" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v "AnnounceFlags" /t REG_DWORD /d 5 /f
net start w32time 2>nul

rem ===================================================
rem ネットワーク最適化セクション
rem ===================================================
echo [ネットワーク最適化] ネットワーク設定をリセットしています...

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
netsh int tcp set supplemental template=Internet congestionprovider=BBR2
netsh int tcp set supplemental template=InternetCustom congestionprovider=BBR2
netsh int tcp set supplemental template=Datacenter congestionprovider=BBR2
netsh int tcp set supplemental template=DatacenterCustom congestionprovider=BBR2
netsh int tcp set supplemental template=Compat congestionprovider=BBR2
netsh int ipv6 set global loopbacklargemtu=disable
netsh int ipv4 set global loopbacklargemtu=disable
echo  - TCP設定を最適化しました

rem ネットワークアダプターのLSO最適化
powershell -Command "Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | ForEach-Object { try { Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName 'Large Send Offload (IPv4)' -DisplayValue 'Disabled' -ErrorAction SilentlyContinue; Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName 'Large Send Offload (IPv6)' -DisplayValue 'Disabled' -ErrorAction SilentlyContinue; Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName 'Large Send Offload Version 2 (IPv4)' -DisplayValue 'Enabled' -ErrorAction SilentlyContinue; Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName 'Large Send Offload Version 2 (IPv6)' -DisplayValue 'Enabled' -ErrorAction SilentlyContinue } catch {} }"
echo  - ネットワークアダプターのLSO v2を有効化しました

rem ネットワークアダプターの電源管理無効化
powershell -Command "Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | ForEach-Object { try { Disable-NetAdapterPowerManagement -Name $_.Name -ErrorAction SilentlyContinue; Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName 'Energy Efficient Ethernet' -DisplayValue 'Disabled' -ErrorAction SilentlyContinue; Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName 'Green Ethernet' -DisplayValue 'Disabled' -ErrorAction SilentlyContinue; Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName 'Power Saving Mode' -DisplayValue 'Disabled' -ErrorAction SilentlyContinue } catch {} }"
echo  - ネットワークアダプターの電源管理を無効化しました

rem === oldで設定された過度なネットワーク設定をWindows標準にリセット ===
echo [ネットワーク最適化] 過度なネットワーク設定をWindows標準にリセットしています...

rem AFD未公開パラメータをリセット
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v DefaultReceiveWindow /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v DefaultSendWindow /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v MaxFastDgramRecv /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v MaxFastReceive /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v MaxFastTransmit /f >nul 2>&1

rem TCP詳細設定をリセット
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnableDeadGWDetect /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnableICMPRedirect /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnablePMTUBHDetect /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnableTCPChimney /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnableWsd /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpCongestionControl /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v GlobalMaxTcpWindowSize /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpWindowSize /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpInitialRtt /f >nul 2>&1

rem Dns設定をリセット
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v MaxCacheTtl /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v MaxNegativeCacheTtl /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v MaxSOACacheTtl /f >nul 2>&1

rem HTTP設定をリセット
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\HTTP\Parameters" /v EnableNonUTF8 /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\HTTP\Parameters" /v EnableUrlRewrite /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\HTTP\Parameters" /v MaxConnections /f >nul 2>&1

rem LanmanServer設定をリセット
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v SizReqBuf /f >nul 2>&1

rem IPv6設定をリセット
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" /v DisableIPAutoConfigurationLimits /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" /v MaxUserPort /f >nul 2>&1

echo  - 過度なネットワーク設定をWindows標準にリセットしました

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
