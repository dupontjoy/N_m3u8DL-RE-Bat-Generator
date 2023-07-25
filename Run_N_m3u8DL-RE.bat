::2023.07.24
::�ǵñ���ΪASNI����

@echo off & setlocal enabledelayedexpansion

::��ʼ
Title N_m3u8DL-RE����ƽ̨��DASH/HLS/MSS���ع��� by nilaoda

cd /d %~dp0

::�˵�����
:menu
cls
ECHO.
ECHO  ����ѡ��
echo.                   
ECHO. **********************************************************
echo.
ECHO  1��m3u8��Ƶ
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
call :setting_m3u8_params
call :path_print
call :m3u8_download_print
call :m3u8_downloading
call :when_done
goto :eof

:live_record
call :common_input
call :live_record_input
call :setting_path
call :setting_live_record_params
call :path_print
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
set /p "filename=�����뱣���ļ���: "
if "!filename!"=="" (
    echo �������벻��Ϊ�գ�
    goto set_filename
)

::�ӱ�ǩ�м���goto :eof������˳��ӱ�ǩ��������ִ�����������������
goto :eof

:live_record_input
:set_record_limit
set "record_limit="
set /p "record_limit=������¼��ʱ������:(��ʽ��HH:mm:ss) "
if "!record_limit!"=="" (
    echo �������벻��Ϊ�գ�
    goto set_record_limit
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


:setting_m3u8_params
::����m3u8���ز���
set m3u8_params=--download-retry-count:9 --auto-select:true --check-segments-count:false --no-log:true --append-url-params:true -mt:true --mp4-real-time-decryption:true --ui-language:zh-CN

goto :eof

:setting_live_record_params
::����ֱ��¼�Ʋ���
set dash_params=-sv best -sa best --live-real-time-merge:true --live-keep-segments:false --live-fix-vtt-by-audio:true --live-record-limit %record_limit% --no-log:true -mt:true -M format=mp4:bin_path="%ffmpeg%"

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
::--append-url-params                      ������Url��Params��������Ƭ, ��ĳЩ��վ������ [default: False]
::-mt, --concurrent-download               ����������ѡ�����Ƶ����Ƶ����Ļ [default: False]
::--mp4-real-time-decryption               ʵʱ����MP4��Ƭ [default: False]
::-M, --mux-after-done <OPTIONS>           ���й������ʱ���Ի������������Ƶ
::--custom-range <RANGE>                   �����ز��ַ�Ƭ. ���� "--morehelp custom-range" �Բ鿴��ϸ��Ϣ
::--ffmpeg-binary-path <PATH>              ffmpeg��ִ�г���ȫ·��, ���� C:\Tools\ffmpeg.exe
::--ui-language <en-US|zh-CN|zh-TW>        ����UI����
::--live-real-time-merge                   ¼��ֱ��ʱʵʱ�ϲ� [default: False]
::--live-keep-segments                     ¼��ֱ��������ʵʱ�ϲ�ʱ��Ȼ������Ƭ [default: True]
::--live-fix-vtt-by-audio                  ͨ����ȡ��Ƶ�ļ�����ʼʱ������VTT��Ļ [default: False]
::--live-record-limit <HH:mm:ss>           ¼��ֱ��ʱ��¼��ʱ������

::---------------�������---------------
:path_print
cls
echo.��ʱĿ¼��%TempDir%
echo.���Ŀ¼��%SaveDir%
echo.ffmpeg.exe·����%ffmpeg%
::��һ��
echo.
goto :eof

:m3u8_download_print
echo.�������N_m3u8DL-RE %m3u8_params% "%link%" --ffmpeg-binary-path %ffmpeg% --tmp-dir %TempDir% --save-dir %SaveDir% --save-name %filename%
::��һ��
echo.
goto :eof

:live_record_print
echo.�������N_m3u8DL-RE %dash_params% "%link%" --tmp-dir %TempDir% --save-dir %SaveDir% --save-name %filename%
::��һ��
echo.
goto :eof


::��������
:m3u8_downloading
::��filename�ŵ���󣬷�ֹ�ļ�������ĳЩ���ŵ���·��ʶ�eʧ��
N_m3u8DL-RE %m3u8_params% "%link%" --ffmpeg-binary-path %ffmpeg% --tmp-dir %TempDir% --save-dir %SaveDir% --save-name %filename%
goto :eof

:live_recording
::��filename�ŵ���󣬷�ֹ�ļ�������ĳЩ���ŵ���·��ʶ�eʧ��
N_m3u8DL-RE %dash_params% "%link%" --tmp-dir %TempDir% --save-dir %SaveDir% --save-name %filename%
goto :eof

::���������ͣһ��ʱ��رմ��ڣ���ֹ���б���ʱֱ�ӹرմ��ڡ�
:when_done
timeout /t 5 /nobreak
exit
goto :eof

