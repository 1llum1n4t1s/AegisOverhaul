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
rem TheMaintenance.bat の reg delete をそのまま実行
rem ===================================================
echo [設定リセット] レジストリ削除（TheMaintenance同等）を実行しています...
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\TrayNotify" /v IconStreams /f >nul 2>&1
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\TrayNotify" /v PastIconsStream /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache /f >nul 2>&1
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\BagMRU" /f >nul 2>&1
echo  - 完了: レジストリ削除（TheMaintenance同等）

rem ===================================================
rem TheMaintenance.bat の reg add を reg delete で打ち消す
rem ===================================================
echo [設定リセット] レジストリ追加分（TheMaintenance同等）を削除しています...
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Playback" /v "Priority" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Capture" /v "Priority" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "AlwaysHighPriority" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "DirectoryCacheLifetime" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" /v "NtpServer" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" /v "Type" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v "AnnounceFlags" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell" /v FolderType /f >nul 2>&1
echo  - 完了: レジストリ追加分（TheMaintenance同等）の削除

rem ===================================================
rem アクセシビリティ（固定キー等）の設定を既定に戻す
rem 対象: TheMaintenance.bat で Flags を変更した項目
rem 方針: 値を削除し、Windowsの既定動作に委ねる
rem ===================================================
echo [設定リセット] アクセシビリティ設定を既定へ戻しています...
reg delete "HKCU\Control Panel\Accessibility\StickyKeys" /v "Flags" /f >nul 2>&1
reg delete "HKCU\Control Panel\Accessibility\ToggleKeys" /v "Flags" /f >nul 2>&1
reg delete "HKCU\Control Panel\Accessibility\Keyboard Response" /v "Flags" /f >nul 2>&1
echo  - 完了: アクセシビリティ設定

rem ===================================================
rem ゲーム関連（MMCSSタスク）の設定を既定に戻す
rem 対象: Tasks\Games の Priority / GPU Priority / Scheduling Category
rem 方針: 値を削除し、Windowsの既定動作に委ねる
rem ===================================================
echo [設定リセット] ゲーム関連の優先度設定を既定へ戻しています...
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /f >nul 2>&1
echo  - 完了: ゲーム関連の優先度設定

rem ===================================================
rem GameDVR（録画/キャプチャ）設定を既定に戻す
rem 対象: GameDVR_Enabled / AppCaptureEnabled を 0 にしていた項目
rem 方針: 一般的な既定に合わせて 1 に戻す（値が存在しない場合もあるため add で復元）
rem ===================================================
echo [設定リセット] GameDVR（録画/キャプチャ）設定を既定へ戻しています...
reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 1 /f >nul 2>&1
echo  - 完了: GameDVR 設定

rem ===================================================
rem 電力スロットリング設定を既定に戻す
rem 対象: PowerThrottlingOff=1
rem 方針: 値を削除し、Windowsの既定動作に委ねる
rem ===================================================
echo [設定リセット] 電力スロットリング設定を既定へ戻しています...
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v PowerThrottlingOff /f >nul 2>&1
echo  - 完了: 電力スロットリング設定

rem ===================================================
rem MMAgent（メモリ圧縮/プリフェッチ等）の設定を元に戻す（TheMaintenanceの逆操作）
rem 対象:
rem  - Enable: MemoryCompression / PageCombining
rem  - Disable: OperationAPI / ApplicationLaunchPrefetching / ApplicationPreLaunch
rem ===================================================
echo [設定リセット] MMAgent の設定を戻しています...
powershell -NoProfile -Command "try { Disable-MMAgent -MemoryCompression -ErrorAction SilentlyContinue } catch {}" >nul 2>&1
powershell -NoProfile -Command "try { Disable-MMAgent -PageCombining -ErrorAction SilentlyContinue } catch {}" >nul 2>&1
powershell -NoProfile -Command "try { Enable-MMAgent -OperationAPI -ErrorAction SilentlyContinue } catch {}" >nul 2>&1
powershell -NoProfile -Command "try { Enable-MMAgent -ApplicationLaunchPrefetching -ErrorAction SilentlyContinue } catch {}" >nul 2>&1
powershell -NoProfile -Command "try { Enable-MMAgent -ApplicationPreLaunch -ErrorAction SilentlyContinue } catch {}" >nul 2>&1
echo  - 完了: MMAgent 設定（反映には再起動が必要な場合があります）

rem ===================================================
rem スタートアップ遅延の設定を既定に戻す
rem 対象: Explorer\Serialize の WaitForIdleState / StartupDelayInMSec を 0 にしていた項目
rem 方針: 値を削除し、Windowsの既定動作に委ねる
rem ===================================================
echo [設定リセット] スタートアップ遅延関連の設定を既定へ戻しています...
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v "WaitForIdleState" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v "StartupDelayInMSec" /f >nul 2>&1
echo  - 完了: スタートアップ遅延関連

rem ===================================================
rem MPO（マルチプレーンオーバーレイ）設定を既定に戻す
rem 対象: Dwm\OverlayTestMode=5
rem 方針: 値を削除し、Windowsの既定動作に委ねる
rem ===================================================
echo [設定リセット] MPO 設定を既定へ戻しています...
reg delete "HKLM\SOFTWARE\Microsoft\Windows\Dwm" /v OverlayTestMode /f >nul 2>&1
echo  - 完了: MPO 設定

rem ===================================================
rem リモートデスクトップのフレーム間隔設定を既定に戻す
rem 対象: WinStations\DWMFRAMEINTERVAL=15
rem 方針: 値を削除し、Windowsの既定動作に委ねる
rem ===================================================
echo [設定リセット] リモートデスクトップ表示設定を既定へ戻しています...
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations" /v DWMFRAMEINTERVAL /f >nul 2>&1
echo  - 完了: リモートデスクトップ表示設定

rem ===================================================
rem 電源関連設定を既定に戻す
rem 対象:
rem  - TheMaintenance.bat は電源プランを既定へリセットし、一部のタイムアウト/動作を上書き
rem 方針:
rem  - Windows既定の電源プランへ戻す（ユーザー独自の電源プランは復元できません）
rem  - 休止状態は有効へ戻す（TheMaintenance は off）
rem ===================================================
echo [設定リセット] 電源設定を既定へ戻しています...
powercfg /restoredefaultschemes >nul 2>&1
powercfg /setactive SCHEME_BALANCED >nul 2>&1
powercfg /hibernate on >nul 2>&1
echo  - 完了: 電源設定（反映には再起動が必要な場合があります）

rem ===================================================
rem 時刻同期（w32time）の設定を既定に戻す
rem 対象: NtpServer/Type/AnnounceFlags を変更していた項目
rem 方針: サービスを再登録して既定構成に戻す
rem ===================================================
echo [設定リセット] 時刻同期サービスの設定を既定へ戻しています...
net stop w32time >nul 2>&1
w32tm /unregister >nul 2>&1
w32tm /register >nul 2>&1
net start w32time >nul 2>&1
w32tm /resync >nul 2>&1
echo  - 完了: 時刻同期サービス

rem ===================================================
rem ネットワーク（TCP/IP）最適化設定を既定に戻す
rem 対象:
rem  - netsh int tcp の各種 global 設定
rem  - 輻輳制御（BBR2）テンプレート設定
rem 方針:
rem  - global を既定へ戻す
rem  - supplemental template の congestionprovider を default に戻す
rem ===================================================
echo [設定リセット] ネットワーク（TCP/IP）設定を既定へ戻しています...
netcfg -d
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
rem エクスプローラー（フォルダ種別固定）の設定を既定に戻す
rem 対象: Bags\AllFolders\Shell\FolderType=NotSpecified
rem 方針: 値を削除し、Windowsの既定動作に委ねる
rem ===================================================
echo [設定リセット] エクスプローラーのフォルダ種別設定を既定へ戻しています...
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell" /v FolderType /f >nul 2>&1
echo  - 完了: エクスプローラー設定

rem ===================================================
rem エクスプローラー再起動
rem ===================================================
echo [エクスプローラー起動] エクスプローラーを起動しています...
start explorer.exe
echo  - 完了: エクスプローラー起動

echo.
echo すべてのリセット処理が完了しました。
echo 一部の設定は再起動後に完全に反映されます。
pause
