@echo off
setlocal

:: Get the path to the user's Desktop
set "DESKTOP_DIR=%USERPROFILE%\Desktop"

:: Set the repository ZIP URL and directory
set REPO_URL=https://github.com/Udoy2/gxyvcc/archive/refs/tags/v1.0.0.zip
set REPO_ZIP=gxyvcc.zip
set FINAL_REPO_DIR=%DESKTOP_DIR%\gxyvcc-1.0.0

:: Check if Python is installed
python --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Python is not installed. Installing Python...
    :: Download Python installer
    curl -L https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe -o python_installer.exe
    :: Install Python (without modifying environment variables or installing additional tools)
    start /wait python_installer.exe /quiet InstallAllUsers=1 PrependPath=1
    del python_installer.exe
    echo Python installed successfully.
) else (
    echo Python is already installed.
)

:: Check if the repository ZIP file exists
if not exist "%DESKTOP_DIR%\%REPO_ZIP%" (
    echo Downloading repository ZIP...
    curl -L %REPO_URL% -o "%DESKTOP_DIR%\%REPO_ZIP%"
) else (
    echo Repository ZIP file already downloaded.
)

:: Verify if the ZIP file exists after download
if not exist "%DESKTOP_DIR%\%REPO_ZIP%" (
    echo Failed to download the ZIP file. Exiting...
    exit /b 1
)

:: Check file size of the downloaded ZIP to verify it downloaded correctly
for %%F in ("%DESKTOP_DIR%\%REPO_ZIP%") do set FILESIZE=%%~zF
echo File size of downloaded ZIP: %FILESIZE% bytes

if %FILESIZE% lss 1000 (
    echo The downloaded ZIP file is too small. The download may have failed. Exiting...
    exit /b 1
)

if exist "%FINAL_REPO_DIR%" (
    echo The repository is already extracted. Skipping extraction.
) else (
    :: Unzip the repository ZIP file using PowerShell
    echo Attempting to unzip the repository...
    powershell -Command "Expand-Archive -Path '%DESKTOP_DIR%\%REPO_ZIP%' -DestinationPath '%FINAL_REPO_DIR%'"
    :: Add a small delay to ensure extraction is complete
    echo Waiting for a few seconds to ensure extraction is complete...
    timeout /t 3 /nobreak >nul
    :: Check if the extracted folder is named "gxyvcc-1.0.0"
    if exist "%DESKTOP_DIR%\gxyvcc-1.0.0" (
        echo Repository extracted successfully.
    ) else (
        echo Repository extraction failed. The folder gxyvcc does not exist. Exiting...
        exit /b 1
    )
)






:: Change to the repository directory
cd "%FINAL_REPO_DIR%"

:: Create the virtual environment if not already set up
if not exist "venv" (
    echo Setting up virtual environment...
    python -m venv venv
)

:: Activate the virtual environment
call venv\Scripts\activate

:: Install setuptools before installing requirements
echo Installing setuptools...
pip install setuptools

:: Install requirements if not already installed
if not exist "venv\Lib\site-packages\uvicorn" (
    echo Installing requirements...
    pip install -r requirements.txt
)

:: Run the app with uvicorn over HTTP
echo Running the app with uvicorn on HTTP...
uvicorn main:app --host 0.0.0.0 --port 8000 --reload

:: End of script
endlocal
