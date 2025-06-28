@echo off & setlocal enabledelayedexpansion

:: ��ʼ������
Title N_m3u8DL-RE����ƽ̨��DASH/HLS/MSS���ع��� by nilaoda
color 0a & cls
pushd %~dp0

:: ���˵�
:menu
cls
echo.
echo *****************************
echo.
echo  1��������Ƶ
echo.  
echo  2��ֱ��¼��
echo.
echo *****************************
echo.
choice /C 12 /N /M "��ѡ�����:"
if errorlevel 2 goto live_record
if errorlevel 1 goto video_download_no_ad
goto menu

:: ����ѡ��
:video_download_no_ad
cls & echo.& echo ������Ƶ & echo.
call :common_input
call :check_mixed_m3u8
call :analyze_ad_segments
call :custom_ad_keyword
set "video_download=N_m3u8DL-RE @config_common.conf @config_ad_keyword.conf !custom_ad_keyword! --save-name "!filename!" "!link!""
echo.�������!video_download! & echo.
!video_download!
goto :end

:live_record
cls & echo.& echo ֱ��¼�� & echo.
call :common_input
call :record_limit_input
set "live_record=N_m3u8DL-RE @config_common.conf @config_live_record.conf !live_record_limit! --save-name "!filename!" "!link!""
echo.�������!live_record! & echo.
!live_record!
goto :end

:: ���봦��
:common_input
:set_link
set "link=" & set /p "link=����������: "
if "!link!"=="" (echo �������벻��Ϊ�գ� & goto :set_link)

:set_filename 
set "filename=" & set /p "filename=�������ļ��������ܰ���\/:*?^<>|��: "
if "!filename!"=="" (echo �������벻��Ϊ�գ� & goto :set_filename)
goto :eof

:check_mixed_m3u8
curl -s "!link!" > temp.m3u8
findstr /i "mixed.m3u8" temp.m3u8 >nul || goto :no_mixed
for /f "delims=" %%a in ('findstr /i "mixed.m3u8" temp.m3u8') do set "mixed_line=%%a"
set "base_url=!link:index.m3u8=!"
if not "!base_url:~-1!"=="/" if not "!base_url:~-1!"=="\" set "base_url=!base_url:/index.m3u8=!"
set "new_link=!base_url!!mixed_line!"
echo ������: !new_link!
curl -s "!new_link!" > temp_analyze.m3u8
goto :mixed_done

:no_mixed
copy temp.m3u8 temp_analyze.m3u8 >nul
:mixed_done
del temp.m3u8
goto :eof

:analyze_ad_segments
set "first_ts_length=0" & set "ad_detected=0" & set "line_count=0"
set "ad_count=0"
set "ad_segments="
set "ad_regex="
set "first_ts_id="

for /f "delims=" %%a in ('type temp_analyze.m3u8') do (
    set /a "line_count+=1"
    echo %%a|find ".ts">nul && (
        if !first_ts_length! equ 0 (
            set "first_line=%%a"
            call :get_length "%%a"
            set "first_ts_length=!length!"
            :: ��ȡ�׸�.tsƬ�ε�ID
            set "first_ts_id=%%a"
            set "first_ts_id=!first_ts_id:.ts=!"
            set "first_ts_id=!first_ts_id:/=\!"
            set "first_ts_id=!first_ts_id:\=/!"
            set "first_ts_id=!first_ts_id:*/=!"
            set "first_ts_id=!first_ts_id:*/=!"
            echo.
            echo �׸�.tsƬ��ID: !first_ts_id!
            echo ����: !first_ts_length!
        ) else (
            call :get_length "%%a"
            if !length! gtr !first_ts_length! (
                set /a "ad_count+=1"
                set "ad_detected=1"
                set "ad_segment=%%a"
                set "ad_segment=!ad_segment:.ts=!"
                set "ad_segment=!ad_segment:/=\!"
                set "ad_segment=!ad_segment:\=/!"
                set "ad_segments=!ad_segments! !ad_segment!"
                echo ��⵽���ܵĹ��Ƭ��: %%a
                echo ����: !length! (�׸�.ts����: !first_ts_length!)
            )
        )
    )
)

if !ad_detected! equ 1 (
    echo. 
    echo ����⵽ !ad_count! �����Ƭ��
    echo �������ɹ��������ʽ...
    
    :: ���ɸ�ͨ�õĹ��������ʽ
    set "ad_regex="
    for %%a in (!ad_segments!) do (
        if "!ad_regex!"=="" (
            set "ad_regex=.*%%a.*"
        ) else (
            set "ad_regex=!ad_regex!|.*%%a.*"
        )
    )
    echo.
    echo ���ɵĹ������: !ad_regex!
    echo.
    choice /C YN /M "�Ƿ�Ӧ�ô˹��������ʽ(Y/N)?"
    if errorlevel 2 (
        set "custom_ad_keyword="
        echo �������������Ӧ��
    ) else (
        set "custom_ad_keyword=--ad-keyword "!ad_regex!""
        echo ��Ӧ�ù��������ʽ
    )
) else (
    echo δ��⵽���Ƭ������
    set "custom_ad_keyword="
)
del temp_analyze.m3u8
goto :eof

:get_length
set "line=%~1" & set "length=0"
:length_loop
if not "!line:~%length%,1!"=="" (set /a length+=1 & goto length_loop)
goto :eof

:custom_ad_keyword
:: ���ﲻ����Ҫ���⴦������analyze_ad_segments�����
goto :eof

:record_limit_input
set "record_limit="
set /p "record_limit=������¼��ʱ������(��ʽ��HH:mm:ss, ��Ϊ��): "
if "!record_limit!"=="" (set "live_record_limit=") else set "live_record_limit=--live-record-limit !record_limit!"
goto :eof

:: ��������
:end
timeout /t 3 /nobreak >nul