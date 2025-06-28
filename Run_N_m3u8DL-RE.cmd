@echo off & setlocal enabledelayedexpansion

:: 初始化设置
Title N_m3u8DL-RE：跨平台的DASH/HLS/MSS下载工具 by nilaoda
color 0a & cls
pushd %~dp0

:: 主菜单
:menu
cls
echo.
echo *****************************
echo.
echo  1、下载视频
echo.  
echo  2、直播录制
echo.
echo *****************************
echo.
choice /C 12 /N /M "请选择操作:"
if errorlevel 2 goto live_record
if errorlevel 1 goto video_download_no_ad
goto menu

:: 功能选项
:video_download_no_ad
cls & echo.& echo 下载视频 & echo.
call :common_input
call :check_mixed_m3u8
call :analyze_ad_segments
call :custom_ad_keyword
set "video_download=N_m3u8DL-RE @config_common.conf @config_ad_keyword.conf !custom_ad_keyword! --save-name "!filename!" "!link!""
echo.运行命令：!video_download! & echo.
!video_download!
goto :end

:live_record
cls & echo.& echo 直播录制 & echo.
call :common_input
call :record_limit_input
set "live_record=N_m3u8DL-RE @config_common.conf @config_live_record.conf !live_record_limit! --save-name "!filename!" "!link!""
echo.运行命令：!live_record! & echo.
!live_record!
goto :end

:: 输入处理
:common_input
:set_link
set "link=" & set /p "link=请输入链接: "
if "!link!"=="" (echo 错误：输入不能为空！ & goto :set_link)

:set_filename 
set "filename=" & set /p "filename=请输入文件名（不能包含\/:*?^<>|）: "
if "!filename!"=="" (echo 错误：输入不能为空！ & goto :set_filename)
goto :eof

:check_mixed_m3u8
curl -s "!link!" > temp.m3u8
findstr /i "mixed.m3u8" temp.m3u8 >nul || goto :no_mixed
for /f "delims=" %%a in ('findstr /i "mixed.m3u8" temp.m3u8') do set "mixed_line=%%a"
set "base_url=!link:index.m3u8=!"
if not "!base_url:~-1!"=="/" if not "!base_url:~-1!"=="\" set "base_url=!base_url:/index.m3u8=!"
set "new_link=!base_url!!mixed_line!"
echo 新链接: !new_link!
curl -s "!new_link!" > temp_analyze.m3u8
goto :mixed_done

:no_mixed
copy temp.m3u8 temp_analyze.m3u8 >nul
:mixed_done
del temp.m3u8
goto :eof

:analyze_ad_segments
set "first_ts_length=0" & set "ad_detected=0" & set "line_count=0"
for /f "delims=" %%a in ('type temp_analyze.m3u8') do (
    set /a "line_count+=1"
    if !line_count! leq 500 echo %%a|find ".ts">nul && (
        if !first_ts_length! equ 0 (
            set "first_line=%%a"
            call :get_length "%%a"
            set "first_ts_length=!length!"
        ) else (
            call :get_length "%%a"
            if !length! gtr !first_ts_length! (
                set "ad_detected=1"
                echo 检测到可能的广告片段: %%a
                echo 长度: !length! (首个.ts长度: !first_ts_length!)
            )
        )
    )
)
if !ad_detected! equ 1 (
    echo. & echo 检测到广告片段特征，建议设置广告正则匹配
) else echo 未检测到广告片段特征
del temp_analyze.m3u8
goto :eof

:get_length
set "line=%~1" & set "length=0"
:length_loop
if not "!line:~%length%,1!"=="" (set /a length+=1 & goto length_loop)
goto :eof

:custom_ad_keyword
if !ad_detected! equ 1 (
    set "custom_ad_keyword="
    set /p "custom_ad_keyword=请输入广告匹配正则（可为空）: "
    if not "!custom_ad_keyword!"=="" set "custom_ad_keyword=--ad-keyword !custom_ad_keyword!"
) else set "custom_ad_keyword="
goto :eof

:record_limit_input
set "record_limit="
set /p "record_limit=请输入录制时长限制(格式：HH:mm:ss, 可为空): "
if "!record_limit!"=="" (set "live_record_limit=") else set "live_record_limit=--live-record-limit !record_limit!"
goto :eof

:: 结束处理
:end
timeout /t 3 /nobreak >nul