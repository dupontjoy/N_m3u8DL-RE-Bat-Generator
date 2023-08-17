::2023.08.15
::�Ƽ�����ΪASNI����

@echo off & setlocal enabledelayedexpansion

::��ʼ
Title N_m3u8DL-RE����ƽ̨��DASH/HLS/MSS���ع��� by nilaoda

::������ɫ��С��ColsΪ��LinesΪ��
color 0a

pushd %~dp0

::---------------�˵�����---------------
:menu
cls
ECHO.
ECHO  ѡ��
echo.                   
ECHO. *******************************************************************************************
echo.
ECHO  1��������Ƶ
echo.
ECHO  2��ֱ��¼��
echo.
ECHO. *******************************************************************************************
echo.
CHOICE /C 12 /N >NUL 2>NUL
cls

IF "%ERRORLEVEL%"=="1" (goto video_download)
IF "%ERRORLEVEL%"=="2" (goto live_record)


::����ѡ��
:video_download
cls
call :common_input
call :setting_video_download
call :video_download_print
call :video_downloading
call :when_done
goto :eof

:live_record
call :common_input
call :live_record_input
call :setting_live_record
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
:setting_video_download
::����video��������
::��%filename%�����ţ���ֹ�ļ�������ĳЩ���ŵ���·��ʶ�eʧ��
set video_download=N_m3u8DL-RE @config_video_download.json "%link%" --save-name "%filename%"
goto :eof

:setting_live_record
::����ֱ��¼������
set live_record=N_m3u8DL-RE @config_live_record.json %live_record_limit% "%link%" --save-name "%filename%"
goto :eof


::---------------�������---------------
:video_download_print
cls
echo.�������%video_download%
::��һ��
echo.
goto :eof

:live_record_print
cls
echo.�������%live_record%
::��һ��
echo.
goto :eof


::---------------���в���---------------
:video_downloading
::��ʼ����
%video_download%
goto :eof

:live_recording
::��ʼ¼��
%live_record%
goto :eof


::---------------��������---------------
::���������ͣһ��ʱ��رմ��ڣ���ֹ���б���ʱֱ�ӹرմ��ڡ�
:when_done
timeout /t 10 /nobreak

goto :eof


