@echo off

echo Prepare directories...
set script_dir=%~dp0
set src_dir=%script_dir%..

cd /D %src_dir%

echo Project directory: %src_dir%

echo Looking for vswhere.exe...
set "vswhere=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%vswhere%" set "vswhere=%ProgramFiles%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%vswhere%" (
	echo ERROR: Failed to find vswhere.exe
	exit 1
)
echo Found %vswhere%

echo Looking for VC...
for /f "usebackq tokens=*" %%i in (`"%vswhere%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do (
  set vc_dir=%%i
)
if not exist "%vc_dir%\Common7\Tools\vsdevcmd.bat" (
	echo ERROR: Failed to find VC tools x86/x64
	exit 1
)
echo Found %vc_dir%

REM call "%vc_dir%\Common7\Tools\vsdevcmd.bat" -arch=x86 -host_arch=x64

call "%vc_dir%\Common7\Tools\vsdevcmd.bat" -arch=x64 -host_arch=x64

cd /D %src_dir%
REM set "PATH=%PATH%;%src_dir%\webview\dll\x64;%src_dir%\webview\dll\x86"

echo Running tests
nimble test

echo Building examples
nimble examples

copy "%src_dir%\webview\script\microsoft.web.webview2.0.9.488\build\native\x64\WebView2Loader.dll" "%src_dir%\examples\demo"
copy "%src_dir%\webview\script\microsoft.web.webview2.0.9.488\build\native\x64\WebView2Loader.dll" "%src_dir%\examples\simple"
