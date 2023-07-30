::2023.07.30
::�ǵñ���ΪASNI����

@echo off & setlocal enabledelayedexpansion

::��ʼ
Title N_m3u8DL-RE����ƽ̨��live_record/HLS/MSS���ع��� by nilaoda

cd /d %~dp0

::�˵�����
:menu
cls
ECHO.
ECHO  ѡ��
echo.                   
ECHO. **********************************************************
echo.
ECHO  1������m3u8��Ƶ
echo.
ECHO  2��ֱ��¼��
echo.
ECHO. **********************************************************
echo.
set /p a=�����������Ų��س���1��2����
cls

if %a%==1 goto m3u8_download
if %a%==2 goto live_record


::��ʼ����
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


::---------------���벿��---------------
:common_input
::�������� �� �ļ���
:set_link
set "link="
set /p "link=����������: "
if "!link!"=="" (
    echo �������벻��Ϊ�գ�
    goto set_link
)

:set_filename 
set "filename="
set /p "filename=�����뱣���ļ��������ܰ���"\/:*?"<>|"�κ�֮һ��: "
if "!filename!"=="" (
    echo �������벻��Ϊ�գ�
    goto set_filename
)

::�ӱ�ǩ�м���goto :eof������˳��ӱ�ǩ��������ִ�����������������
goto :eof

:live_record_input
:set_record_limit
set "record_limit="
set /p "record_limit=������¼��ʱ������(��ʽ��HH:mm:ss, ��Ϊ��): "
if "!record_limit!"=="" (
    set live_record_limit=
) else (
    set live_record_limit=--live-record-limit %record_limit%
    )
goto :eof

:custom_range_input
:set_custom_range
set "custom_range="
set /p "custom_range=�������Ƭ��Χ(��ʽ��0-10��10-��-99��05:00-20:00, ��Ϊ��): "
if "!custom_range!"=="" (
    set custom_range=
) else (
    set custom_range=--custom-range %custom_range%
    )
goto :eof


::---------------���ò���---------------
:setting_path
::������ʱ�ļ��洢Ŀ¼
set TempDir=N_m3u8DL_Temp

::�������Ŀ¼
set SaveDir=D:\Download\

::����ffmpeg.exe·��
set ffmpeg=..\..\..\MedLexo\bin\ffmpeg.exe

goto :eof

:setting_ad_keyword
::���ù��ؼ���
set user_ad_keyword="o\d{3,4}.ts$|/ads/|hesads.akamaized.net|doppiocdn.org|doppiocdn.com|stream.highwebmedia.com|redirector.gvt1.com/api|dmxleo.dailymotion.com/cdn/manifest/video/|"
goto :eof

:setting_m3u8_params
::����m3u8���ز���
set m3u8_params=--download-retry-count:9 --auto-select:true --check-segments-count:false --no-log:true --append-url-params:true --ad-keyword %user_ad_keyword% -mt:true --mp4-real-time-decryption:true --ui-language:zh-CN
goto :eof

:setting_live_record_params
::����ֱ��¼�Ʋ���
set live_record_params=--no-log:true --append-url-params:true -mt:true --mp4-real-time-decryption:true --ui-language:zh-CN -sv best -sa best --live-pipe-mux:true --live-keep-segments:false --live-fix-vtt-by-audio:true %live_record_limit% -M format=mp4:bin_path="%ffmpeg%"
goto :eof

::---------------����˵��---------------
::--tmp-dir <tmp-dir>                      ������ʱ�ļ��洢Ŀ¼
::--save-name <save-name>                  ���ñ����ļ���
::--save-dir <save-dir>                    �������Ŀ¼
::--download-retry-count <number>          ÿ����Ƭ�����쳣ʱ�����Դ��� [default: 3]
::--auto-select                            �Զ�ѡ���������͵���ѹ�� [default: False]
::--ad-keyword                             ѡ����˹��URL
::--check-segments-count                   ���ʵ�����صķ�Ƭ������Ԥ�������Ƿ�ƥ�� [default: True]
::--no-log                                 �ر���־�ļ���� [default: False]
::--append-url-params                      ������Url��Params�������Ƭ, ��ĳЩ��վ������ [default: False]
::-mt, --concurrent-download               ����������ѡ�����Ƶ����Ƶ����Ļ [default: False]
::--mp4-real-time-decryption               ʵʱ����MP4��Ƭ [default: False]
::-M, --mux-after-done <OPTIONS>           ���й������ʱ���Ի������������Ƶ
::--custom-range <RANGE>                   �����ز��ַ�Ƭ. ���� "--morehelp custom-range" �Բ鿴��ϸ��Ϣ
::--ffmpeg-binary-path <PATH>              ffmpeg��ִ�г���ȫ·��, ���� C:\Tools\ffmpeg.exe
::--ui-language <en-US|zh-CN|zh-TW>        ����UI����
::--live-keep-segments                     ¼��ֱ��������ʵʱ�ϲ�ʱ��Ȼ������Ƭ [default: True]
::--live-pipe-mux                          ¼��ֱ��������ʵʱ�ϲ�ʱͨ���ܵ�+ffmpegʵʱ������TS�ļ� [default: False]
::--live-fix-vtt-by-audio                  ͨ����ȡ��Ƶ�ļ�����ʼʱ������VTT��Ļ [default: False]
::--live-record-limit <HH:mm:ss>           ¼��ֱ��ʱ��¼��ʱ������
::-sv, --select-video <OPTIONS>            ͨ��������ʽѡ�����Ҫ�����Ƶ��. ���� "--morehelp select-video" �Բ鿴��ϸ��Ϣ
::-sa, --select-audio <OPTIONS>            ͨ��������ʽѡ�����Ҫ�����Ƶ��. ���� "--morehelp select-audio" �Բ鿴��ϸ��Ϣ
::-ss, --select-subtitle <OPTIONS>         ͨ��������ʽѡ�����Ҫ�����Ļ��. ���� "--morehelp select-subtitle" �Բ鿴��ϸ��Ϣ
::-dv, --drop-video <OPTIONS>              ͨ��������ʽȥ������Ҫ�����Ƶ��.
::-da, --drop-audio <OPTIONS>              ͨ��������ʽȥ������Ҫ�����Ƶ��.
::-ds, --drop-subtitle <OPTIONS>           ͨ��������ʽȥ������Ҫ�����Ļ��.

::---------------�������---------------
:m3u8_download_print
cls
echo.�������N_m3u8DL-RE "%link%" %m3u8_params% --ffmpeg-binary-path %ffmpeg% --tmp-dir %TempDir% --save-dir %SaveDir% --save-name "%filename%"
::��һ��
echo.
goto :eof

:live_record_print
cls
echo.�������N_m3u8DL-RE "%link%" %live_record_params% --tmp-dir %TempDir% --save-dir %SaveDir% --save-name "%filename%"
::��һ��
echo.
goto :eof


::��������
:m3u8_downloading
::��%filename%�����ţ���ֹ�ļ�������ĳЩ���ŵ���·��ʶ�eʧ��
N_m3u8DL-RE "%link%" %m3u8_params% --ffmpeg-binary-path %ffmpeg% --tmp-dir %TempDir% --save-dir %SaveDir% --save-name "%filename%"
goto :eof

:live_recording
N_m3u8DL-RE "%link%" %live_record_params% --tmp-dir %TempDir% --save-dir %SaveDir% --save-name "%filename%"
goto :eof

::���������ͣһ��ʱ��رմ��ڣ���ֹ���б���ʱֱ�ӹرմ��ڡ�
:when_done
timeout /t 10 /nobreak
exit
goto :eof


