::2023.08.15
::推荐保存为ASNI编码

@echo off & setlocal enabledelayedexpansion

::开始
Title N_m3u8DL-RE：跨平台的DASH/HLS/MSS下载工具 by nilaoda

::界面大小，Cols为宽，Lines为高
COLOR 0a

pushd %~dp0

::菜单部分
:menu
cls
ECHO.
ECHO  选项
echo.                   
ECHO. *******************************************************************************************
echo.
ECHO  1、下载m3u8视频
echo.
ECHO  2、直播录制
echo.
ECHO. *******************************************************************************************
echo.
CHOICE /C 12 /N >NUL 2>NUL
cls

IF "%ERRORLEVEL%"=="1" (goto m3u8_download)
IF "%ERRORLEVEL%"=="2" (goto live_record)


::功能选项
:m3u8_download
cls
call :common_input
call :setting_path
call :setting_ad_keyword
call :setting_m3u8_params
call :m3u8_download_print
call :m3u8_downloading
call :when_done
goto :eof

:live_record
call :common_input
call :live_record_input
call :setting_path
call :setting_live_record_params
call :live_record_print
call :live_recording
call :when_done
goto :eof


::---------------输入部分---------------
:common_input
::输入链接 和 文件名
:set_link
set "link="
set /p "link=请输入链接: "
if "!link!"=="" (
    echo 错误：输入不能为空！
    goto set_link
)

:set_filename 
set "filename="
set /p "filename=请输入保存文件名（不能包含"\/:*?"<>|"任何之一）: "
if "!filename!"=="" (
    echo 错误：输入不能为空！
    goto set_filename
)

::子标签中加上goto :eof命令即可退出子标签，不继续执行它下面的其它命令
goto :eof

:live_record_input
:set_record_limit
set "record_limit="
set /p "record_limit=请输入录制时长限制(格式：HH:mm:ss, 可为空): "
if "!record_limit!"=="" (
    set live_record_limit=
) else (
    set live_record_limit=--live-record-limit %record_limit%
    )
goto :eof

:custom_range_input
:set_custom_range
set "custom_range="
set /p "custom_range=请输入分片范围(格式：0-10或10-或-99或05:00-20:00, 可为空): "
if "!custom_range!"=="" (
    set custom_range=
) else (
    set custom_range=--custom-range %custom_range%
    )
goto :eof


::---------------设置部分---------------
:setting_path
::设置临时文件存储目录
set TempDir=N_m3u8DL_Temp

::设置输出目录
set SaveDir=D:\Download\

::设置ffmpeg.exe路径
set ffmpeg=..\..\..\MPV\ffmpeg.exe

goto :eof

:setting_ad_keyword
::设置广告关键词
set user_ad_keyword="o\d{3,4}.ts|/ads?/|hesads.akamaized.net"
goto :eof

:setting_m3u8_params
::设置m3u8下载参数
set m3u8_params=--download-retry-count:99 --auto-select:true --check-segments-count:false --no-log:true --ad-keyword %user_ad_keyword% --ui-language:zh-CN

::将%filename%加引号，防止文件名带有某些符号导致路径识別失败
set m3u8_download=N_m3u8DL-RE "%link%" %m3u8_params% --ffmpeg-binary-path %ffmpeg% --tmp-dir %TempDir% --save-dir %SaveDir% --save-name "%filename%"
goto :eof

:setting_live_record_params
::设置直播录制参数
set live_record_params=--no-log:true --append-url-params:true -mt:true --mp4-real-time-decryption:true --ui-language:zh-CN -sv best -sa best --live-pipe-mux:true --live-keep-segments:false --live-fix-vtt-by-audio:true %live_record_limit% -M format=mp4:bin_path="%ffmpeg%"

set live_record=N_m3u8DL-RE "%link%" %live_record_params% --tmp-dir %TempDir% --save-dir %SaveDir% --save-name "%filename%"
goto :eof


::---------------参数说明---------------
::--tmp-dir <tmp-dir>                      设置临时文件存储目录
::--save-name <save-name>                  设置保存文件名
::--save-dir <save-dir>                    设置输出目录
::--download-retry-count <number>          每个分片下载异常时的重试次数 [default: 3]
::--auto-select                            自动选择所有类型的最佳轨道 [default: False]
::--ad-keyword                             选项过滤广告URL
::--check-segments-count                   检测实际下载的分片数量和预期数量是否匹配 [default: True]
::--no-log                                 关闭日志文件输出 [default: False]
::--append-url-params                      将输入Url的Params添加至分片, 对某些网站很有用 [default: False]
::-mt, --concurrent-download               并发下载已选择的音频、视频和字幕 [default: False]
::--mp4-real-time-decryption               实时解密MP4分片 [default: False]
::-M, --mux-after-done <OPTIONS>           所有工作完成时尝试混流分离的音视频
::--custom-range <RANGE>                   仅下载部分分片. 输入 "--morehelp custom-range" 以查看详细信息
::--ffmpeg-binary-path <PATH>              ffmpeg可执行程序全路径, 例如 C:\Tools\ffmpeg.exe
::--ui-language <en-US|zh-CN|zh-TW>        设置UI语言
::--live-keep-segments                     录制直播并开启实时合并时依然保留分片 [default: True]
::--live-pipe-mux                          录制直播并开启实时合并时通过管道+ffmpeg实时混流到TS文件 [default: False]
::--live-fix-vtt-by-audio                  通过读取音频文件的起始时间修正VTT字幕 [default: False]
::--live-record-limit <HH:mm:ss>           录制直播时的录制时长限制
::-sv, --select-video <OPTIONS>            通过正则表达式选择符合要求的视频流. 输入 "--morehelp select-video" 以查看详细信息
::-sa, --select-audio <OPTIONS>            通过正则表达式选择符合要求的音频流. 输入 "--morehelp select-audio" 以查看详细信息
::-ss, --select-subtitle <OPTIONS>         通过正则表达式选择符合要求的字幕流. 输入 "--morehelp select-subtitle" 以查看详细信息
::-dv, --drop-video <OPTIONS>              通过正则表达式去除符合要求的视频流.
::-da, --drop-audio <OPTIONS>              通过正则表达式去除符合要求的音频流.
::-ds, --drop-subtitle <OPTIONS>           通过正则表达式去除符合要求的字幕流.

::---------------输出部分---------------
:m3u8_download_print
cls
echo.下载命令：%m3u8_download%
::空一行
echo.
goto :eof

:live_record_print
cls
echo.下载命令：%live_record%
::空一行
echo.
goto :eof


::下载命令
:m3u8_downloading
::开始下载
%m3u8_download%
goto :eof

:live_recording
::开始下载
%live_record%
goto :eof

::下载完成暂停一段时间关闭窗口，防止运行报错时直接关闭窗口。
:when_done
timeout /t 10 /nobreak

goto :eof


