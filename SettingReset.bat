@echo off
setlocal EnableDelayedExpansion

rem コードページをUTF-8に設定
chcp 65001 >nul

rem ===================================================
rem TheMaintenance.bat の設定変更を可能な範囲で既定へ戻す
rem 注意:
rem  - キャッシュ削除/ログ削除/フォルダ削除のような「削除」系は元に戻せません
rem  - 「元の値」を保存していないため、基本は「値を削除してWindows既定に委ねる」方針です
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
rem レジストリ削除（統合版）
rem ===================================================
echo [設定リセット] レジストリ削除を実行しています...

rem タスクトレイ通知アイコン
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\TrayNotify" /v IconStreams /f >nul 2>&1
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\TrayNotify" /v PastIconsStream /f >nul 2>&1

rem エクスプローラー（フォルダビュー設定）
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\BagMRU" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\Shell\BagMRU" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\Shell\Bags" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell" /v FolderType /f >nul 2>&1

rem エクスプローラー（表示設定）
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "LaunchTo" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Hidden" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSyncProviderNotifications" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAnimations" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarDa" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarMn" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowCopilotButton" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v "WaitForIdleState" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v "StartupDelayInMSec" /f >nul 2>&1

rem 検索設定
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /f >nul 2>&1

rem デスクトップ設定
reg delete "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /f >nul 2>&1
reg delete "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /f >nul 2>&1

rem アクセシビリティ設定
reg delete "HKCU\Control Panel\Accessibility\StickyKeys" /v "Flags" /f >nul 2>&1
reg delete "HKCU\Control Panel\Accessibility\ToggleKeys" /v "Flags" /f >nul 2>&1
reg delete "HKCU\Control Panel\Accessibility\Keyboard Response" /v "Flags" /f >nul 2>&1

rem コンテンツ配信マネージャー
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SystemPaneSuggestionsEnabled /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SoftLandingEnabled /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338388Enabled /f >nul 2>&1

rem Windows Copilot
reg delete "HKCU\Software\Policies\Microsoft\Windows\WindowsCopilot" /v "TurnOffWindowsCopilot" /f >nul 2>&1
reg delete "HKLM\Software\Policies\Microsoft\Windows\WindowsCopilot" /v "TurnOffWindowsCopilot" /f >nul 2>&1

rem ニュースと関心事項
reg delete "HKCU\SOFTWARE\Policies\Microsoft\Dsh" /v "AllowNewsAndInterests" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v "AllowNewsAndInterests" /f >nul 2>&1

rem バックグラウンドアクセスアプリケーション
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /f >nul 2>&1

rem メモリ管理
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v SessionViewSize /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v DisablePagingExecutive /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v SystemCacheLimit /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v PoolUsageMaximum /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v MaxPrefetchFiles /f >nul 2>&1

rem ファイルシステム
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v NtfsMemoryUsage /f >nul 2>&1

rem セッション管理
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\SubSystems" /v SharedSection /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Segment Heap" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /f >nul 2>&1

rem グラフィックスドライバー
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /f >nul 2>&1

rem DWM（デスクトップウィンドウマネージャー）
reg delete "HKLM\SOFTWARE\Microsoft\Windows\Dwm" /v OverlayTestMode /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations" /v DWMFRAMEINTERVAL /f >nul 2>&1

rem ストレージ
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\stornvme\Parameters\Device" /v "ForcedPhysicalSectorSizeInBytes" /f >nul 2>&1

rem マルチメディア（MMCSS）
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "AlwaysHighPriority" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Playback" /v "Priority" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Capture" /v "Priority" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Clock Rate" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "NetworkThrottlingIndex" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\DisplayPostProcessing" /v "NetworkThrottlingIndex" /f >nul 2>&1

rem ゲームバー
reg delete "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\GameBar" /v "UseNexusForGameBarEnabled" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\GameBar" /v ShowStartupPanel /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\GameBar" /v Enabled /f >nul 2>&1

rem GameDVR
reg delete "HKCU\System\GameConfigStore" /v GameDVR_Enabled /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /f >nul 2>&1

rem 電力スロットリング
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v PowerThrottlingOff /f >nul 2>&1

rem ネットワーク（AFD）
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v DefaultReceiveWindow /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v DefaultSendWindow /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v MaxFastDgramRecv /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v MaxFastReceive /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v MaxFastTransmit /f >nul 2>&1

rem ネットワーク（TCP/IP）
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnableDeadGWDetect /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnableICMPRedirect /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnablePMTUBHDetect /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnableTCPChimney /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnableWsd /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpCongestionControl /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v GlobalMaxTcpWindowSize /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpWindowSize /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpInitialRtt /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v DefaultTTL /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnablePMTUDiscovery /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v MaxUserPort /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v Tcp1323Opts /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpEcnCapability /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpFastOpen /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpFastOpenFallback /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpInitialCWnd /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpMaxDupAcks /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpNoDelay /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpTimedWaitDelay /f >nul 2>&1

rem ネットワーク（TCP/IPv6）
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" /v DisableIPAutoConfigurationLimits /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" /v MaxUserPort /f >nul 2>&1

rem ネットワーク（DNS）
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v MaxCacheTtl /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v MaxNegativeCacheTtl /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v MaxSOACacheTtl /f >nul 2>&1

rem ネットワーク（HTTP）
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\HTTP\Parameters" /v EnableNonUTF8 /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\HTTP\Parameters" /v EnableUrlRewrite /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\HTTP\Parameters" /v MaxConnections /f >nul 2>&1

rem ネットワーク（SMB）
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v SizReqBuf /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "DirectoryCacheLifetime" /f >nul 2>&1

rem ネットワーク（QoS）
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "MaxOutstandingSends" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "TimerResolution" /f >nul 2>&1

rem ネットワーク（WLAN）
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\WlanSvc\Parameters" /v "EnableAutoDisconnect" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\WlanSvc\Parameters" /v "AutoDisconnectTimeout" /f >nul 2>&1

rem 時刻同期（W32Time）
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" /v "NtpServer" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" /v "Type" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v "AnnounceFlags" /f >nul 2>&1

echo  - 完了: レジストリ削除

rem ===================================================
rem MMAgent（メモリ圧縮/プリフェッチ等）の設定を元に戻す
rem ===================================================
echo [設定リセット] MMAgent の設定を戻しています...
powershell -NoProfile -Command "try { Enable-MMAgent -MemoryCompression -ErrorAction SilentlyContinue } catch {}" >nul 2>&1
powershell -NoProfile -Command "try { Enable-MMAgent -PageCombining -ErrorAction SilentlyContinue } catch {}" >nul 2>&1
powershell -NoProfile -Command "try { Enable-MMAgent -OperationAPI -ErrorAction SilentlyContinue } catch {}" >nul 2>&1
powershell -NoProfile -Command "try { Enable-MMAgent -ApplicationLaunchPrefetching -ErrorAction SilentlyContinue } catch {}" >nul 2>&1
powershell -NoProfile -Command "try { Enable-MMAgent -ApplicationPreLaunch -ErrorAction SilentlyContinue } catch {}" >nul 2>&1
echo  - 完了: MMAgent 設定（反映には再起動が必要な場合があります）

rem ===================================================
rem 電源関連設定を既定に戻す
rem ===================================================
echo [設定リセット] 電源設定を既定へ戻しています...
rem 電源プランを初期化
powercfg /restoredefaultschemes >nul 2>&1
powercfg /setactive SCHEME_BALANCED >nul 2>&1

rem ディスプレイ消灯時間を設定
powercfg /change monitor-timeout-ac 180
powercfg /change monitor-timeout-dc 30

rem スタンバイ時間を設定
powercfg /change standby-timeout-ac 0
powercfg /change standby-timeout-dc 60

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
rem 休止状態をオフにする
powercfg /hibernate off

echo  - 休止状態を無効化しました
echo  - 完了: 電源設定（反映には再起動が必要な場合があります）

rem ===================================================
rem ネットワーク（TCP/IP）最適化設定を既定に戻す
rem ===================================================
echo [設定リセット] ネットワーク（TCP/IP）設定を既定へ戻しています...
netsh advfirewall reset
netsh int tcp set global default >nul 2>&1
netsh int ipv6 set global loopbacklargemtu=enable >nul 2>&1
netsh int ipv4 set global loopbacklargemtu=enable >nul 2>&1
netsh int tcp set supplemental template=Internet congestionprovider=default >nul 2>&1
netsh int tcp set supplemental template=InternetCustom congestionprovider=default >nul 2>&1
netsh int tcp set supplemental template=Datacenter congestionprovider=default >nul 2>&1
netsh int tcp set supplemental template=DatacenterCustom congestionprovider=default >nul 2>&1
netsh int tcp set supplemental template=Compat congestionprovider=default >nul 2>&1
echo  - 完了: ネットワーク（TCP/IP）設定（反映には再起動が必要な場合があります）

rem ===================================================
rem エクスプローラー再起動
rem ===================================================
echo [エクスプローラー起動] エクスプローラーを起動しています...
start explorer.exe
echo  - 完了: エクスプローラー起動

echo.
echo すべてのリセット処理が完了しました。
echo 一部の設定は再起動後に完全に反映されます。
echo.
echo [再起動] システムを再起動しています...
shutdown /r /f /t 0
