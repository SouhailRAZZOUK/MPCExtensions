@ECHO OFF
@echo -- NuGet Process Start --

set TARGETDIR=%~1
set TARGETNAME=%~2
set PROJECTDIR=%~3
set NUPKG=%TARGETDIR%nupkg

echo.%NUPKG%|findstr /r "Release" >nul
if %errorlevel%==1 (
   echo ERROR Debug build - nuget must be Release
   goto end
)

echo.%NUPKG%|findstr /C:"x86" >nul 2>&1
if %errorlevel%==0 (
   echo ERROR targets x86 - nuget must target AnyCPU
   goto end
)

echo.%NUPKG%|findstr /C:"x64" >nul 2>&1
if %errorlevel%==0 (
   echo ERROR targets x64 - nuget must target AnyCPU
   goto end
)

echo.%NUPKG%|findstr /C:"ARM" >nul 2>&1
if %errorlevel%==0 (
   echo ERROR targets ARM - nuget must target AnyCPU
   goto end
)

if "%NuGetCachePath%"=="" (  
	set CACHE=%USERPROFILE%\.nuget\packages\MPCExtensions\
) else (  
	set CACHE=%NuGetCachePath%\MPCExtensions\
)  

:clear nuget cache
if exist "%CACHE%" (
	echo OK Nuget cache will be cleared: %CACHE%
	rmdir "%CACHE%" /S/Q >nul
) else (
	echo OK No nuget cache to clear: %CACHE%
)

:clear previous build
if exist "%NUPKG%" (
	echo OK Previous build will be cleared: "%NUPKG%"
	rmdir "%NUPKG%" /S/Q >nul
) else (
	echo OK No previous build to clear: "%NUPKG%"
)

echo Copy \lib\*.dll(s)
xcopy.exe "%TARGETDIR%*.dll" "%NUPKG%\lib\" /y >nul

echo Copy \lib\*.pri(s)
xcopy.exe "%TARGETDIR%*.pri" "%NUPKG%\lib\" /y >nul

echo Copy \%TARGETDIR%%TARGETNAME%\*.*  %NUPKG%\lib\%TARGETNAME%\ 
xcopy.exe "%TARGETDIR%%TARGETNAME%\*.*" "%NUPKG%\lib\%TARGETNAME%\" /s/e/y >nul


echo Copy \%TARGETNAME%.nuspec
xcopy.exe "%PROJECTDIR%nuget\%TARGETNAME%.nuspec" "%NUPKG%" /y >nul

md %NUPKG%\build

echo Execute Pack %NUPKG%\ +++ %TARGETNAME%.nuspec ---------------- OutputDirectory "%NUPKG%" 
"%PROJECTDIR%nuget\NuGet.exe" pack "%NUPKG%\%TARGETNAME%.nuspec" -Verbosity detailed -OutputDirectory "%NUPKG%" -NonInteractive 

echo Copy %NUPKG%\*.nupkg +++++
xcopy.exe "%NUPKG%\*.nupkg" "c:\nuget-local\" /y >nul

:end
echo -- NuGet Process End --
exit /b 0