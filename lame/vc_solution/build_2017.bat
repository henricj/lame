@if exist "%VS150COMNTOOLS%VsDevCmd.bat" goto skipwhere

@if not defined VSWHWERE set VSWHERE="%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"

@if not exist %VSWHERE% set VSWHERE="%ProgramFiles%\Microsoft Visual Studio\Installer\vswhere.exe"

@if not exist %VSWHERE% goto weberrorexit

@set pre=Microsoft.VisualStudio.Product.
@set ids=%pre%Community %pre%Professional %pre%Enterprise %pre%BuildTools

@for /f "usebackq tokens=*" %%i in (`%VSWHERE% -latest -products %ids% -requires Microsoft.Component.MSBuild -requires Microsoft.VisualStudio.Workload.NativeDesktop -property installationPath`) do @(
  @set VS150COMNTOOLS=%%i\Common7\Tools\
)

@if not exist "%VS150COMNTOOLS%VsDevCmd.bat" goto weberrorexit

:skipwhere

md "%~dp0build\"

@setlocal

call "%VS150COMNTOOLS%VsDevCmd.bat"
@if %errorlevel% neq 0 goto errorexit

cd "%~dp0"
@if %errorlevel% neq 0 goto errorexit

:: Build all the solution configurations

@title Building Debug

msbuild /m /p:Configuration=Debug,Platform=x64 /t:Build /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_d_x64_2017.log lame.sln
@if %errorlevel% neq 0 goto errorexit

msbuild /m /p:Configuration=Debug,Platform=Win32 /t:Build /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_d_win32_2017.log lame.sln
@if %errorlevel% neq 0 goto errorexit

@title Building Release

msbuild /m /p:Configuration=Release,Platform=x64 /t:Build /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_x64_2017.log lame.sln
@if %errorlevel% neq 0 goto errorexit

msbuild /m /p:Configuration=Release,Platform=Win32 /t:Build /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_win32_2017.log lame.sln
@if %errorlevel% neq 0 goto errorexit

@title Building Static Release

msbuild /m /p:Configuration="Static Release",Platform=x64 /t:Build /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_s_x64_2017.log lame.sln
@if %errorlevel% neq 0 goto errorexit

msbuild /m /p:Configuration="Static Release",Platform=Win32 /t:Build /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_s_win32_2017.log lame.sln
@if %errorlevel% neq 0 goto errorexit

@endlocal

:: http://stackoverflow.com/a/27675253
:: Profile then relink Release/x64

@setlocal

call "%VS150COMNTOOLS%VsDevCmd.bat" -arch=x64 -host_arch=x64
@if %errorlevel% neq 0 goto errorexit

cd "%~dp0"
@if %errorlevel% neq 0 goto errorexit

@title Relinking x64 for PGO instrumentation

msbuild /m /p:Configuration=Release,Platform=x64,WholeProgramOptimization=PGInstrument /t:BuildLink /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_x64_2017.log lame.vcxproj
@if %errorlevel% neq 0 goto errorexit

msbuild /m /p:Configuration=Release,Platform=x64,WholeProgramOptimization=PGInstrument /t:LibLinkOnly /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_x64_2017.log lame_enc_dll.vcxproj
@if %errorlevel% neq 0 goto errorexit

msbuild /m /p:Configuration=Release,Platform=x64,WholeProgramOptimization=PGInstrument /t:LibLinkOnly /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_x64_2017.log libmp3lame_dll.vcxproj
@if %errorlevel% neq 0 goto errorexit

@title Profiling x64

"%~dp0..\..\build\bin\v141\x64\Release\lame.exe" -q0 -b128 "%~dp0..\testcase.wav" "%~dp0..\..\build\bin\v141\x64\Release\lame_testcase_128.mp3"
"%~dp0..\..\build\bin\v141\x64\Release\lame.exe" -q0 -V0 "%~dp0..\testcase.wav" "%~dp0..\..\build\bin\v141\x64\Release\lame_testcase_V0.mp3"
"%~dp0..\..\build\bin\v141\x64\Release\lame.exe" -q0 -V6 --resample 22.05 "%~dp0..\testcase.wav" "%~dp0..\..\build\bin\v141\x64\Release\lame_testcase_V6.mp3"
"%~dp0..\..\build\bin\v141\x64\Release\lame.exe" -q0 --abr 56 -mm --resample 11.025 "%~dp0..\testcase.wav" "%~dp0..\..\build\bin\v141\x64\Release\lame_testcase_abr56.mp3"
"%~dp0..\..\build\bin\v141\x64\Release\lame.exe" --decode "%~dp0..\testcase.wav" "%~dp0..\..\build\bin\v141\x64\Release\lame_testcase.mp3"
"%~dp0..\..\build\bin\v141\x64\Release\lame_enc_dll_example.exe" "%~dp0..\testcase.wav"
"%~dp0..\..\build\bin\v141\x64\Release\lame_test.exe" "%~dp0..\..\build\bin\v141\x64\Release\lame_test_random_pgo.mp3" 441000

@title Relinking x64 with PGO

msbuild /m /p:Configuration=Release,Platform=x64,WholeProgramOptimization=PGOptimize,LinkTimeCodeGeneration=PGOptimization /t:BuildLink /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_x64_2017.log lame.vcxproj
@if %errorlevel% neq 0 goto errorexit

msbuild /m /p:Configuration=Release,Platform=x64,WholeProgramOptimization=PGOptimize,LinkTimeCodeGeneration=PGOptimization /t:LibLinkOnly /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_x64_2017.log lame_enc_dll.vcxproj
@if %errorlevel% neq 0 goto errorexit

msbuild /m /p:Configuration=Release,Platform=x64,WholeProgramOptimization=PGOptimize,LinkTimeCodeGeneration=PGOptimization /t:LibLinkOnly /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_x64_2017.log libmp3lame_dll.vcxproj
@if %errorlevel% neq 0 goto errorexit

@endlocal

:: http://stackoverflow.com/a/27675253
:: Profile then relink Release/Win32

@setlocal

call "%VS150COMNTOOLS%VsDevCmd.bat"
@if %errorlevel% neq 0 goto errorexit

cd "%~dp0"
@if %errorlevel% neq 0 goto errorexit

@title Relinking Win32 for PGO instrumentation

msbuild /m /p:Configuration=Release,Platform=Win32,WholeProgramOptimization=PGInstrument /t:BuildLink /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_Win32_2017.log lame.vcxproj
@if %errorlevel% neq 0 goto errorexit

msbuild /m /p:Configuration=Release,Platform=Win32,WholeProgramOptimization=PGInstrument /t:LibLinkOnly /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_Win32_2017.log lame_enc_dll.vcxproj
@if %errorlevel% neq 0 goto errorexit

msbuild /m /p:Configuration=Release,Platform=Win32,WholeProgramOptimization=PGInstrument /t:LibLinkOnly /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_Win32_2017.log libmp3lame_dll.vcxproj
@if %errorlevel% neq 0 goto errorexit

@title Profiling Win32

"%~dp0..\..\build\bin\v141\Win32\Release\lame.exe" -q0 -b128 "%~dp0..\testcase.wav" "%~dp0..\..\build\bin\v141\Win32\Release\lame_testcase_128.mp3"
"%~dp0..\..\build\bin\v141\Win32\Release\lame.exe" -q0 -V0 "%~dp0..\testcase.wav" "%~dp0..\..\build\bin\v141\Win32\Release\lame_testcase_V0.mp3"
"%~dp0..\..\build\bin\v141\Win32\Release\lame.exe" -q0 -V6 --resample 22.05 "%~dp0..\testcase.wav" "%~dp0..\..\build\bin\v141\Win32\Release\lame_testcase_V6.mp3"
"%~dp0..\..\build\bin\v141\Win32\Release\lame.exe" -q0 --abr 56 -mm --resample 11.025 "%~dp0..\testcase.wav" "%~dp0..\..\build\bin\v141\Win32\Release\lame_testcase_abr56.mp3"
"%~dp0..\..\build\bin\v141\Win32\Release\lame.exe" --decode "%~dp0..\testcase.wav" "%~dp0..\..\build\bin\v141\Win32\Release\lame_testcase.mp3"
"%~dp0..\..\build\bin\v141\Win32\Release\lame_enc_dll_example.exe" "%~dp0..\testcase.wav"
"%~dp0..\..\build\bin\v141\Win32\Release\lame_test.exe" "%~dp0..\..\build\bin\v141\Win32\Release\lame_test_random_pgo.mp3" 441000

@title Relinking Win32 with PGO

msbuild /m /p:Configuration=Release,Platform=Win32,WholeProgramOptimization=PGOptimize,LinkTimeCodeGeneration=PGOptimization /t:BuildLink /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_Win32_2017.log lame.vcxproj
@if %errorlevel% neq 0 goto errorexit

msbuild /m /p:Configuration=Release,Platform=Win32,WholeProgramOptimization=PGOptimize,LinkTimeCodeGeneration=PGOptimization /t:LibLinkOnly /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_Win32_2017.log lame_enc_dll.vcxproj
@if %errorlevel% neq 0 goto errorexit

msbuild /m /p:Configuration=Release,Platform=Win32,WholeProgramOptimization=PGOptimize,LinkTimeCodeGeneration=PGOptimization /t:LibLinkOnly /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_Win32_2017.log libmp3lame_dll.vcxproj
@if %errorlevel% neq 0 goto errorexit

@title Command Prompt
@endlocal

@exit /b 0

:weberrorexit
@echo ***** Unable to find Visual Studio 2017 *****
start https://www.visualstudio.com/downloads/#build-tools-for-visual-studio-2017

:errorexit
@title Command Prompt
@endlocal
@exit /b 1
