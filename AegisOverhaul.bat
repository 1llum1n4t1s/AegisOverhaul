@echo off
setlocal EnableDelayedExpansion

rem コードページをUTF-8に設定
chcp 65001 >nul

rem ===================================================
rem PCメンテナンスおよびネットワーク最適化用バッチスクリプト
rem 作成日: 2024年
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
for %%S in (bits wuauserv appidsvc usosvc FontCache SysMain) do (
    net stop "%%S" 2>nul
    echo  - %%S サービスを停止しました
)

rem Windows Search インデックス作成を無効化（メモリ節約）
sc config wsearch start=disabled
net stop wsearch 2>nul
echo  - Windows Search インデックス作成を無効化しました

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
echo [Windows Defender] 定義ファイルキャッシュを削除しています...
"%ProgramFiles%\Windows Defender\MpCmdRun.exe" -removedefinitions -dynamicsignatures
"%ProgramFiles%\Windows Defender\MpCmdRun.exe" -SignatureUpdate
echo  - Windows Defender の定義ファイルを更新しました

rem ===================================================
rem システム最適化セクション
rem ===================================================
echo [システム最適化] 各種システム設定を最適化しています...

rem Internet Explorerのキャッシュをクリアする
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 255
echo  - Internet Explorer のキャッシュをクリアしました

rem ダウンロードフォルダなどが英語になっているのを修復する
regsvr32 shell32.dll /i:U /s
echo  - フォルダ名を修復しました

rem シェルバッグの最適化（エクスプローラーの表示履歴をクリア）
reg delete "HKCU\Software\Microsoft\Windows\Shell\BagMRU" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\Shell\Bags" /f >nul 2>&1

rem Explorerフォルダーオプション最適化（設定を削除してデフォルトに戻す）
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "LaunchTo" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Hidden" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSyncProviderNotifications" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAnimations" /f >nul 2>&1

rem ビジュアルエフェクト設定をデザイン優先に設定
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 1 /f

rem エクスプローラーの表示速度設定を削除（デフォルトに戻す）
reg delete "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /f >nul 2>&1

rem エクスプローラーのメニュー表示速度設定を削除（デフォルトに戻す）
reg delete "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /f >nul 2>&1

rem ネットワークドライブアクセスの最適化
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "DirectoryCacheLifetime" /t REG_DWORD /d 0 /f >nul 2>&1

rem QoS予約帯域幅を0に設定（エクスプローラーの表示速度向上）
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /t REG_DWORD /d 0 /f >nul 2>&1

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
powershell -Command "Enable-MMAgent -MemoryCompression"
powershell -Command "Enable-MMAgent -PageCombining"
powershell -Command "Set-MMAgent -MaxOperationAPIFiles 64"
powershell -Command "Enable-MMAgent -ApplicationLaunchPrefetching"
powershell -Command "Enable-MMAgent -OperationAPI"
powershell -Command "Disable-MMAgent -ApplicationPreLaunch"
echo  - MMAgentの設定を完了しました

rem Superfetch設定は現在はSysMainによって管理されているため設定を削除
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /f >nul 2>&1
echo  - Superfetch および Prefetcher の設定を削除しました

rem ストレージ応答性の向上設定
powershell -Command "fsutil behavior set disabledeletenotify 0"
echo - SSDのTRIM機能を有効化しました

rem NVMe最適化設定
powershell -Command "Set-StorageSetting -NewDiskPolicy OnlineAll"
echo - ストレージ設定をパフォーマンス優先に設定しました

rem メモリ関連のレジストリ設定
echo [システム最適化] メモリ管理設定の最適化
rem 大きなシステムキャッシュを初期値に設定
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache /t REG_DWORD /d 0 /f
echo  - システムキャッシュを初期値に設定

rem セッションビューのサイズ設定を除去（過去の設定をクリア）
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v SessionViewSize /f >nul 2>&1
echo  - セッションビューのサイズ設定を除去しました

rem カーネルをメモリに常駐させない
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v DisablePagingExecutive /t REG_DWORD /d 0 /f
echo  - カーネルをメモリに常駐させない設定を完了しました

rem デスクトップヒープサイズのGPUアクセラレーション対応設定
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\SubSystems" /v SharedSection /f
powershell -NoProfile -Command ^
  "$p='HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\SubSystems';" ^
  "$s=(Get-ItemProperty -Path $p -Name Windows).Windows;" ^
  "$s=$s -replace 'SharedSection=\d+,\d+,\d+','SharedSection=2048,20480,5120';" ^
  "Set-ItemProperty -Path $p -Name Windows -Type ExpandString -Value $s"
echo  - デスクトップヒープサイズをGPUアクセラレーション対応に設定しました

rem Segment Heap設定を削除（ゲーム起動問題対策）
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Segment Heap" /f >nul 2>&1
echo  - Segment Heap設定を削除しました（ゲーム起動問題対策）

rem バックグラウンドアプリの実行設定を削除
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /f >nul 2>&1
echo  - バックグラウンドアプリの実行設定を削除しました

rem Fast Startupを無効化
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d 0 /f
echo  - Fast Startupを無効化しました

rem Windows 11 のウィジット・Copilot機能を無効化
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SystemPaneSuggestionsEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SoftLandingEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338388Enabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarDa" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarMn" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowCopilotButton" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Policies\Microsoft\Windows\WindowsCopilot" /v "TurnOffWindowsCopilot" /t REG_DWORD /d 1 /f
reg add "HKCU\SOFTWARE\Policies\Microsoft\Dsh" /v "AllowNewsAndInterests" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v "AllowNewsAndInterests" /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsCopilot" /v "TurnOffWindowsCopilot" /t REG_DWORD /d 1 /f
echo  - Windows 11 機能を無効化

rem プリフェッチファイル数の手動設定を削除（Windows自動制御に戻す）
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v MaxPrefetchFiles /f >nul 2>&1
echo  - プリフェッチファイル数の手動設定を削除しました（Windows自動制御に戻しました）

rem SystemCacheLimit設定を削除（既存の設定を元に戻す）
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v SystemCacheLimit /f >nul 2>&1
echo  - SystemCacheLimit設定を削除しました（Windowsデフォルトに戻しました）

rem NtfsMemoryUsage設定を削除（Windowsデフォルトに戻す）
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v NtfsMemoryUsage /f >nul 2>&1
echo  - NtfsMemoryUsage設定を削除しました（Windowsデフォルトに戻しました）

rem PoolUsageMaximum設定を削除（Windowsの自動管理に戻す）
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v PoolUsageMaximum /f >nul 2>&1
echo  - PoolUsageMaximum設定を削除しました（Windowsデフォルトに戻しました）

rem Direct Storage 最適化
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 2 /f
echo - ハードウェアスケジューリングを有効化しました

rem MPO（マルチプレーンオーバーレイ）を無効化（表示のちらつき対策・安定性向上）
reg add "HKLM\SOFTWARE\Microsoft\Windows\Dwm" /v OverlayTestMode /t REG_DWORD /d 5 /f
echo  - MPO（マルチプレーンオーバーレイ）を無効化しました

rem NVMe SSDのキューの深度最適化
reg add "HKLM\SYSTEM\CurrentControlSet\Services\stornvme\Parameters\Device" /v "ForcedPhysicalSectorSizeInBytes" /t REG_DWORD /d 4096 /f

rem GPU優先度をパフォーマンスモードに設定
powershell -Command "if (Get-Command 'Set-ProcessMitigation' -ErrorAction SilentlyContinue) { Set-ProcessMitigation -System -Disable CFG }"
reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d 1 /f
echo - GPUパフォーマンス設定とゲームモードを最適化しました

rem ゲーム優先度設定
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f
echo - ゲームプロセスの優先度を最高レベルに設定しました

rem Windows Game Mode の詳細設定
reg add "HKCU\Software\Microsoft\GameBar" /v "UseNexusForGameBarEnabled" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Clock Rate" /t REG_DWORD /d 10000 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d "High" /f

rem ============================
rem ゲーム用途の追加最適化
rem ============================
rem Xbox Game Bar の録画系機能を無効化（オーバーヘッド低減）
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\GameBar" /v ShowStartupPanel /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\GameBar" /v Enabled /t REG_DWORD /d 0 /f
echo - Xbox Game Bar の録画機能を無効化しました（パフォーマンス優先）

rem 電源プランを究極のパフォーマンスに設定（存在しなければ複製してから適用）
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1
powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61 2>nul || powercfg -setactive SCHEME_MAX
echo - 電源プランを究極のパフォーマンス（なければ高パフォーマンス）に設定しました

rem システムの電力スロットリングを無効化（EcoQoSの抑制）
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v PowerThrottlingOff /t REG_DWORD /d 1 /f
echo - システムの電力スロットリングを無効化しました


rem タイマー解像度の最適化（ゲームのフレームレート向上）
bcdedit /set useplatformtick yes
bcdedit /set disabledynamictick yes
bcdedit /set tscsyncpolicy enhanced
echo - タイマー解像度を最適化しました

rem 休止状態をオフにする
powercfg /hibernate off
echo  - 休止状態を無効化しました

rem 接続しているすべてのSSDへTRIMコマンドを発行する
defrag /C /L /B
echo  - SSD TRIM コマンドを実行しました

rem 時刻同期の設定と実行（w32tmコマンドを使わない方法）
echo [System Optimization] Setting time synchronization...
net stop w32time 2>nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" /v "NtpServer" /t REG_SZ /d "ntp1.v6.mfeed.ad.jp,0x8 ntp2.v6.mfeed.ad.jp,0x8 ntp3.v6.mfeed.ad.jp,0x8" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" /v "Type" /t REG_SZ /d "NTP" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v "AnnounceFlags" /t REG_DWORD /d 5 /f
net start w32time 2>nul
powershell -Command "try { Start-Service w32time -ErrorAction SilentlyContinue; Start-Sleep 2; Restart-Service w32time -ErrorAction SilentlyContinue; Write-Host '時刻同期完了' } catch { Write-Host '時刻同期に失敗' }"
echo  - Time synchronization completed (using Japanese NTP servers, no w32tm commands)

rem ===================================================
rem ネットワーク最適化セクション
rem ===================================================
echo [ネットワーク最適化] ネットワーク設定をリセットしています...

rem DNSキャッシュとHTTPログのクリア
ipconfig /flushdns
netsh http flush logbuffer
netsh http delete cache
nbtstat -R
nbtstat -RR

rem プロキシ設定のリセット
netsh winhttp reset proxy
netsh winhttp reset autoproxy

rem ファイアウォールのリセット（現在はコメントアウト）
netsh advfirewall reset

rem ルーティング関連のリセット
route /f

rem IPアドレス操作
ipconfig /registerdns
ipconfig /release
ipconfig /renew

rem 重要なTCP/IP設定リセット
netsh int tcp reset
netsh int tcp set global default
netsh winsock reset
netsh int ip reset

rem DNS設定（Google Public DNS）を全有効アダプターへ一括適用
echo [ネットワーク最適化] 全有効アダプターのDNSをGoogle Public DNSに設定しています...
rem ネットワークリセット直後の安定化待ち
timeout /t 8 /nobreak >nul
rem 必要であればアダプターのIPv6バインドを有効化（無効だとDNS設定に失敗する）
powershell -NoProfile -Command "Get-NetAdapter | Where-Object { $_.Status -in 'Up','Disconnected' -and $_.HardwareInterface -eq $true } | ForEach-Object { try { Enable-NetAdapterBinding -Name $_.Name -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue } catch {} }"
rem システム全体でIPv6が無効化されている場合に備えフラグを初期化（完全反映は再起動後）
powershell -NoProfile -Command "$dc = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters' -Name DisabledComponents -ErrorAction SilentlyContinue).DisabledComponents; if ($dc -ne $null -and $dc -ne 0) { Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters' -Name DisabledComponents -Type DWord -Value 0 -ErrorAction SilentlyContinue; Write-Host '  - IPv6を有効化しました（DisabledComponents=0、再起動後に完全反映）' }"
rem IPv6リース更新（DHCPv6/SLAACの反映を促す。失敗しても続行）
ipconfig /renew6
rem PowerShellワンライナーで全DNSクライアントIFへ適用。失敗時はnetshでフォールバック（インターフェース名はクォート）
powershell -NoProfile -Command "$nics = Get-NetAdapter | Where-Object { $_.Status -in 'Up','Disconnected' -and $_.HardwareInterface -eq $true }; foreach($n in $nics){ $alias=$n.Name; try { Set-DnsClientServerAddress -InterfaceAlias $alias -AddressFamily IPv4 -ServerAddresses 8.8.8.8,8.8.4.4 -ErrorAction Stop } catch { & netsh interface ipv4 set dnsservers name=\"$alias\" static 8.8.8.8 primary > $null 2>&1; & netsh interface ipv4 add dnsserver name=\"$alias\" address=8.8.4.4 index=2 > $null 2>&1 }; try { Set-DnsClientServerAddress -InterfaceAlias $alias -AddressFamily IPv6 -ServerAddresses 2001:4860:4860::8888,2001:4860:4860::8844 -ErrorAction Stop } catch { & netsh interface ipv6 set dnsservers interface=\"$alias\" static 2001:4860:4860::8888 primary validate=no > $null 2>&1; & netsh interface ipv6 add dnsserver interface=\"$alias\" address=2001:4860:4860::8844 index=2 validate=no > $null 2>&1 } }"
rem 適用状況の表示
powershell -NoProfile -Command "Get-DnsClientServerAddress | Where-Object { $_.ServerAddresses } | Format-Table InterfaceAlias,AddressFamily,ServerAddresses -AutoSize"
rem DNSキャッシュをクリア（新設定を即時反映）
ipconfig /flushdns
echo  - DNSキャッシュをクリアしました
echo  - DNSサーバー設定を適用しました（IPv4: 8.8.8.8/8.8.4.4, IPv6: 2001:4860:4860::8888/2001:4860:4860::8844）

echo [ネットワーク最適化] TCP設定を最適化しています...
netsh int tcp set global rsc=enabled
rem rackパラメータは現在のWindowsバージョンではサポートされていないためコメントアウト
rem netsh int tcp set global rack=enabled
netsh int tcp set global ecncapability=enabled
netsh int tcp set global timestamps=disabled
rem RSSを有効化（マルチコア性能を活用）
netsh int tcp set global rss=enabled
echo  - Receive Side Scalingを有効化しました（マルチコア性能を活用）
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

echo [ネットワーク最適化] ネットワークのレジストリ設定を最適化しています...
rem TcpAckFrequency等の設定（各ネットワークインターフェースに対して）
for /f "tokens=*" %%i in ('reg query HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces') do (
    reg query %%i | find "DhcpIPAddress" > nul
    if !errorlevel!==0 (
        reg add %%i /v TcpAckFrequency /t REG_DWORD /d 1 /f
        reg add %%i /v TCPNoDelay /t REG_DWORD /d 1 /f
        reg add %%i /v TcpDelAckTicks /t REG_DWORD /d 0 /f
        echo  - インターフェース %%i のTCPパラメータを最適化しました
    )
)

rem ネットワークアダプターのLSO最適化
powershell -Command "Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | ForEach-Object { try { Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName 'Large Send Offload (IPv4)' -DisplayValue 'Disabled' -ErrorAction SilentlyContinue; Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName 'Large Send Offload (IPv6)' -DisplayValue 'Disabled' -ErrorAction SilentlyContinue; Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName 'Large Send Offload Version 2 (IPv4)' -DisplayValue 'Enabled' -ErrorAction SilentlyContinue; Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName 'Large Send Offload Version 2 (IPv6)' -DisplayValue 'Enabled' -ErrorAction SilentlyContinue } catch {} }"
echo  - ネットワークアダプターのLSO v2を有効化しました

rem ネットワークアダプターの電源管理無効化
powershell -Command "Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | ForEach-Object { try { Disable-NetAdapterPowerManagement -Name $_.Name -ErrorAction SilentlyContinue; Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName 'Energy Efficient Ethernet' -DisplayValue 'Disabled' -ErrorAction SilentlyContinue; Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName 'Green Ethernet' -DisplayValue 'Disabled' -ErrorAction SilentlyContinue; Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName 'Power Saving Mode' -DisplayValue 'Disabled' -ErrorAction SilentlyContinue } catch {} }"
echo  - ネットワークアダプターの電源管理を無効化しました

rem TCP/IP設定の最適化
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 0xffffffff /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\DisplayPostProcessing" /v "NetworkThrottlingIndex" /t REG_DWORD /d 0xffffffff /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "NetworkThrottlingIndex" /t REG_DWORD /d 0xffffffff /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "MaxOutstandingSends" /t REG_DWORD /d 2 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "TimerResolution" /t REG_DWORD /d 1 /f
rem 過去に設定した AFD 未公開パラメータを削除（現行 Windows では不要）
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v DefaultReceiveWindow /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v DefaultSendWindow /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v MaxFastDgramRecv /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v MaxFastReceive /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v MaxFastTransmit /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v MaxCacheTtl /t REG_DWORD /d 1800 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v MaxNegativeCacheTtl /t REG_DWORD /d 300 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v MaxSOACacheTtl /t REG_DWORD /d 300 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\HTTP\Parameters" /v EnableNonUTF8 /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\HTTP\Parameters" /v EnableUrlRewrite /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\HTTP\Parameters" /v MaxConnections /t REG_DWORD /d 100000 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v SizReqBuf /t REG_DWORD /d 16384 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v DefaultTTL /t REG_DWORD /d 64 /f
rem 危険なネットワーク設定を削除（オンラインゲーム安定性対策）
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnableDeadGWDetect /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnableICMPRedirect /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnablePMTUBHDetect /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnablePMTUDiscovery /t REG_DWORD /d 1 /f
rem 過去に設定した Chimney/WSD を削除（現行 Windows では無効）
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnableTCPChimney /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnableWsd /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v MaxUserPort /t REG_DWORD /d 65534 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v Tcp1323Opts /t REG_DWORD /d 1 /f
rem 過去に設定した TcpCongestionControl レジストリ値を削除（netsh で適用済み）
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpCongestionControl /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpEcnCapability /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpFastOpen /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpFastOpenFallback /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpInitialCWnd /t REG_DWORD /d 16 /f
rem RTTはデフォルト値（3000ms）のほうが安定
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpInitialRtt /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpMaxDupAcks /t REG_DWORD /d 2 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpNoDelay /t REG_DWORD /d 1 /f
rem TimedWaitDelayは120秒が推奨
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpTimedWaitDelay /t REG_DWORD /d 120 /f


rem システム全体の最大値をWindows自動制御に戻す
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v GlobalMaxTcpWindowSize /f >nul 2>&1
echo  - GlobalMaxTcpWindowSizeの手動設定を削除しました（Windows自動制御に戻しました）

rem TCP自動チューニングを有効化（手動設定を削除）
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpWindowSize /f >nul 2>&1
echo  - TcpWindowSizeの手動設定を削除しました（Windows自動チューニングに戻しました）

reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" /v DisableIPAutoConfigurationLimits /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" /v MaxUserPort /t REG_DWORD /d 65534 /f
echo  - TCP/IP設定の最適化を完了しました

rem WiFiの自動切断を防ぐ設定
echo [ネットワーク最適化] WiFiの自動切断を無効化しています...
rem 危険なネットワーク設定を削除（オンラインゲーム安定性対策）
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnableDeadGWDetect /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnableICMPRedirect /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnablePMTUBHDetect /f >nul 2>&1

rem WiFiの自動切断タイマーを無効化
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WlanSvc\Parameters" /v "EnableAutoDisconnect" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WlanSvc\Parameters" /v "AutoDisconnectTimeout" /t REG_DWORD /d 0 /f
echo  - WiFiの自動切断タイマーを無効化しました

rem ネットワーク接続の永続性を確保（過去の WSD 設定を削除）
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "EnableWsd" /f >nul 2>&1
rem ICMPリダイレクト設定を削除（オンラインゲーム安定性対策）
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "EnableICMPRedirect" /f >nul 2>&1
echo  - ネットワーク接続の永続性を確保しました

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
